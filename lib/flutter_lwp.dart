/// flutter_lwp contains the functionality to interact with Lego PoweredUp hubs using the LWP protocol.
///
/// Disclaimer: This code was not written nor endorsed by Lego. It was written based on
/// the protocol definitions published by Lego [here](https://lego.github.io/lego-ble-wireless-protocol-docs/).
///
/// Getting started
/// ---------------
///
/// The entry point for the library is the [IHubScanner] and [Hub].
///
library flutter_lwp;

import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'flutter_blue/transport.dart' as flutter_blue_transport;

part 'lwp_constants.dart';
part 'lwp_error_message.dart';
part 'lwp_hub.dart';
part "lwp_hub_attached_io.dart";
part 'lwp_hub_message.dart';
part 'lwp_ihub_scanner.dart';
part 'lwp_ihub_transport.dart';
part 'lwp_message.dart';
part 'lwp_motor_peripheral.dart';
part 'lwp_output_command.dart';
part 'lwp_peripheral.dart';
part 'lwp_port_format_setup.dart';
part 'lwp_port_information.dart';
part 'lwp_port_information_request.dart';
part 'lwp_port_mode_information.dart';
part 'lwp_port_mode_information_request.dart';
part 'lwp_port_output_command_feedback.dart';
part 'lwp_port_value.dart';
part 'lwp_transaction.dart';

/// @nodoc
/// Internal class useful for decoding the LWP data.
class Helper {
  static bool debug = false;

  static List<int> encodeInt16LE(int d) {
    List<int> res = [];
    ByteData bd = ByteData(2);
    bd.setInt16(0, d, Endian.little);
    for (int i = 0; i < bd.lengthInBytes; i++) {
      res.add(bd.getUint8(i));
    }
    return res;
  }

  static int decodeInt16LE(List<int> data, int offset) {
    ByteData bd = ByteData(2);
    for (int i = 0; i < bd.lengthInBytes; i++) {
      bd.setInt8(i, data[offset + i]);
    }
    return bd.getInt16(0, Endian.little);
  }

  static int decodeInt32BE(List<int> data, int offset) {
    ByteData bd = ByteData(4);
    for (int i = 0; i < bd.lengthInBytes; i++) {
      bd.setInt8(i, data[offset + i]);
    }
    return bd.getInt32(0, Endian.big);
  }

  static List<int> encodeInt32BE(int d) {
    List<int> res = [];
    ByteData bd = ByteData(4);
    bd.setInt32(0, d, Endian.big);
    for (int i = 0; i < bd.lengthInBytes; i++) {
      res.add(bd.getUint8(i));
    }

    return res;
  }

  static int decodeInt32LE(List<int> data, int offset) {
    ByteData bd = ByteData(4);
    for (int i = 0; i < bd.lengthInBytes; i++) {
      bd.setInt8(i, data[offset + i]);
    }
    return bd.getInt32(0, Endian.little);
  }

  static List<int> encodeInt32LE(int d) {
    List<int> res = [];
    ByteData bd = ByteData(4);
    bd.setInt32(0, d, Endian.little);
    for (int i = 0; i < bd.lengthInBytes; i++) {
      res.add(bd.getUint8(i));
    }

    return res;
  }

  static List<int> encodeFloat32(double v) {
    List<int> res = [];
    ByteData bd = ByteData(4);
    bd.setFloat32(0, v, Endian.little);
    for (int i = 0; i < bd.lengthInBytes; i++) {
      res.add(bd.getUint8(i));
    }

    return res;
  }

  static String decodeStr(List<int> data, int offset) {
    String s = "";
    for (int i = offset; i < data.length; i++) {
      if (data[i] != 0) {
        s = s + String.fromCharCode(data[i]);
      }
    }
    return s;
  }

  static List<int> encodeStr(String v) {
    List<int> values = [];
    for (int i = 0; i < v.length; i++) {
      values.add(v.codeUnitAt(i) & 0xff);
    }
    return values;
  }

  static double decodeFloat32(List<int> data, int offset) {
    ByteData bd = ByteData(4);

    for (int i = 0; i < bd.lengthInBytes; i++) {
      bd.setInt8(i, data[offset + i]);
    }

    return bd.getFloat32(0, Endian.little);
  }

  static toHex(List<int> data) {
    String dump = "data=[";
    data.forEach((element) {
      dump = dump + element.toRadixString(16) + ",";
    });
    return dump + "]";
  }

  static void dprint(String s) {
    if (debug) {
      print(s);
    }
  }
}
