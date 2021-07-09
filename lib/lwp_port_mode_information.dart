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
        return PortModeInformationMessageNAME(portId, mode, Helper.decodeStr(data, offset + 3));
      case PortModeInformationType.SYMBOL:
        return PortModeInformationMessageSYMBOL(portId, mode, Helper.decodeStr(data, offset + 3));
      case PortModeInformationType.RAW:
        return PortModeInformationMessageRAW(portId, mode, Helper.decodeFloat32(data, offset + 3), Helper.decodeFloat32(data, offset + 7));
      case PortModeInformationType.PCT:
        return PortModeInformationMessagePCT(portId, mode, Helper.decodeFloat32(data, offset + 3), Helper.decodeFloat32(data, offset + 7));
      case PortModeInformationType.SI:
        return PortModeInformationMessageSI(portId, mode, Helper.decodeFloat32(data, offset + 3), Helper.decodeFloat32(data, offset + 7));
      case PortModeInformationType.MOTOR_BIAS:
        return PortModeInformationMessageMotorBias(portId, mode, data[offset + 3]);
      case PortModeInformationType.VALUE_FORMAT:
        return PortModeInformationMessageValueFormat(portId, mode, ValueFormat.decode(data, offset + 3));
      default:
        throw Exception("Unsupported information type $informationType");
    }
  }
}

/// {@category messages}
class PortModeInformationMessageNAME extends PortModeInformationMessage {
  final String name;

  PortModeInformationMessageNAME(int portId, int mode, this.name) : super(portId, mode, PortModeInformationType.NAME);

  @override
  List<int> _encode() {
    return super._encode()..addAll(Helper.encodeStr(name));
  }

  String toString() {
    return "PortModeInformationMessageNAME Message: port=$portId, informationType=$informationType, mode=$mode, name=$name";
  }
}

/// {@category messages}
class PortModeInformationMessageSYMBOL extends PortModeInformationMessage {
  final String symbol;

  PortModeInformationMessageSYMBOL(int portId, int mode, this.symbol) : super(portId, mode, PortModeInformationType.SYMBOL);

  @override
  List<int> _encode() {
    return super._encode()..addAll(Helper.encodeStr(symbol));
  }

  String toString() {
    return "PortModeInformationMessageSYMBOL Message: port=$portId, informationType=$informationType, mode=$mode, symbol=$symbol";
  }
}

/// {@category messages}
class PortModeInformationMessageRAWBase extends PortModeInformationMessage {
  final double minimum;
  final double maximum;

  PortModeInformationMessageRAWBase(int portId, int mode, PortModeInformationType pi, this.minimum, this.maximum) : super(portId, mode, pi);

  @override
  List<int> _encode() {
    return super._encode()..addAll([...Helper.encodeFloat32(minimum), ...Helper.encodeFloat32(maximum)]);
  }

  String toString() {
    return "${informationType.toString()} Message: port=$portId, informationType=$informationType, mode=$mode, minimum=$minimum, maximum=$maximum";
  }
}

class PortModeInformationMessageRAW extends PortModeInformationMessageRAWBase {
  PortModeInformationMessageRAW(int portId, int mode, double minimum, double maximum) : super(portId, mode, PortModeInformationType.RAW, minimum, maximum);
}

/// {@category messages}
class PortModeInformationMessagePCT extends PortModeInformationMessageRAWBase {
  PortModeInformationMessagePCT(int portId, int mode, double minimum, double maximum) : super(portId, mode, PortModeInformationType.PCT, minimum, maximum);

  String toString() {
    return "PortModeInformationMessagePCT Message: port=$portId, informationType=$informationType, mode=$mode, minimum=$minimum, maximum=$maximum";
  }
}

/// {@category messages}
class PortModeInformationMessageSI extends PortModeInformationMessageRAWBase {
  PortModeInformationMessageSI(int portId, int mode, double minimum, double maximum) : super(portId, mode, PortModeInformationType.SI, minimum, maximum);

  String toString() {
    return "PortModeInformationMessageSI Message: port=$portId, informationType=$informationType, mode=$mode, minimum=$minimum, maximum=$maximum";
  }
}

/// {@category messages}
class PortModeInformationMessageMotorBias extends PortModeInformationMessage {
  final int bias;

  PortModeInformationMessageMotorBias(int portId, int mode, this.bias) : super(portId, mode, PortModeInformationType.MOTOR_BIAS);

  @override
  List<int> _encode() {
    return super._encode()..addAll([bias]);
  }

  String toString() {
    return "PortModeInformationMessageMotorBias Message: port=$portId, informationType=$informationType, mode=$mode, bias=$bias";
  }
}

/// https://lego.github.io/lego-ble-wireless-protocol-docs/index.html#value-format
/// {@category messages}
enum ValueFormatDataType { EightBit, SixteenBit, ThirtyTwoBit, Float }

/// https://lego.github.io/lego-ble-wireless-protocol-docs/index.html#value-format
/// {@category messages}
class ValueFormat {
  final int datasetCount;
  final ValueFormatDataType dataType;
  final int totalFigures;
  final int decimals;

  ValueFormat(this.datasetCount, this.dataType, this.totalFigures, this.decimals);

  factory ValueFormat.decode(List<int> data, offset) {
    int datasetCount = data[offset];
    ValueFormatDataType dataType = ValueFormatDataType.values[data[offset + 1] & 3];
    int totalFigures = data[offset + 2];
    int decimals = data[offset + 3];
    return ValueFormat(datasetCount, dataType, totalFigures, decimals);
  }

  List<int> encode() {
    return [datasetCount, dataType.index, totalFigures, decimals];
  }

  Map<String, dynamic> toJSON() {
    return {"datasetCount": datasetCount, "dataType": dataType.toString(), "totalFigures": totalFigures, "decimals": decimals};
  }

  String toString() {
    return "ValueFormat: count=$datasetCount, dataType=${dataType.toString()}, figures=$totalFigures decimals=$decimals";
  }
}

/// https://lego.github.io/lego-ble-wireless-protocol-docs/index.html#value-format
/// {@category messages}
class PortModeInformationMessageValueFormat extends PortModeInformationMessage {
  final ValueFormat valueFormat;

  PortModeInformationMessageValueFormat(int portId, int mode, this.valueFormat) : super(portId, mode, PortModeInformationType.VALUE_FORMAT);

  @override
  List<int> _encode() {
    return super._encode()..addAll([...valueFormat.encode()]);
  }

  String toString() {
    return "PortModeInformationMessageValueFormat Message: port=$portId, informationType=$informationType, mode=$mode, valueFormat=($valueFormat)";
  }
}
