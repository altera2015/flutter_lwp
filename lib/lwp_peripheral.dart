part of flutter_lwp;

/// Range container.
/// {@category API}
class PeripheralModeRange {
  double min = 0.0;
  double max = 1.0;

  double get range {
    return (max - min).abs();
  }

  bool equals(PeripheralModeRange other) {
    return (other.min == min) && (other.max == max);
  }
}

/// Mode container
/// {@category API}
class PeripheralMode {
  final int modeId;
  final bool inputMode;

  bool active = false;
  String name = "";
  String symbol = "";
  ValueFormat valueFormat = ValueFormat(0, ValueFormatDataType.EightBit, 0, 0);

  PeripheralModeRange rawRange = PeripheralModeRange();
  PeripheralModeRange siRange = PeripheralModeRange();
  String toString() {
    return "$modeId, $name $symbol rawRange=(${rawRange.min}-${rawRange.max}, valueFormat=$valueFormat)";
  }

  PeripheralMode(this.modeId, this.inputMode);

  Map<String, Object> toJsonObject() {
    return {
      "name": name,
      "symbol": symbol,
      "rawRange": {"min": rawRange.min, "max": rawRange.max},
      "siRange": {"min": siRange.min, "max": siRange.max},
      "valueFormat": valueFormat.toJSON()
    };
  }

  double _toSI(Object raw) {
    double v = 0;
    if (raw is int) {
      v = raw.toDouble();
    } else if (raw is double) {
      v = raw;
    } else {
      throw Exception("unhandled source type");
    }

    if (rawRange.equals(siRange)) {
      return v;
    }

    v = (v - rawRange.min) / rawRange.range; // to PCT
    v = v * siRange.range + siRange.min;
    return v;
  }

