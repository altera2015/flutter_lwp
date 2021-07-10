import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_lwp/flutter_lwp.dart';

class HubPeripheralView extends StatefulWidget {
  final Hub hub;

  HubPeripheralView({required this.hub, Key? key}) : super(key: key);

  @override
  _HubPeripheralViewState createState() => _HubPeripheralViewState();
}

class _HubPeripheralViewState extends State<HubPeripheralView> {
  List<String> _values = [];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    HubState hubState = widget.hub.hubState;

    if (_values.length != hubState.peripherals.length) {
      for (int i = 0; i < hubState.peripherals.length; i++) {
        _values.add("");
      }
    }

    return ListView.builder(
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
        });
  }
}
