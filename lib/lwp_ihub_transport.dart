part of flutter_lwp;

/// HUB Transport interface
///
/// {@category backend}
abstract class IHubTransport {
  /// transmit places the message on the wire immediately
  Future<bool> transmit(Message msg);

  /// returns the name of the hub
  String get name;

  /// returns the id of the hub
  String get id;

  /// Initiates the connection to the hub.
  Future<bool> connect();

  /// Disconnect from the hub.
  Future<void> disconnect();

  /// Broadcast stream of messages coming from the hub hardware.
  Stream<Message> get stream;

  /// call when done with
  void dispose();
}
