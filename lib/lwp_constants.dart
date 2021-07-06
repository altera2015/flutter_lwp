part of flutter_lwp;

/// The top level message type for messages
/// to and from the Hub. Used by [Message]
///
/// Full details:
/// https://lego.github.io/lego-ble-wireless-protocol-docs/#message-types
/// {@category messages}
enum MessageType {
  Empty,
  HubProperties,
  HubActions,
  HubAlerts,
  HubAttachedIO,
  GenericErrorMessages,

  PortInformationRequest,
  PortModeInformationRequest,
  PortInputFormatSetup,
  PortInputFormatSetupCombined,
  PortInformation,
  PortModeInformation,
  PortValue,
  PortValueCombined,
  PortInputFormat,
  PortInputFormatCombined,
  VirtualPortSetup,
  PortOutputCommand,
  PortOutputCommandFeedback
}

/// {@category messages}
extension MessageTypeValue on MessageType {
  static const int _HubProperties = 0x01;
  static const int _HubActions = 0x02;
  static const int _HubAlerts = 0x03;
  static const int _HubAttachedIO = 0x04;
  static const int _GenericErrorMessages = 0x05;

  static MessageType fromInt(int v) {
    switch (v) {
      case _HubProperties:
        return MessageType.HubProperties;
      case _HubActions:
        return MessageType.HubActions;
      case _HubAlerts:
        return MessageType.HubAlerts;
      case _HubAttachedIO:
        return MessageType.HubAttachedIO;
      case _GenericErrorMessages:
        return MessageType.GenericErrorMessages;

      case 0x21:
        return MessageType.PortInformationRequest;
      case 0x22:
        return MessageType.PortModeInformationRequest;
      case 0x41:
        return MessageType.PortInputFormatSetup;
      case 0x42:
        return MessageType.PortInputFormatSetupCombined;
      case 0x43:
        return MessageType.PortInformation;
      case 0x44:
        return MessageType.PortModeInformation;
      case 0x45:
        return MessageType.PortValue;
      case 0x46:
        return MessageType.PortValueCombined;
      case 0x47:
        return MessageType.PortInputFormat;
      case 0x48:
        return MessageType.PortInputFormatCombined;
      case 0x61:
        return MessageType.VirtualPortSetup;
      case 0x81:
        return MessageType.PortOutputCommand;
      case 0x82:
        return MessageType.PortOutputCommandFeedback;
      default:
        throw Exception("MessageType: Unknown Value $v");
    }
  }

  int get value {
    switch (this) {
      case MessageType.Empty:
        return 0;
      // Hub Messages
      case MessageType.HubProperties:
        return _HubProperties;
      case MessageType.HubActions:
        return _HubActions;
      case MessageType.HubAlerts:
        return _HubAlerts;
      case MessageType.HubAttachedIO:
        return _HubAttachedIO;
      case MessageType.GenericErrorMessages:
        return _GenericErrorMessages;

      // Port Messages
      case MessageType.PortInformationRequest:
        return 0x21;
      case MessageType.PortModeInformationRequest:
        return 0x22;
      case MessageType.PortInputFormatSetup:
        return 0x41;
      case MessageType.PortInputFormatSetupCombined:
        return 0x42;
      case MessageType.PortInformation:
        return 0x43;
      case MessageType.PortModeInformation:
        return 0x44;
      case MessageType.PortValue:
        return 0x45;
      case MessageType.PortValueCombined:
        return 0x46;
      case MessageType.PortInputFormat:
        return 0x47;
      case MessageType.PortInputFormatCombined:
        return 0x48;
      case MessageType.VirtualPortSetup:
        return 0x61;
      case MessageType.PortOutputCommand:
        return 0x81;
      case MessageType.PortOutputCommandFeedback:
        return 0x82;
    }
  }
}

/// Hub Operation enum
///
/// Full details:
/// https://lego.github.io/lego-ble-wireless-protocol-docs/#hub-property-operation
/// {@category messages}
enum HubOperation {
  Set,

