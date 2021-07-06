part of flutter_lwp;

/// Port Input format setup message
///
/// Used to setup automatic value reporting from a port.
/// Hub answers with [PortInputFormatMessage]
///
/// {@category messages}
class PortInputFormatSetupMessage extends Message {
  final int portId;
  final int mode;
  final int delta;
  final bool notificationEnabled;

  PortInputFormatSetupMessage(this.portId, this.mode, this.delta, this.notificationEnabled) : super(messageType: MessageType.PortInputFormatSetup);

  @override
  List<int> _encode() {
    return [portId, mode, ...Helper.encodeInt32LE(delta), notificationEnabled ? 1 : 0];
  }

  factory PortInputFormatSetupMessage.decode(List<int> data, int offset) {
    if (data.length - offset < 7) {
      throw Exception("Not enough data");
    }

    int portId = data[offset];
    int mode = data[offset + 1];
    int delta = Helper.decodeInt32LE(data, offset + 2);
    bool notification = data[offset + 6] == 0 ? false : true;

    return PortInputFormatSetupMessage(portId, mode, delta, notification);
  }

  String toString() {
    return "PortInputFormatSetupMessage Message: port=$portId, mode=$mode, delta=$delta, notificationEnabled=$notificationEnabled";
  }
}

/// Port Input format setup message
///
/// {@category messages}
class PortInputFormatMessage extends Message {
  final int portId;
  final int mode;
  final int delta;
  final bool notificationEnabled;

  PortInputFormatMessage(this.portId, this.mode, this.delta, this.notificationEnabled) : super(messageType: MessageType.PortInputFormat);

  @override
  List<int> _encode() {
    return [portId, mode, ...Helper.encodeInt32LE(delta), notificationEnabled ? 1 : 0];
  }

  factory PortInputFormatMessage.decode(List<int> data, int offset) {
    if (data.length - offset < 7) {
      throw Exception("Not enough data");
    }

    int portId = data[offset];
    int mode = data[offset + 1];
    int delta = Helper.decodeInt32LE(data, offset + 2);
    bool notification = data[offset + 6] == 0 ? false : true;

    return PortInputFormatMessage(portId, mode, delta, notification);
  }

  String toString() {
    return "PortInputFormatMessage Message: port=$portId, mode=$mode, delta=$delta, notificationEnabled=$notificationEnabled";
  }
}
