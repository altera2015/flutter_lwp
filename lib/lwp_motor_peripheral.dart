part of flutter_lwp;

class _StartSpeedThrottle {
  bool inProgress = false;
  bool requested = false;
  int speed = 0;
  int maxPower = 0;
  MotorAccelerationProfile profile = MotorAccelerationProfile.None;

  void assign(int speed, int maxPower, MotorAccelerationProfile useProfile) {
    requested = true;
    this.speed = speed;
    this.maxPower = maxPower;
    this.profile = useProfile;
  }
}

class _GotoAbsolutePositionThrottle {
  bool inProgress = false;
  bool requested = false;
  int absolutePosition = 0;
  int speed = 0;
  int maxPower = 0;
  MotorEndState endState = MotorEndState.Float;
  MotorAccelerationProfile useProfile = MotorAccelerationProfile.None;
  void assign(int degrees, int speed, int maxPower, MotorEndState endState, MotorAccelerationProfile useProfile) {
    requested = true;
    this.absolutePosition = degrees;
    this.speed = speed;
    this.maxPower = maxPower;
    this.endState = endState;
    this.useProfile = useProfile;
  }
}

class _StartSpeedForDegreesThrottle {
  bool inProgress = false;
  bool requested = false;
  int degrees = 0;
  int speed = 0;
  int maxPower = 0;
  MotorEndState endState = MotorEndState.Float;
  MotorAccelerationProfile useProfile = MotorAccelerationProfile.None;
  void assign(int degrees, int speed, int maxPower, MotorEndState endState, MotorAccelerationProfile useProfile) {
    requested = true;
    this.degrees = degrees;
    this.speed = speed;
    this.maxPower = maxPower;
    this.endState = endState;
    this.useProfile = useProfile;
  }
}