  /// enable updates to arrive from the hub. For example [HubAttachedIOMessage]/[HubDetachedIOMessage] messages.
  EnableUpdates,

  /// disable the updates from the hub
  DisableUpdates,

  /// reset the hub
  Reset,

  /// request a update of the update status.
  RequestUpdate,

  /// enum used by hub to answer [RequestUpdate] and [EnableUpdates]
  Update
}

/// {@category messages}
extension HubOperationValue on HubOperation {
  static const int _Set = 0x01;
  static const int _EnableUpdates = 0x02;
  static const int _DisableUpdates = 0x03;
  static const int _Reset = 0x04;
  static const int _RequestUpdate = 0x05;
  static const int _Update = 0x06;

  int get value {
    switch (this) {
      case HubOperation.Set:
        return _Set;
      case HubOperation.EnableUpdates:
        return _EnableUpdates;
      case HubOperation.DisableUpdates:
        return _DisableUpdates;
      case HubOperation.Reset:
        return _Reset;
      case HubOperation.RequestUpdate:
        return _RequestUpdate;
      case HubOperation.Update:
        return _Update;
    }
  }

  static HubOperation fromInt(int v) {
    switch (v) {
      case _Set:
        return HubOperation.Set;
      case _EnableUpdates:
        return HubOperation.EnableUpdates;
      case _DisableUpdates:
        return HubOperation.DisableUpdates;
      case _Reset:
        return HubOperation.Reset;
      case _RequestUpdate:
        return HubOperation.RequestUpdate;
      case _Update:
        return HubOperation.Update;

      default:
        throw Exception("HubOperation: Unknown Value $v");
    }
  }
}

/// Hub Property
///
/// Full details:
/// https://lego.github.io/lego-ble-wireless-protocol-docs/#hub-property-reference
/// {@category messages}
enum HubProperty {
  AdvertisingName,
  ButtonState,
  FWVersion,
  HWVersion,
  Rssi,
  Battery,
  BatteryType,
  ManufacturerName,
  RadioFWVersion,
  LwpProtocolVersion,
  SystemTypeId,
  HWNetworkId,
  PrimaryMac,
  SecondaryMac,
  NetworkFamily
}

/// {@category messages}
extension HubPropertyValue on HubProperty {
  static const int _AdvertisingName = 0x01;
  static const int _ButtonState = 0x02;
  static const int _FWVersion = 0x03;
  static const int _HWVersion = 0x04;
  static const int _Rssi = 0x05;
  static const int _Battery = 0x06;
  static const int _BatteryType = 0x07;
  static const int _ManufacturerName = 0x08;
  static const int _RadioFWVersion = 0x09;
  static const int _LwpProtocolVersion = 0x0a;
  static const int _SystemTypeId = 0x0B;
  static const int _HWNetworkId = 0x0c;
  static const int _PrimaryMac = 0x0d;
  static const int _SecondaryMac = 0x0e;
  static const int _NetworkFamily = 0x0f;

  int get value {
    switch (this) {
      case HubProperty.AdvertisingName:
        return _AdvertisingName;
      case HubProperty.ButtonState:
        return _ButtonState;
      case HubProperty.FWVersion:
        return _FWVersion;
      case HubProperty.HWVersion:
        return _HWVersion;
      case HubProperty.Rssi:
        return _Rssi;
      case HubProperty.Battery:
        return _Battery;
      case HubProperty.BatteryType:
        return _BatteryType;
      case HubProperty.ManufacturerName:
        return _ManufacturerName;
      case HubProperty.RadioFWVersion:
        return _RadioFWVersion;
      case HubProperty.LwpProtocolVersion:
        return _LwpProtocolVersion;
      case HubProperty.SystemTypeId:
        return _SystemTypeId;
      case HubProperty.HWNetworkId:
        return _HWNetworkId;
      case HubProperty.PrimaryMac:
        return _PrimaryMac;
      case HubProperty.SecondaryMac:
        return _SecondaryMac;
      case HubProperty.NetworkFamily:
        return _NetworkFamily;
    }
  }

