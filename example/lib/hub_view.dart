import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_lwp/flutter_lwp.dart';

import 'buggy_42124.dart';

class HubView extends StatefulWidget {
  final Hub hub;

  HubView({required this.hub, Key? key}) : super(key: key);
  @override
  _HubViewState createState() => _HubViewState();
}

class _HubViewState extends State<HubView> {
  List<String> _values = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Hub View'),
        ),
        body: StreamBuilder<HubState>(
            stream: widget.hub.hubStateStream,
            initialData: widget.hub.hubState,
            builder: (BuildContext context, AsyncSnapshot<HubState> listSnapShot) {
              if (!listSnapShot.hasData) {
                return Center(child: LinearProgressIndicator());
              }
              HubState hubState = listSnapShot.data!;

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
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              motor.startSpeed(100, 50, MotorAccelerationProfile.None);
                            },
                            child: Text("100%")),
                        ElevatedButton(
                            onPressed: () {
                              motor.startSpeed(0, 50, MotorAccelerationProfile.None);
                            },
                            child: Text("Stop"))
                      ],
                    ),
                  )
                ]);
              });

              if (_values.length != hubState.peripherals.length) {
                for (int i = 0; i < hubState.peripherals.length; i++) {
                  _values.add("");
                }
              }

              return Column(
                children: [
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
                  ...motorWidgets,
                  Expanded(
                    child: ListView.builder(
                        itemCount: hubState.peripherals.length,
                        itemBuilder: (BuildContext context, int index) {
                          Peripheral p = hubState.peripherals[hubState.peripherals.keys.elementAt(index)]!;

                          return ListTile(
                            leading: GestureDetector(
                                onTap: () async {
                                  if (p is VoltagePeripheral) {
                                    _values[index] = (await p.getVoltage()).toStringAsFixed(1);
                                    setState(() {});
                                  }
                                  if (p is CurrentPeripheral) {
                                    _values[index] = (await p.getCurrent()).toStringAsFixed(1);
                                    print(_values[index]);
                                    setState(() {});
                                  }
                                  if (p is TemperaturePeripheral) {
                                    _values[index] = (await p.getTemperature()).toStringAsFixed(1);
                                    setState(() {});
                                  }
                                  if (p is AccelerationPeripheral) {
                                    _values[index] = (await p.getAcceleration()).toString();
                                    setState(() {});
                                  }
                                  if (p is GyroPeripheral) {
                                    _values[index] = (await p.getGyro()).toString();
                                    setState(() {});
                                  }
                                  if (p is OrientationPeripheral) {
                                    _values[index] = (await p.getOrientation()).toString();
                                    setState(() {});
                                  }
                                  if (p is GesturePeripheral) {
                                    _values[index] = (await p.getGesture()).toString();
                                    setState(() {});
                                  }
                                },
                                child: Container(
                                    width: 45,
                                    height: 45,
                                    margin: EdgeInsets.all(4.0),
                                    decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                                    child: Icon(Icons.refresh))),
                            title: Text("${p.attachedIO.ioType.toString()} ${p.portId.toRadixString(16)}"),
                            subtitle: Text(_values[index]),
                            onTap: () async {
                              await p.interrogate();
                              log(jsonEncode(p.toJsonObject()));
                            },
                            onLongPress: () async {
                              if (p is HubStatusLightPeripheral) {
                                p.setColor(0, 1);
                              }
                            },
                          );
                        }),
                  ),
                ],
              );
            }));
  }
}
