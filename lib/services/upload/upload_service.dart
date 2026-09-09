/// Server upload (opt-in): one multipart POST per memo — audio, transcript,
/// metadata — streamed to the user's own server with flat memory and a
/// single pass over the audio. Only `dart:io` and already-vendored packages
/// are used; the protocol is deliberately hand-rolled like the model
/// downloads (ModelManager), not delegated to a new HTTP dependency.
///
/// Wire format (part order matters — the manifest travels LAST because it
/// carries the hashes of the streamed parts):
///
///   audio      application/octet-stream  (the memo's whole audio file)
///   transcript application/json          (Transcript.toJson())
///   metadata   application/json          (manifest incl. audio_sha256 /
///                                         transcript_sha256)
///
/// Success is defined strictly: HTTP 200/201 with a JSON body carrying
/// {"ok": true}. Anything else is classified as retryable (5xx, 429,
/// network errors, unparseable confirmations) or permanent (4xx), never
/// as success — the phone may re-send the same memo any number of times;
/// the server dedupes by memo id.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models.dart';

/// Everything an upload attempt needs that is NOT in the memo row.
class UploadConfig {
  const UploadConfig({required this.url, required this.token});

  final String url;
  final String token;
}

/// One memo's upload payload (audio path + the already-structured transcript).
class MemoUpload {
  const MemoUpload({
    required this.memo,
    this.cassetteLabel,
    this.appVersion = '',
  });

  final Memo memo;
  final String? cassetteLabel;
  final String appVersion;
}

/// Outcome triage — the queue maps these onto its retry/backoff policy.
sealed class UploadOutcome {
  const UploadOutcome();
}

class UploadSuccess extends UploadOutcome {
  const UploadSuccess({this.updated = false});

  /// Server already had this memo's audio and refreshed the artifacts
  /// (edited transcript / retry after a lost response).
  final bool updated;
}

class UploadRetryable extends UploadOutcome {
  const UploadRetryable(this.reason, {this.retryAfter});

  final String reason;

  /// Server-provided `Retry-After` (429), if any.
  final Duration? retryAfter;
}

/// Auth rejected, malformed request, conflict — retrying as-is is pointless;
/// the job goes 'failed' and the UI offers a manual retry/configure path.
class UploadPermanent extends UploadOutcome {
  const UploadPermanent(this.reason);

  final String reason;
}

/// The network seam: upload starts only when preconditions hold locally.
abstract interface class UploadPerformer {
  Future<UploadOutcome> upload(UploadConfig config, MemoUpload data);
}

/// Real [UploadPerformer] over dart:io. Never logs the token or payload
/// content — only ids/enums may reach [onLog].
class UploadService implements UploadPerformer {
  UploadService({
    HttpClient Function()? httpClientFactory,
    this.connectTimeout = const Duration(seconds: 20),
    this.responseTimeout = const Duration(minutes: 15),
    this._onLog,
  }) : _newHttpClient = httpClientFactory ?? HttpClient.new;

  final HttpClient Function() _newHttpClient;
  final Duration connectTimeout;

  /// Covers the entire body send + response; an upload stalling server-side
  /// (server accepts bytes then wedges) becomes retryable, not immortal.
  final Duration responseTimeout;
  final void Function(String message)? _onLog;

  void _log(String message) => _onLog?.call(message);

  /// "Test connection": GET the health route derived from the upload URL
  /// (`.../upload` → `.../health`); true only on a JSON {"ok": true}.
  Future<bool> checkHealth(String uploadUrl) async {
    final uri = Uri.tryParse(uploadUrl);
    if (uri == null) return false;
    final healthUri =
        uri.replace(path: uri.path.replaceFirst(RegExp(r'upload/?$'), 'health'));
    final client = _newHttpClient();
    client.connectionTimeout = connectTimeout;
    try {
      final request = await client.getUrl(healthUri);
      final response = await request.close().timeout(connectTimeout);
      final body = await utf8.decodeStream(response);
      if (response.statusCode != 200) return false;
      return (jsonDecode(body) as Map?)?['ok'] == true;
    } catch (_) {
      return false;
    } finally {
      client.close(force: true);
    }
  }