  static HubProperty fromInt(int v) {
    switch (v) {
      case _AdvertisingName:
        return HubProperty.AdvertisingName;
      case _ButtonState:
        return HubProperty.ButtonState;
      case _FWVersion:
        return HubProperty.FWVersion;
      case _HWVersion:
        return HubProperty.HWVersion;
      case _Rssi:
        return HubProperty.Rssi;
      case _Battery:
        return HubProperty.Battery;
      case _BatteryType:
        return HubProperty.BatteryType;
      case _ManufacturerName:
        return HubProperty.ManufacturerName;
      case _RadioFWVersion:
        return HubProperty.RadioFWVersion;
      case _LwpProtocolVersion:
        return HubProperty.LwpProtocolVersion;
      case _SystemTypeId:
        return HubProperty.SystemTypeId;
      case _HWNetworkId:
        return HubProperty.HWNetworkId;
      case _PrimaryMac:
        return HubProperty.PrimaryMac;
      case _SecondaryMac:
        return HubProperty.SecondaryMac;
      case _NetworkFamily:
        return HubProperty.NetworkFamily;
      default:
        throw Exception("HubProperty: Unknown Value $v");
    }
  }
}

/// Enums detailing if ports are attached or detached.
///
/// Full details:
/// https://lego.github.io/lego-ble-wireless-protocol-docs/#event
/// {@category messages}
enum HubAttachedIOEvent { Attached, Detached, AttachedVirtual }

/// {@category messages}
extension HubAttachedIOEventValue on HubAttachedIOEvent {
  static const int _Attached = 0x01;
  static const int _Detached = 0x02;
  static const int _AttachedVirtual = 0x03;

  int get value {
    switch (this) {
      case HubAttachedIOEvent.Attached:
        return _Attached;
      case HubAttachedIOEvent.Detached:
        return _Detached;
      case HubAttachedIOEvent.AttachedVirtual:
        return _AttachedVirtual;
    }
  }

  static HubAttachedIOEvent fromInt(int v) {
    switch (v) {
      case _Attached:
        return HubAttachedIOEvent.Attached;
      case _Detached:
        return HubAttachedIOEvent.Detached;
      case _AttachedVirtual:
        return HubAttachedIOEvent.AttachedVirtual;
      default:
        throw Exception("HubAttachedIOEvent: Unknown Value $v");
    }
  }
}

/// IOTypes for attached [Peripheral]s.
///
/// Full details:
/// https://lego.github.io/lego-ble-wireless-protocol-docs/#io-type-id
/// additional types from:
/// https://docs.pybricks.com/projects/pybricksdev/en/latest/api/ble/lwp3/bytecodes.html
/// {@category messages}
enum IOType {
  Motor,
  SystemTrainMotor,
  Button,
  LEDLight,
  Voltage,
  Current,
  PiezoTone,
  RGBLight,
  ExternalTiltSensor,
  MotionSensor,
  VisionSensor,
  ExternalMotorWithTacho,
  InternalMotorWithTacho,
  InternalTilt,
  HubIMUAccel,
  HubIMUGesture,
  HubIMUGyro,
  HubIMUOrientation,
  HubIMUTemperature,
  HubStatusLight,
  LargeMotor,
  XLargeMotor,
  MediumAngularMotor,
  LargeAngularMotor,
}

/// {@category messages}
extension IOTypeValue on IOType {
  static Map<IOType, int> _mapping = {
    IOType.Motor: 0x0001,
    IOType.SystemTrainMotor: 0x0002,
    IOType.Button: 0x0005,
    IOType.LEDLight: 0x0008,
    IOType.Voltage: 0x0014,
    IOType.Current: 0x0015,
    IOType.PiezoTone: 0x0016,
    IOType.ExternalTiltSensor: 0x0022,
    IOType.MotionSensor: 0x0023,
    IOType.VisionSensor: 0x0025,
    IOType.ExternalMotorWithTacho: 0x0026,
    IOType.InternalMotorWithTacho: 0x0027,
    IOType.InternalTilt: 0x0028,
    IOType.HubIMUAccel: 0x0039,
    IOType.HubIMUGesture: 0x0036,
    IOType.HubIMUGyro: 0x003a,
    IOType.HubIMUOrientation: 0x003b,
    IOType.HubIMUTemperature: 0x003c,
    IOType.HubStatusLight: 0x0017,
    IOType.LargeMotor: 0x002e,
    IOType.XLargeMotor: 0x002f,
    IOType.MediumAngularMotor: 0x004b,
    IOType.LargeAngularMotor: 0x004c,
  };

