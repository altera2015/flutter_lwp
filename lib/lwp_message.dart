part of flutter_lwp;

abstract class Message {
  int hubId;
  MessageType messageType;

  Message({required this.messageType, this.hubId = 0x00});

  List<int> encode() {
    List<int> data = _encode();
    int length = data.length + 3;
    if (length >= 127) {
      throw UnimplementedError();
    }
    List<int> message = [length, hubId, messageType.value];
    message.addAll(data);
    return message;
  }

  List<int> _encode();

  static Message factory(List<int> data) {
    if (data.length < 3) {
      throw Exception("Data too short.");
    }

    MessageType type = MessageTypeValue.fromInt(data[2]);
    int headerLength = 3;
    switch (type) {
      case MessageType.HubProperties:
        return HubPropertyMessage.decode(data, headerLength);
      case MessageType.HubAttachedIO:
        return HubAttachedIOBaseMessage.decode(data, headerLength);
      case MessageType.GenericErrorMessages:
        return ErrorMessage.decode(data, headerLength);
      case MessageType.PortOutputCommand:
        return PortOutputCommandMessage.decode(data, headerLength);
      case MessageType.PortInformationRequest:
        return PortInformationRequestMessage.decode(data, headerLength);
      case MessageType.PortInformation:
        return PortInformationMessage.decode(data, headerLength);
      case MessageType.PortModeInformationRequest:
        return PortModeInformationMessageRequest.decode(data, headerLength);
      case MessageType.PortModeInformation:
        return PortModeInformationMessage.decode(data, headerLength);
      case MessageType.PortInputFormatSetup:
        return PortInputFormatSetupMessage.decode(data, headerLength);
      case MessageType.PortInputFormat:
        return PortInputFormatMessage.decode(data, headerLength);
      case MessageType.PortOutputCommandFeedback:
        return PortOutputCommandFeedback.decode(data, headerLength);
      case MessageType.PortValue:
        return PortValueMessage.decode(data, headerLength);
      default:
        throw Exception("$type not yet implemented");
    }
  }
}

class EmptyMessage extends Message {
  EmptyMessage() : super(messageType: MessageType.Empty);

  List<int> _encode() {
    return [];
  }

  String toString() {
    return "Empty";
  }
}
