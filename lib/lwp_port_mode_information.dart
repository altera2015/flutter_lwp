part of flutter_lwp;

/// Information about port modes.
/// {@category messages}
class PortModeInformationMessage extends Message {
  final int portId;
  final int mode;
  final PortModeInformationType informationType;

  PortModeInformationMessage(this.portId, this.mode, this.informationType) : super(messageType: MessageType.PortModeInformation);

  @override
  List<int> _encode() {
    return [portId, mode, informationType.value];
  }

  factory PortModeInformationMessage.decode(List<int> data, int offset) {
    if (data.length - offset < 3) {
      throw Exception("Not enough data");
    }

    int portId = data[offset];
    int mode = data[offset + 1];
    PortModeInformationType informationType = PortModeInformationTypeValue.fromInt(data[offset + 2]);

    switch (informationType) {
      case PortModeInformationType.NAME:
        Helper.dumpData(data.sublist(offset + 3));
        return PortModeInformationMessageNAME(portId, mode, informationType, Helper.decodeStr(data, offset + 3));
      case PortModeInformationType.SYMBOL:
        return PortModeInformationMessageSYMBOL(portId, mode, informationType, Helper.decodeStr(data, offset + 3));
      case PortModeInformationType.RAW:
        return PortModeInformationMessageRAW(portId, mode, informationType, Helper.decodeFloat32(data, offset + 3), Helper.decodeFloat32(data, offset + 7));
      case PortModeInformationType.PCT:
        return PortModeInformationMessagePCT(portId, mode, informationType, Helper.decodeFloat32(data, offset + 3), Helper.decodeFloat32(data, offset + 7));
      case PortModeInformationType.SI:
        return PortModeInformationMessageSI(portId, mode, informationType, Helper.decodeFloat32(data, offset + 3), Helper.decodeFloat32(data, offset + 7));
      case PortModeInformationType.MOTOR_BIAS:
        return PortModeInformationMessageMotorBias(portId, mode, informationType, data[offset + 3]);
      default:
        throw Exception("Unsupported information type $informationType");
    }
  }
}

/// {@category messages}
class PortModeInformationMessageNAME extends PortModeInformationMessage {
  final String name;

  PortModeInformationMessageNAME(int portId, int mode, PortModeInformationType informationType, this.name) : super(portId, mode, informationType);

  @override
  List<int> _encode() {
    return super._encode()..addAll(Helper.encodeStr(name));
  }

  String toString() {
    return "PortModeInformationMessageNAME Message: port=$portId, informationType=$informationType, mode=$mode, name=$name";
  }
}

/// {@category messages}
class PortModeInformationMessageSYMBOL extends PortModeInformationMessageNAME {
  PortModeInformationMessageSYMBOL(int portId, int mode, PortModeInformationType informationType, String name) : super(portId, mode, informationType, name);

  String toString() {
    return "PortModeInformationMessageSYMBOL Message: port=$portId, informationType=$informationType, mode=$mode, symbol=$name";
  }
}

/// {@category messages}
class PortModeInformationMessageRAW extends PortModeInformationMessage {
  final double minimum;
  final double maximum;

  PortModeInformationMessageRAW(int portId, int mode, PortModeInformationType informationType, this.minimum, this.maximum)
      : super(portId, mode, informationType);

  @override
  List<int> _encode() {
    return super._encode()..addAll([...Helper.encodeFloat32(minimum), ...Helper.encodeFloat32(maximum)]);
  }

  String toString() {
    return "PortModeInformationMessageRAW Message: port=$portId, informationType=$informationType, mode=$mode, minimum=$minimum, maximum=$maximum";
  }
}

/// {@category messages}
class PortModeInformationMessagePCT extends PortModeInformationMessageRAW {
  PortModeInformationMessagePCT(int portId, int mode, PortModeInformationType informationType, double minimum, double maximum)
      : super(portId, mode, informationType, minimum, maximum);

  String toString() {
    return "PortModeInformationMessagePCT Message: port=$portId, informationType=$informationType, mode=$mode, minimum=$minimum, maximum=$maximum";
  }
}

/// {@category messages}
class PortModeInformationMessageSI extends PortModeInformationMessageRAW {
  PortModeInformationMessageSI(int portId, int mode, PortModeInformationType informationType, double minimum, double maximum)
      : super(portId, mode, informationType, minimum, maximum);

  String toString() {
    return "PortModeInformationMessageSI Message: port=$portId, informationType=$informationType, mode=$mode, minimum=$minimum, maximum=$maximum";
  }
}

/// {@category messages}
class PortModeInformationMessageMotorBias extends PortModeInformationMessage {
  final int bias;

  PortModeInformationMessageMotorBias(int portId, int mode, PortModeInformationType informationType, this.bias) : super(portId, mode, informationType);

  @override
  List<int> _encode() {
    return super._encode()..addAll([bias]);
  }

  String toString() {
    return "PortModeInformationMessageMotorBias Message: port=$portId, informationType=$informationType, mode=$mode, bias=$bias";
  }
}
