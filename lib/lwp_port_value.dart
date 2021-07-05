part of flutter_lwp;

class PortValueMessage extends Message {
  final int portId;
  final int value;

  PortValueMessage(this.portId, this.value) : super(messageType: MessageType.PortValue);

  @override
  List<int> _encode() {
    return [portId, ...Helper.encodeInt32LE(value)];
  }

  factory PortValueMessage.decode(List<int> data, int offset) {
    if (data.length - offset < 2) {
      throw Exception("Not enough data");
    }

    int portId = data[offset];
    int value = 0;
    offset = offset + 1;
    switch (data.length - offset) {
      case 1:
        value = data[offset];
        break;
      case 2:
        value = Helper.decodeInt16LE(data, offset);
        break;
      case 4:
        value = Helper.decodeInt32LE(data, offset);
        break;
      default:
        throw Exception("PortValueMessage: Unexpected data length");
    }
    return PortValueMessage(portId, value);
  }

  String toString() {
    return "PortValueMessage Message: port=$portId value=$value";
  }
}
