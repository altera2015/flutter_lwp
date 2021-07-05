part of flutter_lwp;

class PortModeInformationMessageRequest extends Message {
  final int portId;
  final int mode;
  final PortModeInformationType informationType;

  PortModeInformationMessageRequest(this.portId, this.mode, this.informationType) : super(messageType: MessageType.PortModeInformationRequest);

  @override
  List<int> _encode() {
    return [portId, mode, informationType.value];
  }

  factory PortModeInformationMessageRequest.decode(List<int> data, int offset) {
    if (data.length - offset < 3) {
      throw Exception("Not enough data");
    }

    int portId = data[offset];
    int mode = data[offset + 1];
    PortModeInformationType informationType = PortModeInformationTypeValue.fromInt(data[offset + 2]);

    return PortModeInformationMessageRequest(portId, mode, informationType);
  }

  String toString() {
    return "PortModeInformationMessageRequest Message: port=$portId, informationType=$informationType";
  }
}
