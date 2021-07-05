part of flutter_lwp;

class ErrorMessage extends Message {
  MessageType errorType;
  ErrorCode errorCode;

  ErrorMessage(this.errorType, this.errorCode) : super(messageType: MessageType.GenericErrorMessages);

  @override
  List<int> _encode() {
    return [errorType.value, errorCode.value];
  }

  factory ErrorMessage.decode(List<int> data, int offset) {
    if (data.length - offset < 2) {
      throw Exception("Not enough data");
    }
    MessageType errorType = MessageTypeValue.fromInt(data[offset]);
    ErrorCode errorCode = ErrorCodeValue.fromInt(data[offset + 1]);
    return ErrorMessage(errorType, errorCode);
  }

  String toString() {
    return "ErrorMessage Message: type=$errorType, error=$errorCode";
  }
}