  @override
  Future<UploadOutcome> upload(UploadConfig config, MemoUpload data) async {
    final memo = data.memo;
    final uri = Uri.tryParse(config.url);
    if (uri == null || !(uri.isScheme('https') || uri.isScheme('http'))) {
      return const UploadPermanent('invalid upload URL');
    }
    if (uri.isScheme('http') && !isPlainHttpAllowed(uri)) {
      // Plain HTTP carries the token unprotected; allowed only for
      // explicit local-development / LAN targets.
      return const UploadPermanent(
          'plain HTTP is only allowed for loopback/LAN endpoints — use HTTPS');
    }
    final transcript = memo.transcript;
    if (transcript == null) {
      return const UploadPermanent('transcript missing');
    }
    final dot = memo.filePath.lastIndexOf('.');
    final ext = dot > memo.filePath.lastIndexOf('/')
        ? memo.filePath.substring(dot + 1).toLowerCase()
        : '';
    if (ext != 'm4a' && ext != 'wav') {
      return UploadPermanent('unsupported audio container: $ext');
    }
    final audio = File(memo.filePath);
    if (!await audio.exists()) {
      return const UploadPermanent('audio file missing');
    }
    final audioLength = await audio.length();
    if (audioLength == 0) {
      return const UploadPermanent('audio file empty');
    }

    _log('upload: memo ${memo.id} — $audioLength B audio.$ext');

    final client = _newHttpClient();
    client.connectionTimeout = connectTimeout;
    try {
      // Total length is unknowable upfront (the trailing metadata part
      // carries hashes computed while streaming): the body goes chunked —
      // the server streams it just the same.
      final request = await client.postUrl(uri);
      final boundary = 'dk-${const Uuid().v4().replaceAll('-', '')}';
      request.headers
        ..set(HttpHeaders.authorizationHeader, 'Bearer ${config.token}')
        ..set('Idempotency-Key', memo.id)
        ..contentType = ContentType('multipart', 'form-data',
            parameters: {'boundary': boundary});

      var buffered = 0;
      Future<void> writeAscii(String s) async {
        final bytes = ascii.encode(s);
        request.add(bytes);
        buffered += bytes.length;
      }

      Future<void> maybeFlush() async {
        // Bound request-buffer growth: flush ~1 MiB cadences so memory stays
        // flat regardless of how slowly the network drains the body.
        if (buffered >= 1 << 20) {
          buffered = 0;
          await request.flush();
        }
      }

      Future<void> writePart(String asciiPart) async {
        await writeAscii(asciiPart);
        await maybeFlush();
      }

      // ---- part 1: audio (streamed; hashed in the same pass)
      await writePart('--$boundary\r\n'
          'Content-Disposition: form-data; name="audio"; filename="audio.$ext"\r\n'
          'Content-Type: application/octet-stream\r\n\r\n');
      final audioDigestSink = _DigestBuffer();
      final audioHasher = sha256.startChunkedConversion(audioDigestSink);
      await for (final chunk in audio.openRead()) {
        audioHasher.add(chunk);
        request.add(chunk);
        buffered += chunk.length;
        await maybeFlush();
      }
      audioHasher.close();
      await writePart('\r\n');

      // ---- part 2: transcript
      final transcriptBytes =
          utf8.encode(jsonEncode(transcript.toJson()));
      final transcriptSha = sha256.convert(transcriptBytes).toString();
      await writePart('--$boundary\r\n'
          'Content-Disposition: form-data; name="transcript"; filename="transcript.json"\r\n'
          'Content-Type: application/json\r\n\r\n');
      request.add(transcriptBytes);
      buffered += transcriptBytes.length;
      await writePart('\r\n');

      // ---- part 3: metadata (last — carries the streamed parts' hashes)
      final metadata = buildUploadManifest(
        data,
        audioFormat: ext,
        audioSizeBytes: audioLength,
        audioSha256: audioDigestSink.hexDigest,
        transcriptSha256: transcriptSha,
      );
      await writePart('--$boundary\r\n'
          'Content-Disposition: form-data; name="metadata"; filename="metadata.json"\r\n'
          'Content-Type: application/json\r\n\r\n');
      request.add(utf8.encode(jsonEncode(metadata)));
      await writePart('\r\n--$boundary--\r\n');
      await request.flush();

      final response = await request.close().timeout(responseTimeout);
      final body =
          await utf8.decodeStream(response).timeout(const Duration(seconds: 30));
      final outcome = classifyResponse(response.statusCode, body,
          retryAfterHeader: response.headers.value('retry-after'));
      _log('upload: memo ${memo.id} — HTTP ${response.statusCode} '
          '→ ${outcome.runtimeType}');
      return outcome;
    } on SocketException {
      return const UploadRetryable('network unreachable');
    } on HttpException {
      return const UploadRetryable('connection failed');
    } on HandshakeException {
      return const UploadRetryable('TLS handshake failed');
    } on TimeoutException {
      return const UploadRetryable('server timed out');
    } on FileSystemException {
      // The audio vanished/moved mid-read (e.g. deletion) — worth one
      // retry pass; the preflight re-checks converge it.
      return const UploadRetryable('local file error');
    } finally {
      client.close(force: true);
    }
  }
}