  int get value {
    return _mapping[this]!;
  }

  static IOType fromInt(int v) {
    IOType? foundType;
    _mapping.forEach((key, value) {
      if (value == v) {
        foundType = key;
      }
    });

    if (foundType == null) {
      throw Exception("IOType: Unknown Value $v");
    }

    return foundType!;
  }
}

/// Protocol Errors Codes
///
/// Full details:
/// https://lego.github.io/lego-ble-wireless-protocol-docs/#error-codes
/// {@category messages}
enum ErrorCode { ACK, MACK, BufferOverflow, Timeout, CommandNotRecognized, InvalidUse, OverCurrent, InternalError }

/// {@category messages}
extension ErrorCodeValue on ErrorCode {
  static Map<ErrorCode, int> _mapping = {
    ErrorCode.ACK: 0x0001,
    ErrorCode.MACK: 0x0002,
    ErrorCode.BufferOverflow: 0x0003,
    ErrorCode.Timeout: 0x0004,
    ErrorCode.CommandNotRecognized: 0x0005,
    ErrorCode.InvalidUse: 0x0006,
    ErrorCode.OverCurrent: 0x0007,
    ErrorCode.InternalError: 0x0008
  };

  int get value {
    return _mapping[this]!;
  }

  static ErrorCode fromInt(int v) {
    ErrorCode? found;
    _mapping.forEach((key, value) {
      if (value == v) {
        found = key;
      }
    });

    if (found == null) {
      throw Exception("ErrorCodes: Unknown Value $v");
    }

    return found!;
  }
}

/// Enum detailing the result of a [PortOutputCommandMessage].
///
/// Full details:
/// https://lego.github.io/lego-ble-wireless-protocol-docs/index.html#port-output-command-feedback
/// {@category messages}
enum PortOutputFeedback { BufferEmptyInProgress, BufferEmptyCompleted, CommandsDiscarded, Idle, Busy }

/// {@category messages}
extension PortOutputFeedbackValue on PortOutputFeedback {
  static Map<PortOutputFeedback, int> _mapping = {
    PortOutputFeedback.BufferEmptyInProgress: 0x01,
    PortOutputFeedback.BufferEmptyCompleted: 0x02,
    PortOutputFeedback.CommandsDiscarded: 0x04,
    PortOutputFeedback.Idle: 0x08,
    PortOutputFeedback.Busy: 0x10,
  };

  int get value {
    return _mapping[this]!;
  }

  static PortOutputFeedback fromInt(int v) {
    PortOutputFeedback? found;
    _mapping.forEach((key, value) {
      if (value == v) {
        found = key;
      }
    });

    if (found == null) {
      throw Exception("PortOutputFeedback: Unknown Value $v");
    }

    return found!;
  }

  static List<PortOutputFeedback> toList(int v) {
    List<PortOutputFeedback> l = [];
    PortOutputFeedback.values.forEach((element) {
      if (v & element.value != 0) {
        l.add(element);
      }
    });
    return l;
  }

  static int fromList(List<PortOutputFeedback> l) {
    int v = 0;
    l.forEach((element) {
      v = v | element.value;
    });
    return v;
  }
}

/// Controls queue behavior for [PortOutputCommandMessage]
///
/// Full details:
/// https://lego.github.io/lego-ble-wireless-protocol-docs/index.html#st-comp
/// {@category messages}
enum PortOutputStartup {
  /// Buffers the command if needed, note there is only room for a single buffer
  /// in the Hub's queue.
  BufferIfNeeded,

  /// Cancel ongoing command and immediately
  /// send this command.
  Immediate
}

