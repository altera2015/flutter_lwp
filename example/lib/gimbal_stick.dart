import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/physics.dart';

class GimbalStick extends StatefulWidget {
  final Widget? gimbal;
  final Widget? background;
  final Axis axis;
  final SpringDescription spring;

  final Function(int pos)? onGrabbed;
  final Function(int pos)? onChanged;
  final Function()? onReleased;

  final int min;
  final int max;
  final int minDelta;

  GimbalStick({
    this.gimbal,
    this.background,
    this.axis = Axis.horizontal,
    this.onGrabbed,
    this.onChanged,
    this.onReleased,
    this.spring = const SpringDescription(
      mass: 1,
      stiffness: 120,
      damping: 10,
    ),
    this.min = -100,
    this.max = 100,
    this.minDelta = 1,
    Key? key,
  }) : super(key: key);

  factory GimbalStick.preMade({
    Axis axis = Axis.horizontal,
    Function(int pos)? onGrabbed,
    Function(int pos)? onChanged,
    Function()? onReleased,
    SpringDescription spring = const SpringDescription(
      mass: 1,
      stiffness: 120,
      damping: 10,
    ),
    int min = -100,
    int max = 100,
    int minDelta = 1,
    Key? key,
  }) {
    if (axis == Axis.vertical) {
      return GimbalStick(
        min: min,
        max: max,
        minDelta: minDelta,
        gimbal: Container(
            width: 100.0,
            height: 100.0,
            decoration: new BoxDecoration(
              gradient: RadialGradient(colors: [Colors.blue, Color.fromARGB(255, 10, 0, 150)]),
              shape: BoxShape.circle,
            )),
        background: Container(
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1.0, style: BorderStyle.solid),
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [
                    Colors.grey,
                    Colors.black87,
                  ])),
              width: 110,
            )),
        axis: axis,
        onGrabbed: onGrabbed,
        onChanged: onChanged,
        onReleased: onReleased,
        key: key,
      );
    } else {
      return GimbalStick(
        min: min,
        max: max,
        minDelta: minDelta,
        gimbal: Container(
            width: 100.0,
            height: 100.0,
            decoration: new BoxDecoration(
              gradient: RadialGradient(colors: [Colors.blue, Color.fromARGB(255, 10, 0, 150)]),
              shape: BoxShape.circle,
            )),
        background: Container(
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  border: Border.all(color: Colors.black, width: 1.0, style: BorderStyle.solid),
                  gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [
                    Colors.grey,
                    Colors.black87,
                  ])),
              height: 110,
            )),
        axis: axis,
        onGrabbed: onGrabbed,
        onChanged: onChanged,
        onReleased: onReleased,
        key: key,
      );
    }
  }

  @override
  _GimbalStickState createState() => _GimbalStickState();
}

class _GimbalStickState extends State<GimbalStick> with SingleTickerProviderStateMixin {
  final GlobalKey _box = GlobalKey();
  double _percent = 0.5;
  int? _lastSend;
  Size _size = Size(0, 0);
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addListener(() {
      setState(() {
        _percent = _controller.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _onMove(PointerEvent event) {
    if (widget.axis == Axis.vertical) {
      _percent = min(max(event.localPosition.dy / (_size.height), 0.0), 1.0);
    } else {
      _percent = min(max(event.localPosition.dx / (_size.width), 0.0), 1.0);
    }
    setState(() {});
    return (_percent * (widget.max - widget.min) + widget.min).round();
  }

  void _animateHome() {
    final simulation = SpringSimulation(widget.spring, _percent, 0.5, -1.0);
    _controller.animateWith(simulation);
  }

  void _notifyOfChange(int value, bool forceUpdate) {
    // print("notifyofchange $_lastSend $value");
    if (forceUpdate || // are we forcing an update?
            _lastSend == null || // nothing sent previously?
            ((_lastSend! - value).abs() >= widget.minDelta) || // change larger than delta?
            (value == widget.min && _lastSend! != value) || // almost at the edge?
            (value == widget.max && _lastSend! != value) // almost at the edge?
        ) {
      widget.onChanged?.call(value);
      _lastSend = value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Listener(
        onPointerMove: (PointerEvent event) {
          _notifyOfChange(_onMove(event), false);
        },
        onPointerUp: (PointerEvent event) {
          _animateHome();
          _notifyOfChange(((widget.max - widget.min) * 0.5 + widget.min).round(), true);
          widget.onReleased?.call();
        },
        onPointerDown: (PointerEvent event) {
          _controller.stop();

          final ctx = _box.currentContext;
          if (ctx != null) {
            RenderBox box = ctx.findRenderObject() as RenderBox;
            _size = box.size;
          }
          int v = _onMove(event);
          _notifyOfChange(v, false);
          widget.onGrabbed?.call(v);
        },
        child: Stack(
          children: [
            Container(key: _box, child: widget.background ?? Container(color: Colors.black)),
            Container(
                alignment: (widget.axis == Axis.vertical)
                    ? Alignment.lerp(Alignment.topCenter, Alignment.bottomCenter, _percent)
                    : Alignment.lerp(Alignment.centerLeft, Alignment.centerRight, _percent),
                child: widget.gimbal ??
                    Container(
                        width: 100.0,
                        height: 100.0,
                        decoration: new BoxDecoration(
                          color: Colors.yellow,
                          shape: BoxShape.circle,
                        ))),
          ],
        ),
      ),
    );
  }
}
