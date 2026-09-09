import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:diktafon/domain/models.dart';
import 'package:diktafon/services/upload/upload_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// A loopback HTTP server capturing requests for assertions. Bodies are
/// collected whole — the cases here stay under ~10 MB (the service's
/// memory-flatness is structural: the request sink is fed from file streams
/// in 64 KiB chunks with periodic flushes, so no buffer can O(n) grow).
class _CaptureServer {
  _CaptureServer(this._server);

  final HttpServer _server;
  int statusCode = 201;
  String responseBody = '{"ok": true, "meeting_id": "x"}';
  Map<String, String> extraHeaders = const {};
  bool hang = false; // accept and never respond
  final List<_CapturedRequest> requests = [];

  String get baseUrl => 'http://127.0.0.1:${_server.port}';

  static Future<_CaptureServer> start(
      {required void Function(Future<void> Function()) queueMicrotask}) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final capture = _CaptureServer(server);
    server.listen((request) async {
      final body = await request
          .fold<List<int>>(<int>[], (bytes, chunk) => bytes..addAll(chunk));
      capture.requests.add(_CapturedRequest(
        path: request.uri.path,
        headers: {
          for (final name in [
            'authorization',
            'idempotency-key',
            'content-type',
          ])
            name: request.headers.value(name) ?? '',
        },
        body: body,
      ));
      if (capture.hang) return; // connection left open — the client times out
      request.response.statusCode = capture.statusCode;
      capture.extraHeaders
          .forEach((k, v) => request.response.headers.set(k, v));
      request.response.write(capture.responseBody);
      await request.response.close();
    });
    return capture;
  }

  Future<void> close() => _server.close(force: true);
}

class _CapturedRequest {
  _CapturedRequest(
      {required this.path, required this.headers, required this.body});
  final String path;
  final Map<String, String> headers;
  final List<int> body;
}

Memo memoWith(Transcript? transcript,
    {String filePath = '/nonexistent/audio.m4a'}) {
  return Memo(
    id: '550e8400-e29b-41d4-a716-446655440000',
    cassetteId: 'cassette-1',
    filePath: filePath,
    durationMs: 4200,
    createdAt: DateTime.utc(2026, 9, 9, 12),
    status: MemoStatus.ready,
    detectedLang: 'cs',
    transcript: transcript,
    memoSummary: 'krátký gist',
  );
}

Transcript sampleTranscript() => Transcript(languageCode: 'cs', segments: [
      Segment(startMs: 0, endMs: 1900, words: [
        Word(text: 'dobrý', startMs: 0, endMs: 400),
        Word(text: 'den', startMs: 500, endMs: 900),
        Word(text: 'světe', startMs: 1000, endMs: 1900),
      ]),
    ]);

Future<File> writeAudio(Directory dir, List<int> bytes,
    {String name = 'audio.m4a'}) async {
  final file = File('${dir.path}/$name');
  await file.writeAsBytes(bytes);
  return file;
}

