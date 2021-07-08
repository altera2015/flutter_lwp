import 'package:flutter/material.dart';
import 'package:flutter_lwp/flutter_lwp.dart';

import 'gimbal_stick.dart';

class BuggyView extends StatefulWidget {
  final Hub? hub;

  BuggyView({required this.hub, Key? key}) : super(key: key);

  @override
  _BuggyViewState createState() => _BuggyViewState();

  static calibrate(Hub hub) async {
    // steer to left.

    MotorPeripheral motor = hub.peripheral(1) as MotorPeripheral;

    await motor.setInputMode(2, 1, true);

    int power = 50;
    int speed = 10;
    MotorEndState endState = MotorEndState.Float;

    await motor.gotoAbsolutePosition(30, speed, power, endState, MotorAccelerationProfile.None);
    print("Waiting...");
    await Future.delayed(Duration(seconds: 4));

    await motor.gotoAbsolutePosition(0, speed, power, endState, MotorAccelerationProfile.None);
    print("Waiting...");
    await Future.delayed(Duration(seconds: 4));

    await motor.gotoAbsolutePosition(-30, speed, power, endState, MotorAccelerationProfile.None);
    print("Waiting...");
    await Future.delayed(Duration(seconds: 4));

    await motor.gotoAbsolutePosition(0, speed, power, endState, MotorAccelerationProfile.None);
    print("Waiting...");
    await Future.delayed(Duration(seconds: 4));
  }
}

class _BuggyViewState extends State<BuggyView> {
  int _lastSpeed = 0;
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      List<Widget> controls = [
        Expanded(
            child: GimbalStick.preMade(
          axis: Axis.vertical,
          min: -100,
          max: 100,
          minDelta: 10,
          onChanged: (int speed) async {
            print("Requesting speed $speed");
            if (widget.hub != null) {
              int tempLastSpeed = _lastSpeed;
              _lastSpeed = speed;
              // if (speed == 0) {
              //   await (widget.hub?.peripheral(0) as MotorPeripheral)
              //       .startSpeedForTime(100, tempLastSpeed, 80, MotorEndState.Float, MotorAccelerationProfile.UseBoth);
              // } else {
              await (widget.hub?.peripheral(0) as MotorPeripheral).startSpeed(speed, 80, MotorAccelerationProfile.UseBoth);
              //}
            }
          },
        )),
        Expanded(
            child: GimbalStick.preMade(
          axis: Axis.horizontal,
          min: -30,
          max: 30,
          minDelta: 2,
          onChanged: (int value) {
            if (widget.hub != null) {
              (widget.hub?.peripheral(1) as MotorPeripheral).gotoAbsolutePosition(value, 10, 50, MotorEndState.Hold, MotorAccelerationProfile.None);
            }
          },
        )),
      ];

      if (orientation == Orientation.landscape) {
        return Padding(
          padding: const EdgeInsets.all(60.0),
          child: Row(children: [...controls]),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.all(60.0),
          child: Column(children: [...controls]),
        );
      }
    });
  }
}
