part of flutter_lwp;

/// Parent class for PortOutputCommand's.
class PortOutputCommandMessage extends Message {
  final int portId;
  final PortOutputStartup startup;
  final PortOutputCompletion completion;
  final PortSubCommand subCommand;
  final List<int> payload;

  PortOutputCommandMessage(this.portId, this.startup, this.completion, this.subCommand, this.payload) : super(messageType: MessageType.PortOutputCommand);

  @override
  List<int> _encode() {
    return [portId, (startup.value << 4) | completion.value, subCommand.value, ...payload];
  }

  factory PortOutputCommandMessage.decode(List<int> data, int offset) {
    if (data.length - offset < 3) {
      throw Exception("Not enough data");
    }
    int portId = data[offset];
    PortOutputStartup startup = PortOutputStartupValue.fromInt(data[offset + 1] >> 4);
    PortOutputCompletion completion = PortOutputCompletionValue.fromInt(data[offset + 1] & 0x0F);
    PortSubCommand subCommand = PortSubCommandValue.fromInt(data[offset + 2]);
    return PortOutputCommandMessage(portId, startup, completion, subCommand, data.sublist(offset + 3));
  }

  String toString() {
    return "PortOutputCommandMessage Message: type$subCommand";
  }
}

/// Move motor at certain speed indefinitely.
///
/// details:
///https://lego.github.io/lego-ble-wireless-protocol-docs/index.html#output-sub-command-startspeed-speed-maxpower-useprofile-0x07
class StartSpeedMessage extends PortOutputCommandMessage {
  StartSpeedMessage(int portId, PortOutputStartup startup, PortOutputCompletion completion, int speed, int maxPower, MotorAccelerationProfile useProfile)
      : super(portId, startup, completion, PortSubCommand.StartSpeed, [speed, maxPower, useProfile.value]);
}

/// Move motor for a certain number of revolutions specified in degrees.
///
/// details:
/// https://lego.github.io/lego-ble-wireless-protocol-docs/index.html#output-sub-command-startspeedfordegrees-degrees-speed-maxpower-endstate-useprofile-0x0b
class StartSpeedForDegreesMessage extends PortOutputCommandMessage {
  StartSpeedForDegreesMessage(int portId, PortOutputStartup startup, PortOutputCompletion completion, int degrees, int speed, int maxPower,
      MotorEndState endState, MotorAccelerationProfile useProfile)
      : super(portId, startup, completion, PortSubCommand.StartSpeedForDegrees,
            [...Helper.encodeInt32LE(degrees), speed, maxPower, endState.value, useProfile.value]);
}

/// Move motor to an absolute rotation
///
/// details:
/// https://lego.github.io/lego-ble-wireless-protocol-docs/index.html#output-sub-command-gotoabsoluteposition-abspos-speed-maxpower-endstate-useprofile-0x0d
class GotoAbsolutePositionMessage extends PortOutputCommandMessage {
  GotoAbsolutePositionMessage(int portId, PortOutputStartup startup, PortOutputCompletion completion, int absolutePosition, int speed, int maxPower,
      MotorEndState endState, MotorAccelerationProfile useProfile)
      : super(portId, startup, completion, PortSubCommand.GotoAbsolutePosition,
            [...Helper.encodeInt32LE(absolutePosition), speed, maxPower, endState.value, useProfile.value]);
}
