part of flutter_lwp;

class PortInformationMessage extends Message {
  final int portId;
  final PortInformationRequestType informationType;

  PortInformationMessage(this.portId, this.informationType) : super(messageType: MessageType.PortInformation);

  @override
  List<int> _encode() {
    return [portId, informationType.value];
  }

  factory PortInformationMessage.decode(List<int> data, int offset) {
    if (data.length - offset < 2) {
      throw Exception("Not enough data");
    }
    int portId = data[offset];
    PortInformationRequestType informationType = PortInformationRequestTypeValue.fromInt(data[offset + 1]);
    List<PortCapabilities> capabilities = [];

    if (informationType == PortInformationRequestType.ModeInfo) {
      if (data.length - offset < 8) {
        throw Exception("Not enough data");
      }

      int cap = data[offset + 2];
      PortCapabilities.values.forEach((element) {
        if (cap & (1 << element.index) != 0) {
          capabilities.add(element);
        }
      });
      int modeCount = data[offset + 3];
      int inputModes = Helper.decodeInt16LE(data, offset + 4);
      int outputModes = Helper.decodeInt16LE(data, offset + 6);

      return PortInformationModesMessage(portId, capabilities, modeCount, inputModes, outputModes);
    }

    if (informationType == PortInformationRequestType.ModeCombinations) {
      List<int> combinations = data.sublist(offset + 2);
      return PortInformationModeCombinationsMessage(portId, combinations);
    }

    throw Exception("Unsupported informationRequestType $informationType}");
  }

  String toString() {
    return "PortInformationMessage Message: port=$portId, informationType=$informationType";
  }
}

class PortInformationModesMessage extends PortInformationMessage {
  final List<PortCapabilities> capabilities;
  final int modeCount;
  final int inputModes;
  final int outputModes;

  PortInformationModesMessage(int portId, this.capabilities, this.modeCount, this.inputModes, this.outputModes)
      : super(portId, PortInformationRequestType.ModeInfo);

  @override
  List<int> _encode() {
    int cap = 0;
    capabilities.forEach((element) {
      cap |= 1 << element.index;
    });

    return super._encode()..addAll([cap, modeCount, inputModes, outputModes]);
  }

  List<int> get inputModeList {
    List<int> l = [];
    for (int i = 0; i < 16; i++) {
      if ((inputModes & (1 << i)) != 0) {
        l.add(i);
      }
    }
    return l;
  }

  List<int> get outputModeList {
    List<int> l = [];
    for (int i = 0; i < 16; i++) {
      if ((outputModes & (1 << i)) != 0) {
        l.add(i);
      }
    }
    return l;
  }

  String toString() {
    return "PortInformationModesMessage Message: port=$portId, informationType=$informationType, cap=$capabilities, cnt=$modeCount, in=$inputModes out=$outputModes";
  }
}

class PortInformationModeCombinationsMessage extends PortInformationMessage {
  final List<int> combinations;

  PortInformationModeCombinationsMessage(int portId, this.combinations) : super(portId, PortInformationRequestType.ModeCombinations);

  @override
  List<int> _encode() {
    return super._encode()..addAll(combinations);
  }

  String toString() {
    return "PortInformationModeCombinationsMessage Message: port=$portId, informationType=$informationType, combinations=$combinations";
  }
}
