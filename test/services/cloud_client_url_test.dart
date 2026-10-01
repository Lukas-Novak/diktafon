import 'package:diktafon/services/cloud/cloud_client.dart';
import 'package:flutter_test/flutter_test.dart';

/// The v1 verb URLs hang off the upload endpoint's parent path exactly once.
/// A regression here 404'd every poll because `:v1` got prefixed twice.
void main() {
  group('CloudClient.v1Uri', () {
    test('processing POST strips the /upload tail and appends /v1/processing',
        () {
      expect(
        CloudClient.v1Uri(
                'https://speech-server.example/diktafon/upload', '/processing')
            .toString(),
        'https://speech-server.example/diktafon/v1/processing',
      );
    });

    test('job verbs keep a single /v1 prefix', () {
      const base = 'https://speech-server.example/diktafon/upload';
      for (final suffix in [
        '/jobs/abc',
        '/jobs/abc/result',
        '/jobs/abc/cancel',
        '/jobs/abc/retry',
      ]) {
        expect(CloudClient.v1Uri(base, suffix).toString(),
            'https://speech-server.example/diktafon/v1$suffix',
            reason: suffix);
      }
    });

    test('endpoints without /upload still resolve under /v1', () {
      expect(
        CloudClient.v1Uri('https://speech-server.example/diktafon', '/jobs/abc')
            .toString(),
        'https://speech-server.example/diktafon/v1/jobs/abc',
      );
    });

    test('query and port survive', () {
      expect(
        CloudClient.v1Uri('http://localhost:8378/diktafon/upload', '/jobs/abc')
            .toString(),
        'http://localhost:8378/diktafon/v1/jobs/abc',
      );
    });
  });
}
