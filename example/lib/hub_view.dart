import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_lwp/flutter_lwp.dart';

class HubView extends StatefulWidget {
  final IHub hub;

  HubView({required this.hub, Key? key}) : super(key: key);
  @override
  _HubViewState createState() => _HubViewState();
}

class _HubViewState extends State<HubView> {
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

              return Column(
                children: [
                  ...motorWidgets,
                  Expanded(
                    child: ListView.builder(
                        itemCount: hubState.peripherals.length,
                        itemBuilder: (BuildContext context, int index) {
                          Peripheral p = hubState.peripherals[hubState.peripherals.keys.elementAt(index)]!;
                          // if (p.attachedIO.ioType == IOType.LargeMotor) {
                          //   return MotorTile(peripheral: p as MotorPeripheral);
                          // }
                          return ListTile(
                            title: Text(p.attachedIO.ioType.toString()),
                            onTap: () async {
                              await p.interrogate();
                              print(jsonEncode(p.toJsonObject()));
                            },
                          );
                        }),
                  ),
                ],
              );
            }));
  }
}
