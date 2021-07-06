part of flutter_lwp;

/// The main class used to discover hubs.
///
/// {@category API}
abstract class IHubScanner {
  IHubScanner();

  /// dispose should be called when done with the scanner.
  /// this will also destroy all hubs attached.
  void dispose();

  /// starts scanning for the hub, depending on the backend
  /// implementation. Currently this scans for Bluetooth
  /// hubs.
  void startScanning();

  /// Stop scanning for Hubs.
  void stopScanning();

  /// This stream is updated whenever the list of hubs
  /// changes.
  Stream<HubList> get stream;

  /// The hub list.
  /// This is not a copy of the list so don't modify it.
  HubList get list;

  /// IHubScanner factory. Used to instantiate an
  /// object of IHubScanner depending on what platform
  /// it is running on.
  factory IHubScanner.factory() {
    // only one transport implemented currently.
    return flutter_blue_transport.HubScanner();
  }
}