/// Motor actions for Peripherals.
/// {@category API}
mixin Motor on Peripheral {
  _StartSpeedThrottle _startSpeedThrottle = _StartSpeedThrottle();

  /// Starts motor running at specified speed using at most maxPower using the
  /// acceleration profile specified in useProfile.
  Future<bool> startSpeed(int speed, int maxPower, MotorAccelerationProfile useProfile) async {
    if (_startSpeedThrottle.inProgress) {
      _startSpeedThrottle.assign(speed, maxPower, useProfile);
      return false;
    }
    _startSpeedThrottle.inProgress = true;

    print("speed $speed");
    // await Future.delayed(Duration(seconds: 1));
    // Message? msg;
    //
    PortOutputCommandFeedback? msg;
    SimpleTransaction<PortOutputCommandFeedback> tx = SimpleTransaction<PortOutputCommandFeedback>(
        msgToSend: StartSpeedMessage(portId, PortOutputStartup.BufferIfNeeded, PortOutputCompletion.Feedback, speed, maxPower, useProfile));
    msg = await tx.queue(hub);

    _startSpeedThrottle.inProgress = false;
    if (_startSpeedThrottle.requested) {
      startSpeed(_startSpeedThrottle.speed, _startSpeedThrottle.maxPower, _startSpeedThrottle.profile);
      _startSpeedThrottle.requested = false;
    }

    if (msg == null) {
      return false;
    }
    Helper.dprint("startSpeed got $msg");
    return true;
  }

  _StartSpeedForDegreesThrottle _startSpeedForDegreesThrottle = _StartSpeedForDegreesThrottle();

  /// Runs motor for set number of degrees at specified speed using at most maxPower using the
  /// acceleration profile specified in useProfile.
  Future<bool> startSpeedForDegrees(int degrees, int speed, int maxPower, MotorEndState endState, MotorAccelerationProfile useProfile) async {
    if (_startSpeedForDegreesThrottle.inProgress) {
      _startSpeedForDegreesThrottle.assign(degrees, speed, maxPower, endState, useProfile);
      return false;
    }
    _startSpeedForDegreesThrottle.inProgress = true;

    SimpleTransaction<PortOutputCommandFeedback> tx = SimpleTransaction<PortOutputCommandFeedback>(
        msgToSend: StartSpeedForDegreesMessage(
            portId, PortOutputStartup.BufferIfNeeded, PortOutputCompletion.Feedback, degrees, speed, maxPower, endState, useProfile));
    PortOutputCommandFeedback? msg = await tx.queue(hub);

    _startSpeedForDegreesThrottle.inProgress = false;

    if (_startSpeedForDegreesThrottle.requested) {
      startSpeedForDegrees(_startSpeedForDegreesThrottle.degrees, _startSpeedForDegreesThrottle.speed, _startSpeedForDegreesThrottle.maxPower,
          _startSpeedForDegreesThrottle.endState, _startSpeedForDegreesThrottle.useProfile);
      _startSpeedForDegreesThrottle.requested = false;
    }

    if (msg == null) {
      return false;
    }
    Helper.dprint("startSpeedForDegrees got $msg");
    return true;
  }

  _GotoAbsolutePositionThrottle _gotoAbsolutePositionThrottle = _GotoAbsolutePositionThrottle();

  /// Runs motor until a certain rotation position is achieved at specified speed using at most maxPower using the
  /// acceleration profile specified in useProfile.
  Future<bool> gotoAbsolutePosition(int absolutePosition, int speed, int maxPower, MotorEndState endState, MotorAccelerationProfile useProfile) async {
    if (_gotoAbsolutePositionThrottle.inProgress) {
      _gotoAbsolutePositionThrottle.assign(absolutePosition, speed, maxPower, endState, useProfile);
      return false;
    }
    _gotoAbsolutePositionThrottle.inProgress = true;
    //
    // await Future.delayed(Duration(seconds: 1));
    // Message? msg;
    //
    SimpleTransaction<PortOutputCommandFeedback> tx = SimpleTransaction<PortOutputCommandFeedback>(
        msgToSend: GotoAbsolutePositionMessage(
            portId, PortOutputStartup.BufferIfNeeded, PortOutputCompletion.Feedback, absolutePosition, speed, maxPower, endState, useProfile));
    PortOutputCommandFeedback? msg = await tx.queue(hub);

    print("abs = $absolutePosition");

    _gotoAbsolutePositionThrottle.inProgress = false;

    if (_gotoAbsolutePositionThrottle.requested) {
      gotoAbsolutePosition(_gotoAbsolutePositionThrottle.absolutePosition, _gotoAbsolutePositionThrottle.speed, _gotoAbsolutePositionThrottle.maxPower,
          _gotoAbsolutePositionThrottle.endState, _gotoAbsolutePositionThrottle.useProfile);
      _gotoAbsolutePositionThrottle.requested = false;
    }

    if (msg == null) {
      return false;
    }
    Helper.dprint("gotoAbsolutePosition got $msg");
    return true;
  }

  /// Runs motor for set number of degrees at specified speed using at most maxPower using the
  /// acceleration profile specified in useProfile.
  Future<bool> startSpeedForTime(int timeMS, int speed, int maxPower, MotorEndState endState, MotorAccelerationProfile useProfile) async {
    // if (_startSpeedForDegreesThrottle.inProgress) {
    //   _startSpeedForDegreesThrottle.assign(degrees, speed, maxPower, endState, useProfile);
    //   return false;
    // }
    // _startSpeedForDegreesThrottle.inProgress = true;

    SimpleTransaction<PortOutputCommandFeedback> tx = SimpleTransaction<PortOutputCommandFeedback>(
        msgToSend:
            StartSpeedForTimeMessage(portId, PortOutputStartup.BufferIfNeeded, PortOutputCompletion.Feedback, timeMS, speed, maxPower, endState, useProfile));
    PortOutputCommandFeedback? msg = await tx.queue(hub);

    // _startSpeedForDegreesThrottle.inProgress = false;
    //
    // if (_startSpeedForDegreesThrottle.requested) {
    //   startSpeedForDegrees(_startSpeedForDegreesThrottle.degrees, _startSpeedForDegreesThrottle.speed, _startSpeedForDegreesThrottle.maxPower,
    //       _startSpeedForDegreesThrottle.endState, _startSpeedForDegreesThrottle.useProfile);
    //   _startSpeedForDegreesThrottle.requested = false;
    // }

    if (msg == null) {
      return false;
    }
    Helper.dprint("startSpeedForDegrees got $msg");
    return true;
  }
}
