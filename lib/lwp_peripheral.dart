part of flutter_lwp;

class PeripheralModeRange {
  double min = 0.0;
  double max = 1.0;
}

class PeripheralMode {
  final int modeId;
  final bool inputMode;
  String name = "";
  String symbol = "";

  PeripheralModeRange rawRange = PeripheralModeRange();
  String toString() {
    return "$modeId, $name $symbol rawRange=(${rawRange.min}-${rawRange.max})";
  }

  PeripheralMode(this.modeId, this.inputMode);

  Map<String, Object> toJsonObject() {
    return {
      "name": name,
      "symbol": symbol,
      "rawRange": {"min": rawRange.min, "max": rawRange.max}
    };
  }
}

mixin Motor on Peripheral {
  Future<bool> startSpeed(int speed, int maxPower, MotorAccelerationProfile useProfile) async {
    SimpleTransaction<PortOutputCommandFeedback> tx = SimpleTransaction<PortOutputCommandFeedback>(
        msgToSend: StartSpeedMessage(portId, PortOutputStartup.BufferIfNeeded, PortOutputCompletion.Feedback, speed, maxPower, useProfile));
    PortOutputCommandFeedback? msg = await tx.queue(hub);
    if (msg == null) {
      return false;
    }
    print("startSpeed got $msg");
    return true;
  }

  Future<bool> startSpeedForDegrees(int degrees, int speed, int maxPower, MotorEndState endState, MotorAccelerationProfile useProfile) async {
    SimpleTransaction<PortOutputCommandFeedback> tx = SimpleTransaction<PortOutputCommandFeedback>(
        msgToSend: StartSpeedForDegreesMessage(
            portId, PortOutputStartup.BufferIfNeeded, PortOutputCompletion.Feedback, degrees, speed, maxPower, endState, useProfile));
    PortOutputCommandFeedback? msg = await tx.queue(hub);
    if (msg == null) {
      return false;
    }
    print("startSpeedForDegrees got $msg");
    return true;
  }

  Future<bool> gotoAbsolutePosition(int absolutePosition, int speed, int maxPower, MotorEndState endState, MotorAccelerationProfile useProfile) async {
    SimpleTransaction<PortOutputCommandFeedback> tx = SimpleTransaction<PortOutputCommandFeedback>(
        msgToSend: GotoAbsolutePositionMessage(
            portId, PortOutputStartup.BufferIfNeeded, PortOutputCompletion.Feedback, absolutePosition, speed, maxPower, endState, useProfile));
    PortOutputCommandFeedback? msg = await tx.queue(hub);
    if (msg == null) {
      return false;
    }
    print("gotoAbsolutePosition got $msg");
    return true;
  }
}

class Peripheral {
  final IHub hub;
  final HubAttachedIOMessage attachedIO;

  PortInformationModesMessage? _modeInfo;
  Map<int, PeripheralMode> _inputModes = {};
  Map<int, PeripheralMode> _outputModes = {};

  factory Peripheral.factory(IHub hub, HubAttachedIOMessage attachedIO) {
    switch (attachedIO.ioType) {
      case IOType.Motor:
      case IOType.LargeMotor:
      case IOType.XLargeMotor:
        return MotorPeripheral(hub, attachedIO);
      default:
        return Peripheral(hub, attachedIO);
    }
  }

  Peripheral(
    this.hub,
    this.attachedIO,
  ) {
    print("Peripheral added $attachedIO");
  }

  int get portId {
    return attachedIO.portId;
  }

