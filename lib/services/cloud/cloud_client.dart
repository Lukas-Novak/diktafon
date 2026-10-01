/// Cloud processing client: the authenticated phone → ingest calls —
/// request creation, resumable status polling, result download, cancel and
/// retry — over the same streamed-multipart discipline as the archival
/// upload (no new dependencies, bounded memory, sha verified by construction).
///
/// Audio bytes are hashed WHILE being streamed (single pass), and network
/// failures classify into retryable/permanent outcome kinds consumed by the
/// queue; provider-user-facing errors never escape the classified codes, and
/// credentials/payload contents never reach any log.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

/// Same configuration tuple the archival upload uses; deliberately taken
/// from the shared store (one backend connection for both modalities).
class CloudConfig {
  const CloudConfig({required this.url, required this.token});

  final String url;
  final String token;
}

/// Outcome of a cloud round trip; retryable kinds carry optional
/// server-honored Retry-After.
sealed class CloudOutcome {}

class CloudAccepted extends CloudOutcome {
  CloudAccepted({required this.requestId, required this.state, required this.duplicate});
  final String requestId;
  final String state;
  final bool duplicate;
}

class CloudStatus extends CloudOutcome {
  CloudStatus(
      {required this.state,
      required this.errorCode,
      required this.attempts,
      required this.clientRevision});
  final String state; // queued|running|publishing|complete|failed|cancelled
  final String? errorCode;
  final int attempts;
  final int clientRevision;
}

class CloudResultLoaded extends CloudOutcome {
  CloudResultLoaded(this.payload);
  final Map<String, dynamic> payload;
}

class CloudActioned extends CloudOutcome {} // cancel/retry acknowledged

class CloudResultNotReady extends CloudOutcome {}

class CloudRetryableError extends CloudOutcome implements Exception {
  CloudRetryableError(this.reason, {this.retryAfter});
  final String reason;
  final int? retryAfter;
}

class CloudPermanentError extends CloudOutcome implements Exception {
  CloudPermanentError(this.code);
  final String code; // configuration | auth | conflict | media | result_not_found
}

class CloudClient {
  CloudClient({HttpClient Function()? httpClientFactory, this.responseTimeout = const Duration(minutes: 15)})
      : _newHttpClient = httpClientFactory ?? HttpClient.new;

  final HttpClient Function() _newHttpClient;
  final Duration responseTimeout;

  static const _uuid = Uuid();

  /// Computes sha256 of [file] in one pass (bounded chunks), used both for
  /// metadata verification and result-fingerprint checks by the caller.
  static Future<String> sha256OfFile(File file) async {
    final sink = _DigestSink();
    final hasher = sha256.startChunkedConversion(sink);
    await for (final chunk in file.openRead()) {
      hasher.add(chunk);
    }
    hasher.close();
    return sink.hexDigest;
  }

  Future<CloudOutcome> submitTranscriptionJob({
    required CloudConfig config,
    required String memoId,
    required String requestId,
    required int clientRevision,
    required String audioPath,
    required String metadataLanguage,
    required int durationMs,
  }) async {
    final audio = File(audioPath);
    if (!await audio.exists()) {
      return CloudPermanentError('audio_missing');
    }
    final ext = audioPath.endsWith('.wav') ? 'wav' : 'm4a';
    final size = await audio.length();
    if (size == 0) return CloudPermanentError('audio_empty');
    final sha = await sha256OfFile(audio);

    final metadata = <String, Object?>{
      'memo_id': memoId,
      'request_id': requestId,
      'client_revision': clientRevision,
      'purpose': 'transcribe',
      'audio_format': ext,
      'audio_size_bytes': size,
      'audio_sha256': sha,
      'duration_ms': durationMs,
      'requested_language': metadataLanguage,
    };

    final client = _newHttpClient();
    try {
      final base = v1Uri(config.url, '/processing');
      final request = await client.postUrl(base);
      final boundary = 'dk-${_uuid.v4().replaceAll('-', '')}';
      request.headers
        ..set(HttpHeaders.authorizationHeader, 'Bearer ${config.token}')
        ..contentType = ContentType('multipart', 'form-data',
            parameters: {'boundary': boundary});

      Future<void> write(String s) async => request.add(ascii.encode(s));
      var buffered = 0;
      Future<void> flush() async {
        // Keep memory bounded for very large meetings exactly like the
        // archival upload cadence (server sees plain chunked multipart).
        if (buffered >= 1 << 20) {
          buffered = 0;
          await request.flush();
        }
      }

      await write('--$boundary\r\n'
          'Content-Disposition: form-data; name="audio"; filename="audio.$ext"\r\n'
          'Content-Type: application/octet-stream\r\n\r\n');
      await for (final chunk in audio.openRead()) {
        request.add(chunk);
        buffered += chunk.length;
        await flush();
      }
      await write('\r\n--$boundary\r\n'
          'Content-Disposition: form-data; name="metadata"; filename="metadata.json"\r\n'
          'Content-Type: application/json\r\n\r\n');
      request.add(utf8.encode(jsonEncode(metadata)));
      buffered += 2048;
      await write('\r\n--$boundary--\r\n');
      await request.flush();

      final response = await request.close().timeout(responseTimeout);
      final body = await utf8.decodeStream(response).timeout(const Duration(seconds: 30));
      if (response.statusCode == 201 || response.statusCode == 200) {
        final payload = _jsonMap(body);
        return CloudAccepted(
            requestId: requestId,
            state: (payload['state'] as String?) ?? 'queued',
            duplicate: payload['duplicate'] == true);
      }
      return _failure(response.statusCode, body);
    } on SocketException {
      return CloudRetryableError('network_unreachable');
    } on TimeoutException {
      return CloudRetryableError('timeout');
    } on HttpException {
      return CloudRetryableError('connection_failed');
    } on HandshakeException {
      return CloudRetryableError('tls_failed');
    } finally {
      client.close(force: true);
    }
  }

