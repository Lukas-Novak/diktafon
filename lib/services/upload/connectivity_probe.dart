/// Connectivity probing behind tiny closure seams, so the job queue stays
/// plugin-free and unit-testable (`hasConnectivity` / `isUnmetered` are
/// injected there; production wires this probe in providers.dart).
library;

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityProbe {
  ConnectivityProbe([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// Wi-Fi, ethernet, VPN and mobile all count as connectivity.
  Future<bool> hasConnectivity() async =>
      (await _connectivity.checkConnectivity())
          .any((r) => r != ConnectivityResult.none);

  /// Unmetered per the OS: Wi-Fi and ethernet.
  Future<bool> isUnmetered() async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet);
  }

  /// Emits on connectivity transitions; [hasUnmeteredGain] filters them into
  /// "upload may proceed now" signals for the queue.
  Stream<bool> get uploadOpportunities => _connectivity.onConnectivityChanged
      .map((results) => results.any((r) => r != ConnectivityResult.none))
      .distinct();

  /// Whether an upload may start right now given the Wi-Fi-only preference.
  Future<bool> mayUpload({required bool wifiOnly}) async {
    final results = await _connectivity.checkConnectivity();
    if (!results.any((r) => r != ConnectivityResult.none)) return false;
    if (!wifiOnly) return true;
    return results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet);
  }

  /// Emits true whenever uploads with the given preference become possible.
  Stream<bool> uploadOpportunitiesFor(bool wifiOnly) =>
      _connectivity.onConnectivityChanged.map((results) {
        if (!results.any((r) => r != ConnectivityResult.none)) return false;
        if (!wifiOnly) return true;
        return results.contains(ConnectivityResult.wifi) ||
            results.contains(ConnectivityResult.ethernet);
      }).distinct();
}
