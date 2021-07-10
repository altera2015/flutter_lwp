import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_lwp/flutter_lwp.dart';

import 'buggy_42124.dart';

class _Orientation {
  final double value;
  final String name;

  _Orientation(this.value, this.name);

  static List<_Orientation> fromSI(List<double> values) {
    return [
      _Orientation(values[0], "YAW"),
      _Orientation(values[1], "PITCH"),
      _Orientation(values[2], "ROLL"),
    ];
  }
}

class HubDetailView extends StatefulWidget {
  final Hub hub;
  HubDetailView({required this.hub, Key? key}) : super(key: key);

  @override
  _HubDetailViewState createState() => _HubDetailViewState();
}

class _HubDetailViewState extends State<HubDetailView> {
  bool _haveSetupOrientationNotifications = false;

  void _setupOrientation() async {
    if (_haveSetupOrientationNotifications) {
      return;
    }

    Peripheral? p = widget.hub.peripheral(99);
    if (p == null) {
      print("Unable to find orientation");
      return;
    }
    await p.setInputMode(0, 2, true);
    _haveSetupOrientationNotifications = true;
  }

  List<charts.Series<_Orientation, String>> _loadOrientationData(List<double> siValues) {
    List<_Orientation> data = _Orientation.fromSI(siValues);

    return [
      new charts.Series<_Orientation, String>(
        id: 'Orientation',
        domainFn: (_Orientation o, _) => o.name,
        measureFn: (_Orientation o, _) => o.value,
        data: data,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    _setupOrientation(); // we get rebuilt every time there is a new Peripheral,... so keep an eye on it.

    List<MotorPeripheral> motors = [];

    for (int i = 0; i < 4; i++) {
      if (widget.hub.peripheral(i) is MotorPeripheral) {
        motors.add(widget.hub.peripheral(i) as MotorPeripheral);
      }
    }

    List<Widget> motorWidgets = [];

    motors.forEach((motor) {
      motorWidgets.addAll([
        ListTile(
          title: Text("Motor on port ${motor.attachedIO.portId}"),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                  onPressed: () {
                    motor.startSpeed(-100, 50, MotorAccelerationProfile.None);
                  },
                  child: Text("-100%")),
              ElevatedButton(
                  onPressed: () {
                    motor.startSpeed(-50, 50, MotorAccelerationProfile.None);
                  },
                  child: Text("-50%")),
              ElevatedButton(
                  onPressed: () {
                    motor.startSpeed(0, 50, MotorAccelerationProfile.None);
                  },
                  child: Text("Stop")),
              ElevatedButton(
                  onPressed: () {
                    motor.startSpeed(50, 50, MotorAccelerationProfile.None);
                  },
                  child: Text("50%")),
              ElevatedButton(
                  onPressed: () {
                    motor.startSpeed(100, 50, MotorAccelerationProfile.None);
                  },
                  child: Text("100%")),
            ],
          ),
        )
      ]);
    });

    return ListView(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
              onPressed: () async {
                BuggyCalibration calibration = await BuggyCalibration.loadFromSharedPreferences();
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BuggyView(
                            hub: widget.hub,
                            calibration: calibration,
                          )),
                );
              },
              child: Text("Use Buggy View")),
          ElevatedButton(
              onPressed: () async {
                BuggyCalibration? calibration = await BuggyView.calibrate(widget.hub);
                if (calibration != null) {
                  await calibration.saveToSharedPreferences();
                }
              },
              child: Text("Calibrate Steering"))
        ],
      ),
      Divider(),
      Text(_haveSetupOrientationNotifications ? "Orientation Sensor" : ""),
      StreamBuilder<PeripheralValueNotification>(
          stream: widget.hub.peripheral(99)?.stream,
          builder: (BuildContext context, AsyncSnapshot<PeripheralValueNotification> snapshot) {
            if (!snapshot.hasData) {
              return Text("waiting for data...");
            }

            PeripheralValueNotification notification = snapshot.data!;
            return Container(
              height: 150,
              child: charts.BarChart(
                _loadOrientationData(notification.siValues),
                primaryMeasureAxis: charts.NumericAxisSpec(viewport: charts.NumericExtents(-180, 180)),
                animate: false,
                vertical: false,
              ),
            );
          }),
      Divider(),
      ...motorWidgets,
    ]);
  }
}