  Future<PeripheralMode?> _queryMode(int portId, int modeId, bool inputMode) async {
    PeripheralMode m = PeripheralMode(modeId, true);

    {
      PortModeInformationMessageNAME? msg =
          await SimpleTransaction<PortModeInformationMessageNAME>(msgToSend: PortModeInformationMessageRequest(portId, modeId, PortModeInformationType.NAME))
              .queue(hub);
      if (msg == null) {
        return null;
      }
      print("interrogate got $msg");
      m.name = msg.name;
    }

    {
      SimpleTransaction<PortModeInformationMessageSYMBOL> tx =
          SimpleTransaction<PortModeInformationMessageSYMBOL>(msgToSend: PortModeInformationMessageRequest(portId, modeId, PortModeInformationType.SYMBOL));
      PortModeInformationMessageSYMBOL? msg = await tx.queue(hub);
      if (msg == null) {
        return null;
      }
      print("interrogate got $msg");
      m.symbol = msg.name;
    }

    {
      SimpleTransaction<PortModeInformationMessageRAW> tx =
          SimpleTransaction<PortModeInformationMessageRAW>(msgToSend: PortModeInformationMessageRequest(portId, modeId, PortModeInformationType.RAW));
      PortModeInformationMessageRAW? msg = await tx.queue(hub);
      if (msg == null) {
        return null;
      }
      print("interrogate got $msg");
      m.rawRange.min = msg.minimum;
      m.rawRange.max = msg.maximum;
    }

    return m;
  }

  Future<void> interrogate() async {
    print("Sending info request, wait...");

    _modeInfo = await hub.queue(
        SimpleTransaction<PortInformationModesMessage>(msgToSend: PortInformationRequestMessage(attachedIO.portId, PortInformationRequestType.ModeInfo)));

    if (_modeInfo == null) {
      print("Failed to fully query.");
      return;
    }

    for (int mode in _modeInfo!.inputModeList) {
      print("Sending get name for mode $mode on port ${_modeInfo!.portId}");
      PeripheralMode? m = await _queryMode(_modeInfo!.portId, mode, true);
      if (m != null) {
        _inputModes[mode] = m;
      } else {
        print("Failed to fully query input mode $mode on port ${_modeInfo!.portId}");
      }
    }

    for (int mode in _modeInfo!.outputModeList) {
      print("Sending get name for mode $mode on port ${_modeInfo!.portId}");
      PeripheralMode? m = await _queryMode(_modeInfo!.portId, mode, false);
      if (m != null) {
        _outputModes[mode] = m;
      } else {
        print("Failed to fully query output mode $mode on port ${_modeInfo!.portId}");
      }
    }
  }

  void dispose() {}

  Map<String, Object> toJsonObject() {
    Map<String, Object> map = {};
    if (_modeInfo != null) {
      map["type"] = attachedIO.ioType.toString();
      map["hardwareRevision"] = attachedIO.hardwareRevision;
      map["softwareRevision"] = attachedIO.softwareRevision;
      map["portId"] = _modeInfo!.portId;
      map["capabilities"] = _modeInfo!.capabilities.map((e) => e.toString()).toList();
      Map<String, Object> inputModeMap = {};
      _inputModes.forEach((modeId, value) {
        inputModeMap[modeId.toString()] = value.toJsonObject();
      });
      map["inputModes"] = inputModeMap;
      Map<String, Object> outputModeMap = {};
      _outputModes.forEach((modeId, value) {
        outputModeMap[modeId.toString()] = value.toJsonObject();
      });
      map["outputModes"] = outputModeMap;
    }
    return map;
  }

  Future<bool> setInputMode(int mode, int delta, bool notificationEnabled) async {
    SimpleTransaction<PortInputFormatMessage> tx =
        SimpleTransaction<PortInputFormatMessage>(msgToSend: PortInputFormatSetupMessage(portId, mode, delta, notificationEnabled));
    PortInputFormatMessage? msg = await tx.queue(hub);
    if (msg == null) {
      return false;
    }
    print("setInputMode got $msg");
    return (msg.delta == delta) && (msg.mode == mode) && (msg.notificationEnabled == notificationEnabled);
  }
}

class MotorPeripheral extends Peripheral with Motor {
  MotorPeripheral(IHub hub, HubAttachedIOMessage attachedIO) : super(hub, attachedIO);
}