/// {@category messages}
extension PortOutputStartupValue on PortOutputStartup {
  static Map<PortOutputStartup, int> _mapping = {
    PortOutputStartup.BufferIfNeeded: 0x00,
    PortOutputStartup.Immediate: 0x01,
  };

  int get value {
    return _mapping[this]!;
  }

  static PortOutputStartup fromInt(int v) {
    PortOutputStartup? found;
    _mapping.forEach((key, value) {
      if (value == v) {
        found = key;
      }
    });

    if (found == null) {
      throw Exception("PortOutputStartup: Unknown Value $v");
    }

    return found!;
  }
}

/// Completion options.
///
/// Full details:
/// https://lego.github.io/lego-ble-wireless-protocol-docs/index.html#st-comp
/// {@category messages}
enum PortOutputCompletion {
  /// don't give any feedback upon completion.
  NoAction,

  /// send a PortOutputCommandFeedback message when done.
  Feedback
}

/// {@category messages}
extension PortOutputCompletionValue on PortOutputCompletion {
  static Map<PortOutputCompletion, int> _mapping = {
    PortOutputCompletion.NoAction: 0x00,
    PortOutputCompletion.Feedback: 0x01,
  };

  int get value {
    return _mapping[this]!;
  }

  static PortOutputCompletion fromInt(int v) {
    PortOutputCompletion? found;
    _mapping.forEach((key, value) {
      if (value == v) {
        found = key;
      }
    });

    if (found == null) {
      throw Exception("PortOutputCompletion: Unknown Value $v");
    }

    return found!;
  }
}

/// PortSubCommand values for [PortOutputCommandMessage]
///
/// Full details:
/// https://lego.github.io/lego-ble-wireless-protocol-docs/index.html#output-command-0x81-motor-sub-commands-0x01-0x3f
/// {@category messages}
enum PortSubCommand {
  /// Start motor at specified speed and does not stop.
  StartSpeed,

  /// Start motor at specified speed for a certain number of degrees.
  StartSpeedForDegrees,

  /// Move motor at specified speed to a certain rotation in degrees.
  GotoAbsolutePosition,

  /// Write commands directly to peripheral.
  WriteDirectModeData
}

/// {@category messages}
extension PortSubCommandValue on PortSubCommand {
  static Map<PortSubCommand, int> _mapping = {
    PortSubCommand.StartSpeed: 0x07,
    PortSubCommand.StartSpeedForDegrees: 0x0b,
    PortSubCommand.GotoAbsolutePosition: 0x0d,
    PortSubCommand.WriteDirectModeData: 0x51,
  };

  int get value {
    return _mapping[this]!;
  }

  static PortSubCommand fromInt(int v) {
    PortSubCommand? found;
    _mapping.forEach((key, value) {
      if (value == v) {
        found = key;
      }
    });

    if (found == null) {
      throw Exception("PortSubCommand: Unknown Value $v");
    }

    return found!;
  }
}

/// Information Request
///
/// Full details
/// https://lego.github.io/lego-ble-wireless-protocol-docs/index.html#port-information-request-format
/// {@category messages}
enum PortInformationRequestType {
  /// Get a PortValueMessage
  PortValue,

  /// Get a ModeInfoMessage
  ModeInfo,

  /// Get all valid Mode combinations ( not implemented yet ).
  ModeCombinations
}

/// {@category messages}
extension PortInformationRequestTypeValue on PortInformationRequestType {
  static Map<PortInformationRequestType, int> _mapping = {
    PortInformationRequestType.PortValue: 0x00,
    PortInformationRequestType.ModeInfo: 0x01,
    PortInformationRequestType.ModeCombinations: 0x02
  };

  int get value {
    return _mapping[this]!;
  }

  static PortInformationRequestType fromInt(int v) {
    PortInformationRequestType? found;
    _mapping.forEach((key, value) {
      if (value == v) {
        found = key;
      }
    });

    if (found == null) {
      throw Exception("InformationType: Unknown Value $v");
    }

    return found!;
  }
}

