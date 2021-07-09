import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lwp/flutter_lwp.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'gimbal_stick.dart';

class BuggyCalibration {
  final int left;
  final int right;
  const BuggyCalibration.constant()
      : left = -20,
        right = 20;
  BuggyCalibration(this.left, this.right);

  static Future<BuggyCalibration> loadFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int left = prefs.getInt("left") ?? -20;
    int right = prefs.getInt("right") ?? 20;
    return BuggyCalibration(left, right);
  }

  Future<void> saveToSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("left", left);
    await prefs.setInt("right", right);
  }
}

class BuggyView extends StatefulWidget {
  final Hub? hub;
  final BuggyCalibration calibration;

  BuggyView({required this.hub, this.calibration = const BuggyCalibration.constant(), Key? key}) : super(key: key);

  @override
  _BuggyViewState createState() => _BuggyViewState();

  static Future<BuggyCalibration?> calibrate(Hub hub) async {
    int portId = 1;
    int mode = 2;
    int lastReportedValue = 0;

    MotorPeripheral motor = hub.peripheral(portId) as MotorPeripheral;

    StreamSubscription<Message> sub = hub.transport.stream.where((event) => event is PortValueMessage).listen((Message message) {
      PortValueMessage pv = message as PortValueMessage;
      if (pv.portId == portId) {
        if (pv.value.length == 2) {
          lastReportedValue = Helper.decodeInt16LE(pv.value, 0);
        } else if (pv.value.length == 4) {
          lastReportedValue = Helper.decodeInt32LE(pv.value, 0);
        } else {
          throw Exception("Unexpected length");
        }
      }
    });

    await motor.setInputMode(mode, 1, true);

    int power = 40;
    int speed = 10;
    MotorEndState endState = MotorEndState.Float;

    // await motor.gotoAbsolutePosition(40, speed, power, endState, MotorAccelerationProfile.None);
    await motor.startSpeedForDegrees(60, speed, power, endState, MotorAccelerationProfile.None);
    print("Waiting...");
    await Future.delayed(Duration(seconds: 4));

    int extentA = lastReportedValue;

    await motor.startSpeedForDegrees(60, -speed, power, endState, MotorAccelerationProfile.None);
    print("Waiting...");
    await Future.delayed(Duration(seconds: 4));

    int extentB = lastReportedValue;
    int range = (extentA - extentB).abs();
    BuggyCalibration? calibration;
    if (range < 40) {
      print("Warning didn't get full extent! Range was $range");
    } else {
      int center = ((extentA + extentB) / 2).round();
      await motor.gotoAbsolutePosition(center, speed, power, endState, MotorAccelerationProfile.None);
      print("Range was $extentA, $extentB ($range), center = $center");
      calibration = BuggyCalibration(extentA, extentB);
    }

    await motor.setInputMode(2, 1, false);
    sub.cancel();

    return calibration;
  }
}

class _BuggyViewState extends State<BuggyView> {
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
            if (speed < -95 || speed > 95) {
              HapticFeedback.mediumImpact();
            }

            if (widget.hub != null) {
              await (widget.hub?.peripheral(0) as MotorPeripheral).startSpeed(speed, speed == 0 ? 0 : 100, MotorAccelerationProfile.None);
            }
          },
        )),
        Expanded(
            child: GimbalStick.preMade(
          axis: Axis.horizontal,
          min: widget.calibration.right,
          max: widget.calibration.left,
          minDelta: 1,
          onChanged: (int value) {
            if (value == widget.calibration.right || value == widget.calibration.left) {
              HapticFeedback.mediumImpact();
            }

            if (widget.hub != null) {
              (widget.hub?.peripheral(1) as MotorPeripheral).gotoAbsolutePosition(value, 10, 70, MotorEndState.Hold, MotorAccelerationProfile.None);
            }
          },
        )),
      ];

      late Widget controlContainer;
      if (orientation == Orientation.landscape) {
        controlContainer = Padding(
          padding: const EdgeInsets.all(60.0),
          child: Row(children: [...controls]),
        );
      } else {
        controlContainer = Padding(
          padding: const EdgeInsets.all(60.0),
          child: Column(children: [...controls]),
        );
      }

      return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey,
            Colors.black87,
          ],
        )),
        child: Stack(
          children: [
            Container(
              //color: Colors.yellow,
              padding: EdgeInsets.all(25),
              alignment: Alignment.topLeft,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_back),
              ),
            ),
            controlContainer,
          ],
        ),
      );
    });
  }
}