void main() {
  late Directory tmp;
  setUp(() async =>
      tmp = await Directory.systemTemp.createTemp('upload_service_test'));
  tearDown(() async => tmp.delete(recursive: true));

  UploadService service() => UploadService(
        responseTimeout: const Duration(milliseconds: 400),
      );

  Future<UploadOutcome> uploadMemo(UploadService svc, UploadConfig cfg,
      Memo memo, {String? cassetteLabel}) {
    return svc.upload(cfg, MemoUpload(memo: memo, cassetteLabel: cassetteLabel));
  }

  group('wire format', () {
    late _CaptureServer server;
    setUp(() async => server = await _CaptureServer.start(
        queueMicrotask: (fn) => unawaited(fn())));
    tearDown(() => server.close());

    test('streams audio, transcript, metadata as three ordered parts with '
        'hashes in the trailing manifest', () async {
      final audioBytes =
          List<int>.generate(64 * 1024 + 3, (i) => (i * 31 + 7) % 256);
      final audio = await writeAudio(tmp, audioBytes);
      final memo = memoWith(sampleTranscript(), filePath: audio.path);
      final cfg =
          UploadConfig(url: '${server.baseUrl}/diktafon/upload', token: 'test-token');

      final outcome = await uploadMemo(service(), cfg, memo,
          cassetteLabel: 'jednání');
      expect(outcome, isA<UploadSuccess>());

      expect(server.requests, hasLength(1));
      final request = server.requests.single;
      expect(request.path, '/diktafon/upload');
      expect(request.headers['authorization'], 'Bearer test-token');
      expect(request.headers['idempotency-key'], memo.id);
      final contentType = request.headers['content-type']!;
      final boundary =
          RegExp('boundary=(.+)\$').firstMatch(contentType)!.group(1)!;

      // Split the body on boundaries: [pre, audio, transcript, metadata, end]
      final boundaryBytes = ascii.encode('--$boundary');
      final parts = <List<int>>[];
      var rest = request.body;
      while (true) {
        final start = _indexOf(rest, boundaryBytes);
        if (start < 0) break;
        final end = _indexOf(rest, boundaryBytes, start + boundaryBytes.length);
        if (end < 0) break;
        parts.add(rest.sublist(start + boundaryBytes.length, end));
        rest = rest.sublist(end);
      }
      expect(parts, hasLength(3));

      // Part 1: audio — byte-identical with the file.
      expect(utf8.decode(_headersOf(parts[0])), contains('name="audio"'));
      expect(_bodyOf(parts[0]), audioBytes);

      // Part 2: transcript — Transcript.toJson().
      expect(utf8.decode(_headersOf(parts[1])), contains('name="transcript"'));
      final transcript = jsonDecode(utf8.decode(_bodyOf(parts[1])));
      expect(transcript['lang'], 'cs');
      expect(transcript['segments'][0]['w'][2]['t'], 'světe');

      // Part 3 LAST: metadata carries the sha256 of the streamed parts.
      expect(utf8.decode(_headersOf(parts[2])), contains('name="metadata"'));
      final meta = jsonDecode(utf8.decode(_bodyOf(parts[2])));
      expect(meta['memo_id'], memo.id);
      expect(meta['cassette_label'], 'jednání');
      expect(meta['memo_summary'], 'krátký gist');
      expect(meta['detected_lang'], 'cs');
      expect(meta['audio_format'], 'm4a');
      expect(meta['audio_size_bytes'], audioBytes.length);
      expect(meta['audio_sha256'], sha256.convert(audioBytes).toString());
      final transcriptBytes = utf8.encode(jsonEncode(memo.transcript!.toJson()));
      expect(meta['transcript_sha256'], sha256.convert(transcriptBytes).toString());
      expect(meta['duration_ms'], 4200);
      expect(meta['sample_rate'], 16000);
    });

    test('wav uploads keep their extension', () async {
      final audio = await writeAudio(tmp, [1, 2, 3], name: 'audio.wav');
      final memo = memoWith(sampleTranscript(), filePath: audio.path);
      final cfg =
          UploadConfig(url: '${server.baseUrl}/diktafon/upload', token: 't');
      final outcome = await uploadMemo(service(), cfg, memo);
      expect(outcome, isA<UploadSuccess>());
      expect(utf8.decode(server.requests.single.body),
          contains('filename="audio.wav"'));
    });

    test('updated-duplicate is a success flavour, not an error', () async {
      server.statusCode = 200;
      server.responseBody = '{"ok": true, "updated": true}';
      final audio = await writeAudio(tmp, [9, 9]);
      final outcome = await uploadMemo(
          service(),
          UploadConfig(url: '${server.baseUrl}/diktafon/upload', token: 't'),
          memoWith(sampleTranscript(), filePath: audio.path));
      expect((outcome as UploadSuccess).updated, isTrue);
    });
  });

  group('outcome classification', () {
    late _CaptureServer server;
    setUp(() async => server = await _CaptureServer.start(
        queueMicrotask: (fn) => unawaited(fn())));
    tearDown(() => server.close());

    Future<UploadOutcome> withStatus(int status,
        {String body = '{}', Map<String, String> headers = const {}}) async {
      server.statusCode = status;
      server.responseBody = body;
      server.extraHeaders = headers;
      final audio = await writeAudio(tmp, [1, 2, 3]);
      return uploadMemo(service(), UploadConfig(url: '${server.baseUrl}/diktafon/upload', token: 't'),
          memoWith(sampleTranscript(), filePath: audio.path));
    }

    test('server errors are retryable', () async {
      expect(await withStatus(500), isA<UploadRetryable>());
      expect(await withStatus(502), isA<UploadRetryable>());
    });

    test('429 is retryable and honors Retry-After', () async {
      final outcome = await withStatus(429, headers: {'retry-after': '120'});
      expect((outcome as UploadRetryable).retryAfter,
          const Duration(seconds: 120));
    });

    test('auth rejections are permanent (configuration error, not transient)',
        () async {
      expect(await withStatus(401), isA<UploadPermanent>());
      expect(await withStatus(403), isA<UploadPermanent>());
    });

    test('4xx request rejections are permanent', () async {
      expect(await withStatus(400), isA<UploadPermanent>());
      expect(await withStatus(404), isA<UploadPermanent>());
      expect(await withStatus(409), isA<UploadPermanent>());
      expect(await withStatus(413), isA<UploadPermanent>());
    });

    test('a 2xx without the contractual {"ok": true} does NOT count as '
        'uploaded — the retry is safe thanks to idempotency', () async {
      expect(await withStatus(200, body: 'garbage'), isA<UploadRetryable>());
      expect(await withStatus(201, body: '{"ok": false}'),
          isA<UploadRetryable>());
    });

    test('network unreachable is retryable', () async {
      // Port 1 on loopback refuses connections deterministically.
      final audio = await writeAudio(tmp, [1]);
      final outcome = await uploadMemo(
          service(), const UploadConfig(url: 'http://127.0.0.1:1/x', token: 't'),
          memoWith(sampleTranscript(), filePath: audio.path));
      expect(outcome, isA<UploadRetryable>());
    });

    test('server accepting but never answering is retryable (timeout)',
        () async {
      server.hang = true;
      final audio = await writeAudio(tmp, [1]);
      final outcome = await uploadMemo(
          service(), UploadConfig(url: '${server.baseUrl}/diktafon/upload', token: 't'),
          memoWith(sampleTranscript(), filePath: audio.path));
      expect(outcome, isA<UploadRetryable>());
    });
  });

  group('preconditions', () {
    late _CaptureServer server;
    setUp(() async => server = await _CaptureServer.start(
        queueMicrotask: (fn) => unawaited(fn())));
    tearDown(() => server.close());

    test('missing transcript is permanent (cannot become retriable)',
        () async {
      final audio = await writeAudio(tmp, [1]);
      final outcome = await uploadMemo(
          service(),
          UploadConfig(url: '${server.baseUrl}/diktafon/upload', token: 't'),
          memoWith(null, filePath: audio.path));
      expect(outcome, isA<UploadPermanent>());
      expect(server.requests, isEmpty);
    });

    test('missing audio file is permanent', () async {
      final outcome = await uploadMemo(
          service(),
          UploadConfig(url: '${server.baseUrl}/diktafon/upload', token: 't'),
          memoWith(sampleTranscript(), filePath: '${tmp.path}/gone.m4a'));
      expect(outcome, isA<UploadPermanent>());
      expect(server.requests, isEmpty);
    });

    test('invalid URL is permanent', () async {
      final audio = await writeAudio(tmp, [1]);
      final outcome = await uploadMemo(
          service(), const UploadConfig(url: ':::nope', token: 't'),
          memoWith(sampleTranscript(), filePath: audio.path));
      expect(outcome, isA<UploadPermanent>());
    });

    test('plain HTTP is refused for public hosts but allowed for '
        'loopback/LAN (the local-dev escape hatch)', () async {
      final audio = await writeAudio(tmp, [1]);
      Future<UploadOutcome> go(String url) => uploadMemo(
          service(), UploadConfig(url: url, token: 't'),
          memoWith(sampleTranscript(), filePath: audio.path));

      expect(await go('http://example.com/diktafon/upload'),
          isA<UploadPermanent>());
      expect(await go('http://8.8.8.8/diktafon/upload'),
          isA<UploadPermanent>());
      // Loopback / LAN / tailnet shapes pass the gate (no network attempt
      // is asserted here — the refusal is what costs a database write).
      expect(isPlainHttpAllowed(Uri.parse('http://127.0.0.1:8378/x')), isTrue);
      expect(isPlainHttpAllowed(Uri.parse('http://192.168.1.10/x')), isTrue);
      expect(isPlainHttpAllowed(Uri.parse('http://10.0.0.5/x')), isTrue);
      expect(isPlainHttpAllowed(Uri.parse('http://100.64.0.1/x')), isTrue);
      expect(isPlainHttpAllowed(Uri.parse('http://nas.lan/x')), isTrue);
      expect(isPlainHttpAllowed(Uri.parse('http://example.com/x')), isFalse);
    });
  });

  group('health check', () {
    test('derives the health route from the upload URL', () async {
      final server = await _CaptureServer.start(
          queueMicrotask: (fn) => unawaited(fn()));
      server.statusCode = 200;
      server.responseBody = '{"ok": true}';
      expect(
          await service().checkHealth('${server.baseUrl}/diktafon/upload'),
          isTrue);
      expect(server.requests.single.path, '/diktafon/health');
      server.responseBody = '{"ok": false}';
      expect(
          await service().checkHealth('${server.baseUrl}/diktafon/upload'),
          isFalse);
      expect(await service().checkHealth('http://127.0.0.1:1/x/upload'),
          isFalse);
      await server.close();
    });
  });
}

/// Byte-array helpers for the tiny multipart assertions above (small
/// payloads only — the real streaming path is exercised end-to-end here).
int _indexOf(List<int> haystack, List<int> needle, [int start = 0]) {
  outer:
  for (var i = start; i + needle.length <= haystack.length; i++) {
    for (var j = 0; j < needle.length; j++) {
      if (haystack[i + j] != needle[j]) continue outer;
    }
    return i;
  }
  return -1;
}

List<int> _headersOf(List<int> part) {
  final sep = _indexOf(part, [13, 10, 13, 10]); // \r\n\r\n
  return part.sublist(0, sep);
}

List<int> _bodyOf(List<int> part) {
  final sep = _indexOf(part, [13, 10, 13, 10]);
  var body = part.sublist(sep + 4);
  if (body.length >= 2 && body[body.length - 2] == 13 && body.last == 10) {
    body = body.sublist(0, body.length - 2);
  }
  return body;
}