/// Port Capabilities.
///
/// Full details:
/// https://lego.github.io/lego-ble-wireless-protocol-docs/index.html#mod-ityp
/// {@category messages}
enum PortCapabilities {
  /// Port can output (seen from Hub)
  Output,

  /// Port can input (seen from Hub)
  Input,

  /// Can combine commands to this port.
  LogicalCombinable,

  /// Can synchronize commands to this port.
  LogicalSynchronizable,
}

/// {@category messages}
enum PortModeInformationType { NAME, RAW, PCT, SI, SYMBOL, MAPPING, INTERNAL, MOTOR_BIAS, CAPABILITY_BITS, VALUE_FORMAT }

/// {@category messages}
extension PortModeInformationTypeValue on PortModeInformationType {
  static Map<PortModeInformationType, int> _mapping = {
    PortModeInformationType.NAME: 0x00,
    PortModeInformationType.RAW: 0x01,
    PortModeInformationType.PCT: 0x02,
    PortModeInformationType.SI: 0x03,
    PortModeInformationType.SYMBOL: 0x04,
    PortModeInformationType.MAPPING: 0x05,
    PortModeInformationType.INTERNAL: 0x06,
    PortModeInformationType.MOTOR_BIAS: 0x07,
    PortModeInformationType.CAPABILITY_BITS: 0x08,
    PortModeInformationType.VALUE_FORMAT: 0x80
  };

  int get value {
    return _mapping[this]!;
  }

  static PortModeInformationType fromInt(int v) {
    PortModeInformationType? found;
    _mapping.forEach((key, value) {
      if (value == v) {
        found = key;
      }
    });

    if (found == null) {
      throw Exception("PortModeInformationType: Unknown Value $v");
    }

    return found!;
  }
}

/// Controls the state of the motor at the end of a command
/// used by for example [StartSpeedForDegreesMessage].
///
/// Full details:
/// https://lego.github.io/lego-ble-wireless-protocol-docs/index.html#output-sub-command-startspeedfordegrees-degrees-speed-maxpower-endstate-useprofile-0x0b
/// {@category messages}
enum MotorEndState {
  /// let the motor spin freely
  Float,

  /// Attempt to hold the position actively
  Hold,

  /// Resist any changes without correcting.
  Brake
}

/// {@category messages}
extension MotorEndStateValue on MotorEndState {
  static Map<MotorEndState, int> _mapping = {
    MotorEndState.Float: 0x00,
    MotorEndState.Hold: 126,
    MotorEndState.Brake: 127,
  };

  int get value {
    return _mapping[this]!;
  }

  static MotorEndState fromInt(int v) {
    MotorEndState? found;
    _mapping.forEach((key, value) {
      if (value == v) {
        found = key;
      }
    });

    if (found == null) {
      throw Exception("MotorEndState: Unknown Value $v");
    }

    return found!;
  }
}

/// Acceleration/Deceleration profile to use for Motor Commands
///
/// Full details:
/// https://lego.github.io/lego-ble-wireless-protocol-docs/index.html#output-sub-command-startspeedfordegrees-degrees-speed-maxpower-endstate-useprofile-0x0b
/// {@category messages}
enum MotorAccelerationProfile { None, UseAcceleration, UseDeceleration, UseBoth }

/// {@category messages}
extension MotorAccelerationProfileValue on MotorAccelerationProfile {
  static Map<MotorAccelerationProfile, int> _mapping = {
    MotorAccelerationProfile.None: 0,
    MotorAccelerationProfile.UseAcceleration: 1,
    MotorAccelerationProfile.UseDeceleration: 2,
    MotorAccelerationProfile.UseBoth: 3
  };

  int get value {
    return _mapping[this]!;
  }

  static MotorAccelerationProfile fromInt(int v) {
    MotorAccelerationProfile? found;
    _mapping.forEach((key, value) {
      if (value == v) {
        found = key;
      }
    });

    if (found == null) {
      throw Exception("MotorAccelerationProfile: Unknown Value $v");
    }

    return found!;
  }
}
