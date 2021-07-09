part of flutter_lwp;

/// Range container.
/// {@category API}
class PeripheralModeRange {
  double min = 0.0;
  double max = 1.0;
}

/// Mode container
/// {@category API}
class PeripheralMode {
  final int modeId;
  final bool inputMode;

  String name = "";
  String symbol = "";
  ValueFormat valueFormat = ValueFormat(0, ValueFormatDataType.EightBit, 0, 0);

  PeripheralModeRange rawRange = PeripheralModeRange();
  String toString() {
    return "$modeId, $name $symbol rawRange=(${rawRange.min}-${rawRange.max}, valueFormat=$valueFormat)";
  }

  PeripheralMode(this.modeId, this.inputMode);

  Map<String, Object> toJsonObject() {
    return {
      "name": name,
      "symbol": symbol,
      "rawRange": {"min": rawRange.min, "max": rawRange.max},
      "valueFormat": valueFormat.toJSON()
    };
  }
}

/// Master Peripheral class.
///
/// Mixins are used to extend the capabilities of each peripheral to
/// expose it's functionality.
///
/// {@category API}
class Peripheral {
  final Hub hub;
  final HubAttachedIOMessage attachedIO;

  PortInformationModesMessage? _modeInfo;
  Map<int, PeripheralMode> _inputModes = {};
  Map<int, PeripheralMode> _outputModes = {};

  /// factory method to create peripherals depending
  /// on the [IOType].
  factory Peripheral.factory(Hub hub, HubAttachedIOMessage attachedIO) {
    switch (attachedIO.ioType) {
      case IOType.HubStatusLight:
        return HubStatusLightPeripheral(hub, attachedIO);
      case IOType.Motor:
      case IOType.LargeMotor:
      case IOType.XLargeMotor:
        return MotorPeripheral(hub, attachedIO);
      default:
        return Peripheral(hub, attachedIO);
    }
  }

  /// constructor for peripheral. Typically you'll want to use the
  /// factory constructor to ensure the correct mixins are
  /// loaded for each [IOType].
  Peripheral(
    this.hub,
    this.attachedIO,
  ) {
    print("Peripheral added $attachedIO");
  }

  /// Returns the portId this peripheral is attached to.
  ///
  /// Port Id | Description
  /// ---------------------
  /// 0-15    | External ports
  /// 16-49   | Hub Connectors
  /// 50-100  | Internal Ports
  /// 101-255 | Reserved.
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
      Helper.dprint("interrogate got $msg");
      m.name = msg.name;
    }

    {
      SimpleTransaction<PortModeInformationMessageSYMBOL> tx =
          SimpleTransaction<PortModeInformationMessageSYMBOL>(msgToSend: PortModeInformationMessageRequest(portId, modeId, PortModeInformationType.SYMBOL));
      PortModeInformationMessageSYMBOL? msg = await tx.queue(hub);
      if (msg == null) {
        return null;
      }
      Helper.dprint("interrogate got $msg");
      m.symbol = msg.symbol;
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

    {
      SimpleTransaction<PortModeInformationMessageValueFormat> tx = SimpleTransaction<PortModeInformationMessageValueFormat>(
          msgToSend: PortModeInformationMessageRequest(portId, modeId, PortModeInformationType.VALUE_FORMAT));
      PortModeInformationMessageValueFormat? msg = await tx.queue(hub);
      if (msg == null) {
        return null;
      }
      Helper.dprint("interrogate got $msg");
      m.valueFormat = msg.valueFormat;
    }

    return m;
  }

  /// Interrogate the port for all its characteristics.
  /// including input and output modes.
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

  /// call this to dispose of the peripheral when no longer needed.
  void dispose() {}

  /// Provide a JSON suitable object for long term storage of the
  /// peripheral characteristics. Can be used to shorted startup time as a
  /// cache.
  Map<String, Object> toJsonObject() {
    Map<String, Object> map = {};
    if (_modeInfo != null) {
      map["type"] = attachedIO.ioType.toString();
      map["hardwareRevision"] = attachedIO.hardwareRevision.toString();
      map["softwareRevision"] = attachedIO.softwareRevision.toString();
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

  /// Sets a peripheral mode into notification mode.
  ///
  /// if enable the peripheral will send out a [PortValueMessage] whenever
  /// its value changes by delta or more. Considering the bandwidth limitations
  /// of the backend it might not be wise to select a low delta.
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

/// LED actions for Peripherals.
/// {@category API}
mixin Led on Peripheral {
  /// Sets the LED color.
  Future<bool> setColor(int mode, int color) async {
    SimpleTransaction<PortOutputCommandFeedback> tx = SimpleTransaction<PortOutputCommandFeedback>(
        msgToSend: WriteDirectModeDataMessage(portId, PortOutputStartup.BufferIfNeeded, PortOutputCompletion.Feedback, mode, [color]));
    PortOutputCommandFeedback? msg = await tx.queue(hub);
    if (msg == null) {
      return false;
    }
    return true;
  }

  /// Sets the LED RGB color.
  ///
  /// Note this doesn't (currently?) work for hub 2.0
  Future<bool> setRGBColor(int mode, int r, int g, int b) async {
    SimpleTransaction<PortOutputCommandFeedback> tx = SimpleTransaction<PortOutputCommandFeedback>(
        msgToSend: WriteDirectModeDataMessage(portId, PortOutputStartup.BufferIfNeeded, PortOutputCompletion.Feedback, mode, [r, g, b]));
    PortOutputCommandFeedback? msg = await tx.queue(hub);
    if (msg == null) {
      return false;
    }
    return true;
  }
}

/// MotorPeripheral class using [Motor] mixin.
/// {@category API}
class MotorPeripheral extends Peripheral with Motor {
  MotorPeripheral(Hub hub, HubAttachedIOMessage attachedIO) : super(hub, attachedIO);
}

/// HubPeripheral class using [Led] mixin.
/// {@category API}
class HubStatusLightPeripheral extends Peripheral with Led {
  HubStatusLightPeripheral(Hub hub, HubAttachedIOMessage attachedIO) : super(hub, attachedIO);
}