  /// decode a data stream according to the Format
  List<double> decode(List<int> data, int offset) {
    List<double> values = [];
    for (int i = 0; i < valueFormat.datasetCount; i++) {
      switch (valueFormat.dataType) {
        case ValueFormatDataType.EightBit:
          values.add(_toSI(data[offset]));
          offset += 1;
          break;
        case ValueFormatDataType.SixteenBit:
          values.add(_toSI(Helper.decodeInt16LE(data, offset)));
          offset += 2;
          break;
        case ValueFormatDataType.ThirtyTwoBit:
          values.add(_toSI(Helper.decodeInt32LE(data, offset)));
          offset += 4;
          break;
        case ValueFormatDataType.Float:
          values.add(_toSI(Helper.decodeFloat32(data, offset)));
          offset += 4;
          break;
      }
    }

    return values;
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
      case IOType.Voltage:
        return VoltagePeripheral(hub, attachedIO);
      case IOType.Current:
        return CurrentPeripheral(hub, attachedIO);
      case IOType.HubStatusLight:
        return HubStatusLightPeripheral(hub, attachedIO);
      case IOType.HubIMUTemperature:
        return TemperaturePeripheral(hub, attachedIO);
      case IOType.HubIMUAccel:
        return AccelerationPeripheral(hub, attachedIO);
      case IOType.HubIMUGyro:
        return GyroPeripheral(hub, attachedIO);
      case IOType.HubIMUOrientation:
        return OrientationPeripheral(hub, attachedIO);
      case IOType.HubIMUGesture:
        return GesturePeripheral(hub, attachedIO);
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
      SimpleTransaction<PortModeInformationMessageSI> tx =
          SimpleTransaction<PortModeInformationMessageSI>(msgToSend: PortModeInformationMessageRequest(portId, modeId, PortModeInformationType.SI));
      PortModeInformationMessageSI? msg = await tx.queue(hub);
      if (msg == null) {
        return null;
      }
      print("interrogate got $msg");
      m.siRange.min = msg.minimum;
      m.siRange.max = msg.maximum;
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
  ///
  /// if onlyMode and inputMode are specified only that mode is loaded.
  Future<void> interrogate({int onlyMode = -1, bool inputMode = false}) async {
    print("Sending info request, wait...");

    _modeInfo = await hub.queue(
        SimpleTransaction<PortInformationModesMessage>(msgToSend: PortInformationRequestMessage(attachedIO.portId, PortInformationRequestType.ModeInfo)));

    if (_modeInfo == null) {
      print("Failed to fully query.");
      return;
    }

    if (onlyMode == -1) {
      for (int mode in _modeInfo!.inputModeList) {
        PeripheralMode? m = await _queryMode(_modeInfo!.portId, mode, true);
        if (m != null) {
          _inputModes[mode] = m;
        } else {
          print("Failed to fully query input mode $mode on port ${_modeInfo!.portId}");
        }
      }

      for (int mode in _modeInfo!.outputModeList) {
        PeripheralMode? m = await _queryMode(_modeInfo!.portId, mode, false);
        if (m != null) {
          _outputModes[mode] = m;
        } else {
          print("Failed to fully query output mode $mode on port ${_modeInfo!.portId}");
        }
      }
    } else {
      if (inputMode) {
        PeripheralMode? m = await _queryMode(_modeInfo!.portId, onlyMode, true);
        if (m != null) {
          _inputModes[onlyMode] = m;
        } else {
          print("Failed to fully query input mode $onlyMode on port ${_modeInfo!.portId}");
        }
      } else {
        PeripheralMode? m = await _queryMode(_modeInfo!.portId, onlyMode, false);
        if (m != null) {
          _outputModes[onlyMode] = m;
        } else {
          print("Failed to fully query input mode $onlyMode on port ${_modeInfo!.portId}");
        }
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
    if (!_inputModes.containsKey(mode)) {
      await interrogate(onlyMode: mode, inputMode: true);
    }

    if (!_inputModes.containsKey(mode)) {
      print("Unsupported mode selected");
      return false;
    }

    SimpleTransaction<PortInputFormatMessage> tx =
        SimpleTransaction<PortInputFormatMessage>(msgToSend: PortInputFormatSetupMessage(portId, mode, delta, notificationEnabled));
    PortInputFormatMessage? msg = await tx.queue(hub);
    if (msg == null) {
      return false;
    }
    print("setInputMode got $msg");
    bool v = (msg.delta == delta) && (msg.mode == mode) && (msg.notificationEnabled == notificationEnabled);

    _inputModes.forEach((key, value) {
      value.active = key == mode ? v : false;
    });
    return v;
  }

  bool inputModeActive(int mode) {
    if (_inputModes.containsKey(mode)) {
      return _inputModes[mode]!.active;
    } else {
      return false;
    }
  }

  Future<PeripheralMode> getModeFor(String name) async {
    if (_modeInfo == null) {
      await interrogate();
    }
    if (_modeInfo == null) {
      throw Exception("Unable to interrogate");
    }

    PeripheralMode? pMode;

    _inputModes.forEach((int mode, PeripheralMode info) {
      if (info.name == name) {
        pMode = info;
      }
    });
    if (pMode != null) {
      return pMode!;
    } else {
      throw "Unable to find mode $name";
    }
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

/// Voltage input for Peripherals.
/// {@category API}
mixin VoltageInput on Peripheral {
  /// Gets the voltage of the battery.
  Future<double> getVoltage() async {
    PeripheralMode mode = await getModeFor("VLT L");

    // make sure it's active!
    if (!inputModeActive(mode.modeId)) {
      setInputMode(mode.modeId, 10, false);
    }

    SimpleTransaction<PortValueMessage> tx =
        SimpleTransaction<PortValueMessage>(msgToSend: PortInformationRequestMessage(portId, PortInformationRequestType.PortValue));
    PortValueMessage? msg = await tx.queue(hub);
    if (msg == null) {
      return 0.0;
    }
    return mode.decode(msg.value, 0)[0];
  }
}

/// Current input for Peripherals.
/// {@category API}
mixin CurrentInput on Peripheral {
  /// Gets the voltage of the battery.
  Future<double> getCurrent() async {
    PeripheralMode mode = await getModeFor("CUR L");

    // make sure it's active!
    if (!inputModeActive(mode.modeId)) {
      setInputMode(mode.modeId, 10, false);
    }

    SimpleTransaction<PortValueMessage> tx =
        SimpleTransaction<PortValueMessage>(msgToSend: PortInformationRequestMessage(portId, PortInformationRequestType.PortValue));
    PortValueMessage? msg = await tx.queue(hub);
    if (msg == null) {
      return 0.0;
    }
    return mode.decode(msg.value, 0)[0];
  }
}

/// Temperature input for Peripherals.
/// {@category API}
mixin TemperatureInput on Peripheral {
  /// Gets the temperature.
  Future<double> getTemperature() async {
    // check which mode holds TEMP
    PeripheralMode mode = await getModeFor("TEMP");

    // make sure it's active!
    if (!inputModeActive(mode.modeId)) {
      setInputMode(mode.modeId, 10, false);
    }

    // Read the value.
    SimpleTransaction<PortValueMessage> tx =
        SimpleTransaction<PortValueMessage>(msgToSend: PortInformationRequestMessage(portId, PortInformationRequestType.PortValue));
    PortValueMessage? msg = await tx.queue(hub);
    if (msg == null) {
      return 0.0;
    }

    return mode.decode(msg.value, 0)[0];
  }
}

/// Acceleration input for Peripherals.
/// {@category API}
mixin AccelerationInput on Peripheral {
  /// Gets the acceleration readout.
  Future<List<double>> getAcceleration() async {
    PeripheralMode mode = await getModeFor("GRV");

    // make sure it's active!
    if (!inputModeActive(mode.modeId)) {
      setInputMode(mode.modeId, 10, false);
    }

    // read value
    SimpleTransaction<PortValueMessage> tx =
        SimpleTransaction<PortValueMessage>(msgToSend: PortInformationRequestMessage(portId, PortInformationRequestType.PortValue));
    PortValueMessage? msg = await tx.queue(hub);
    if (msg == null) {
      return [];
    }

    return mode.decode(msg.value, 0);
  }
}

/// Gyro input for Peripherals.
/// {@category API}
mixin GyroInput on Peripheral {
  /// Gets the gyro readout.
  Future<List<double>> getGyro() async {
    PeripheralMode mode = await getModeFor("ROT");

    // make sure it's active!
    if (!inputModeActive(mode.modeId)) {
      setInputMode(mode.modeId, 10, false);
    }

    // read value
    SimpleTransaction<PortValueMessage> tx =
        SimpleTransaction<PortValueMessage>(msgToSend: PortInformationRequestMessage(portId, PortInformationRequestType.PortValue));
    PortValueMessage? msg = await tx.queue(hub);
    if (msg == null) {
      return [];
    }

    return mode.decode(msg.value, 0);
  }
}

/// Orientation input for Peripherals.
/// {@category API}
mixin OrientationInput on Peripheral {
  /// Gets the Orientation readout.
  Future<List<double>> getOrientation() async {
    PeripheralMode mode = await getModeFor("POS");

    // make sure it's active!
    if (!inputModeActive(mode.modeId)) {
      setInputMode(mode.modeId, 10, false);
    }

    // read value
    SimpleTransaction<PortValueMessage> tx =
        SimpleTransaction<PortValueMessage>(msgToSend: PortInformationRequestMessage(portId, PortInformationRequestType.PortValue));
    PortValueMessage? msg = await tx.queue(hub);
    if (msg == null) {
      return [];
    }

    return mode.decode(msg.value, 0);
  }
}

/// Gesture input for Peripherals.
/// {@category API}
mixin GestureInput on Peripheral {
  /// Gets the Orientation readout.
  Future<double> getGesture() async {
    PeripheralMode mode = await getModeFor("GEST");

    // make sure it's active!
    if (!inputModeActive(mode.modeId)) {
      setInputMode(mode.modeId, 10, false);
    }

    // read value
    SimpleTransaction<PortValueMessage> tx =
        SimpleTransaction<PortValueMessage>(msgToSend: PortInformationRequestMessage(portId, PortInformationRequestType.PortValue));
    PortValueMessage? msg = await tx.queue(hub);
    if (msg == null) {
      return -1;
    }

    return mode.decode(msg.value, 0)[0];
  }
}

/// GesturePeripheral class using [GestureInput] mixin.
/// {@category API}
class GesturePeripheral extends Peripheral with GestureInput {
  GesturePeripheral(Hub hub, HubAttachedIOMessage attachedIO) : super(hub, attachedIO);
}

/// OrientationPeripheral class using [OrientationInput] mixin.
/// {@category API}
class OrientationPeripheral extends Peripheral with OrientationInput {
  OrientationPeripheral(Hub hub, HubAttachedIOMessage attachedIO) : super(hub, attachedIO);
}

/// GyroPeripheral class using [GyroInput] mixin.
/// {@category API}
class GyroPeripheral extends Peripheral with GyroInput {
  GyroPeripheral(Hub hub, HubAttachedIOMessage attachedIO) : super(hub, attachedIO);
}

/// AccelerationPeripheral class using [AccelerationInput] mixin.
/// {@category API}
class AccelerationPeripheral extends Peripheral with AccelerationInput {
  AccelerationPeripheral(Hub hub, HubAttachedIOMessage attachedIO) : super(hub, attachedIO);
}

/// VoltagePeripheral class using [VoltageInput] mixin.
/// {@category API}
class VoltagePeripheral extends Peripheral with VoltageInput {
  VoltagePeripheral(Hub hub, HubAttachedIOMessage attachedIO) : super(hub, attachedIO);
}

/// CurrentPeripheral class using [CurrentInput] mixin.
/// {@category API}
class CurrentPeripheral extends Peripheral with CurrentInput {
  CurrentPeripheral(Hub hub, HubAttachedIOMessage attachedIO) : super(hub, attachedIO);
}

/// TemperaturePeripheral class using [TemperatureInput] mixin.
/// {@category API}
class TemperaturePeripheral extends Peripheral with TemperatureInput {
  TemperaturePeripheral(Hub hub, HubAttachedIOMessage attachedIO) : super(hub, attachedIO);
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
