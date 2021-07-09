part of flutter_lwp;

/// {@category messages}
class PortValueMessage extends Message {
  final int portId;
  final List<int> value;

  PortValueMessage(this.portId, this.value) : super(messageType: MessageType.PortValue);

  @override
  List<int> _encode() {
    return [portId, ...value];
  }

  factory PortValueMessage.decode(List<int> data, int offset) {
    if (data.length - offset < 2) {
      throw Exception("Not enough data");
    }

    int portId = data[offset];
    return PortValueMessage(portId, data.sublist(offset + 1));
  }

  String toString() {
    return "PortValueMessage Message: port=$portId value=${Helper.toHex(value)}";
  }
}