/// The metadata manifest — mirrors the cassette-export memo shape
/// (`cassette_exporter.dart`) so the server sees the app's own data model.
Map<String, Object?> buildUploadManifest(
  MemoUpload data, {
  required String audioFormat,
  required int audioSizeBytes,
  required String audioSha256,
  required String transcriptSha256,
}) {
  final memo = data.memo;
  return {
    'schema': 1,
    'memo_id': memo.id,
    'cassette_id': memo.cassetteId,
    'cassette_label': data.cassetteLabel,
    'memo_summary': memo.memoSummary,
    'created_at': memo.createdAt.toIso8601String(),
    'duration_ms': memo.durationMs,
    'detected_lang': memo.detectedLang,
    // Diktafon captures are fixed-format by construction (16 kHz mono WAV,
    // transcoded to 16 kHz mono AAC-LC ~48 kbps).
    'audio_format': audioFormat,
    'sample_rate': 16000,
    'channels': 1,
    'audio_size_bytes': audioSizeBytes,
    'audio_sha256': audioSha256,
    'transcript_sha256': transcriptSha256,
    'app_version': data.appVersion,
    'uploaded_at': DateTime.now().toIso8601String(),
  };
}

/// Response → outcome policy. 2xx WITHOUT the contractual {"ok": true} is
/// retryable (the memo is not marked uploaded on an ambiguous answer); the
/// server's idempotency keying makes the retry safe.
UploadOutcome classifyResponse(int status, String body,
    {String? retryAfterHeader}) {
  var ok = false;
  var updated = false;
  try {
    final decoded = jsonDecode(body);
    if (decoded is Map) {
      ok = decoded['ok'] == true;
      updated = decoded['updated'] == true;
    }
  } catch (_) {/* handled below */}
  switch (status) {
    case 200:
    case 201:
      return ok
          ? UploadSuccess(updated: updated)
          : const UploadRetryable('malformed success response');
    case 401:
    case 403:
      return UploadPermanent('authentication rejected (HTTP $status)');
    case 400:
    case 404:
    case 409:
    case 413:
    case 422:
      return UploadPermanent('server rejected the request (HTTP $status)');
    case 429:
      return UploadRetryable('rate limited (HTTP 429)',
          retryAfter: _parseRetryAfter(retryAfterHeader));
    default:
      return status >= 500
          ? UploadRetryable('server error (HTTP $status)')
          : UploadRetryable('unexpected response (HTTP $status)');
  }
}

Duration? _parseRetryAfter(String? header) {
  if (header == null) return null;
  final seconds = int.tryParse(header.trim());
  return seconds == null ? null : Duration(seconds: seconds);
}

/// Plain-HTTP escape hatch: only loopback and private/LAN destinations
/// may receive unencrypted uploads (they never need the public DNS, so
/// nothing trustworthy-looking slips through). Anything else must use TLS.
bool isPlainHttpAllowed(Uri uri) {
  final host = uri.host.toLowerCase();
  if (host == 'localhost' || host == '::1') return true;
  if (host.endsWith('.local') || host.endsWith('.lan')) return true;
  final v4 = RegExp(r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$')
      .firstMatch(host);
  if (v4 != null) {
    final a = int.parse(v4.group(1)!);
    final b = int.parse(v4.group(2)!);
    // 127/8 loopback, 10/8 and 192.168/16 private, 172.16-31/12 private,
    // 100.64/10 carrier-grade NAT (e.g. tailnets self-hosted by the user).
    if (a == 127 || a == 10) return true;
    if (a == 192 && b == 168) return true;
    if (a == 172 && b >= 16 && b <= 31) return true;
    if (a == 100 && b >= 64 && b <= 127) return true;
  }
  return false;
}

class _DigestBuffer implements Sink<Digest> {
  Digest? _digest;

  String get hexDigest => _digest?.toString() ?? '';

  @override
  void add(Digest data) => _digest = data;

  @override
  void close() {}
}
