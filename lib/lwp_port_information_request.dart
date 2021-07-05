part of flutter_lwp;

class PortInformationRequestMessage extends Message {
  int portId;
  PortInformationRequestType informationType;

  PortInformationRequestMessage(this.portId, this.informationType) : super(messageType: MessageType.PortInformationRequest);

  @override
  List<int> _encode() {
    return [portId, informationType.value];
  }

  factory PortInformationRequestMessage.decode(List<int> data, int offset) {
    if (data.length - offset < 2) {
      throw Exception("Not enough data");
    }
    int portId = data[offset];
    PortInformationRequestType informationType = PortInformationRequestTypeValue.fromInt(data[offset + 1]);
    return PortInformationRequestMessage(portId, informationType);
  }

  String toString() {
    return "PortInformationRequestMessage Message: port=$portId, informationType=$informationType";
  }
}