  Future<CloudOutcome> jobStatus(CloudConfig config, String requestId) async {
    final out = await _jsonCall(config, 'GET', '/jobs/$requestId');
    if (out is CloudStatus) return out;
    return out;
  }

  Future<CloudOutcome> jobResult(CloudConfig config, String requestId) async {
    return _jsonCall(config, 'GET', '/jobs/$requestId/result');
  }

  Future<CloudOutcome> cancelJob(CloudConfig config, String requestId) async {
    return _jsonCall(config, 'POST', '/jobs/$requestId/cancel');
  }

  Future<CloudOutcome> retryJob(CloudConfig config, String requestId) async {
    return _jsonCall(config, 'POST', '/jobs/$requestId/retry');
  }

  /// The ingest v1 root hangs off the upload endpoint's parent: strip a
  /// trailing `/upload` from the configured endpoint, then append
  /// `/v1$suffix`. Callers pass suffixes relative to the v1 root
  /// (`/jobs/…`, `/processing`) — full `/diktafon/v1/…` paths would double
  /// the prefix.
  static Uri v1Uri(String uploadUrl, String suffix) {
    final uri = Uri.parse(uploadUrl);
    final root = uri.path.endsWith('/upload')
        ? uri.path.substring(0, uri.path.length - '/upload'.length)
        : uri.path;
    return uri.replace(path: '$root/v1$suffix');
  }

  Future<CloudOutcome> _jsonCall(CloudConfig config, String verb, String suffix) async {
    final client = _newHttpClient();
    try {
      final uri = v1Uri(config.url, suffix);
      final request = await (switch (verb) {
        'GET' => client.getUrl(uri),
        'POST' => client.postUrl(uri),
        _ => throw ArgumentError(verb),
      });
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer ${config.token}');
      final response = await request.close().timeout(const Duration(seconds: 20));
      final body = await utf8.decodeStream(response)
          .timeout(const Duration(seconds: 30), onTimeout: () => '{}');
      return _response(verb, response.statusCode, body);
    } on SocketException {
      return CloudRetryableError('network_unreachable');
    } on TimeoutException {
      return CloudRetryableError('timeout');
    } on HttpException {
      return CloudRetryableError('connection_failed');
    } on HandshakeException {
      return CloudRetryableError('tls_failed');
    } finally {
      client.close(force: true);
    }
  }

  CloudOutcome _response(String verb, int status, String body) {
    if (status == 200 || status == 201) {
      final payload = _jsonMap(body);
      if (payload.containsKey('state')) {
        return CloudStatus(
            state: payload['state'] as String,
            errorCode: payload['error_code'] as String?,
            attempts: payload['attempts'] as int? ?? 0,
            clientRevision: payload['client_revision'] as int? ?? 1);
      }
      if (payload.containsKey('transcript')) return CloudResultLoaded(payload);
      return CloudActioned();
    }
    return _failure(status, body);
  }

  CloudOutcome _failure(int status, String body) {
    final error = _jsonMap(body)['error'] as String? ?? '';
    if (status == 401 || status == 403) return CloudPermanentError('auth');
    if (status == 429 || status >= 500 || status == 408) {
      return CloudRetryableError(error.isEmpty ? 'server_$status' : error);
    }
    if (status == 404) return CloudPermanentError('not_found');
    if (status == 409) {
      if (error == 'result_not_ready') return CloudResultNotReady();
      return CloudPermanentError(error.isEmpty ? 'conflict' : error);
    }
    if (status == 400) return CloudPermanentError(error.isEmpty ? 'rejected' : error);
    return CloudRetryableError('unexpected_$status');
  }

  Map<String, dynamic> _jsonMap(String body) {
    try {
      final value = jsonDecode(body);
      return value is Map<String, dynamic> ? value : const {};
    } catch (_) {
      return const {};
    }
  }
}

class _DigestSink implements Sink<Digest> {
  Digest? _digest;

  String get hexDigest => _digest?.toString() ?? '';

  @override
  void add(Digest data) => _digest = data;

  @override
  void close() {}
}
