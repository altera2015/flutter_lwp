part of flutter_lwp;

class PeripheralVersion {
  final int major;
  final int minor;
  final int bugFix;
  final int build;
  PeripheralVersion(this.major, this.minor, this.bugFix, this.build);

  factory PeripheralVersion.fromInt32(int v) {
    int major = (v >> 28) & 0x07;
    int minor = (v >> 24) & 0x0f;
    int bugFix = (v >> 16) & 0xff;

    int bcdTop = (bugFix >> 4) & 0xf;
    int bcdBottom = bugFix & 0xf;
    bugFix = bcdTop * 10 + bcdBottom;

    int build = v & 0xffff;
    return PeripheralVersion(major, minor, bugFix, build);
  }

  factory PeripheralVersion.decode(List<int> data, int offset) {
    int v = Helper.decodeInt32BE(data, offset);
    return PeripheralVersion.fromInt32(v);
  }

  List<int> encode() {
    int bugFixBcd = (bugFix / 10).round() << 4 | (bugFix % 10);
    int v = (major << 28) | (minor << 24) | (bugFixBcd << 16) | build;
    return Helper.encodeInt32BE(v);
  }

  String toString() {
    return '$major.$minor.$bugFix ($build)';
  }
}

/// Base class for [HubAttachedIOMessage], [HubDetachedIOMessage] and [HubAttachedVirtualIOMessage]
///
/// {@category messages}
class HubAttachedIOBaseMessage extends Message {
  int portId;
  HubAttachedIOEvent event;

  List<int> payload;

  HubAttachedIOBaseMessage(this.portId, this.event, {this.payload = const []}) : super(messageType: MessageType.HubAttachedIO);

  @override
  List<int> _encode() {
    return [portId, event.value]..addAll(payload);
  }

  factory HubAttachedIOBaseMessage.decode(List<int> data, int offset) {
    if (data.length - offset < 2) {
      throw Exception("Not enough data");
    }

    //print(Helper.toHex(data));
    int portId = data[offset];
    HubAttachedIOEvent event = HubAttachedIOEventValue.fromInt(data[offset + 1]);

    switch (event) {
      case HubAttachedIOEvent.Attached:
        if (data.length - offset < 12) {
          throw Exception("Not enough data (Attached)");
        }
        PeripheralVersion hardwareRevision = PeripheralVersion.decode(data, offset + 4);
        PeripheralVersion softwareRevision = PeripheralVersion.decode(data, offset + 8);
        return HubAttachedIOMessage(portId, IOTypeValue.fromInt(Helper.decodeInt16LE(data, offset + 2)), hardwareRevision, softwareRevision);

      case HubAttachedIOEvent.Detached:
        return HubDetachedIOMessage(portId);

      case HubAttachedIOEvent.AttachedVirtual:
        if (data.length - offset < 9) {
          throw Exception("Not enough data (AttachedVirtual)");
        }
        int portA = data[offset + 4];
        int portB = data[offset + 5];
        return HubAttachedVirtualIOMessage(portId, IOTypeValue.fromInt(Helper.decodeInt16LE(data, offset + 2)), portA, portB);
    }
  }

  String toString() {
    return "HubAttachedIOMessage Message: $portId, $event";
  }
}

/// Fired when a new peripheral is attached or on
/// first connection.
///
/// {@category messages}
class HubAttachedIOMessage extends HubAttachedIOBaseMessage {
  final IOType ioType;
  final PeripheralVersion hardwareRevision;
  final PeripheralVersion softwareRevision;

  HubAttachedIOMessage(int portId, this.ioType, this.hardwareRevision, this.softwareRevision)
      : super(portId, HubAttachedIOEvent.Attached, payload: [ioType.value, ...hardwareRevision.encode(), ...softwareRevision.encode()]);

  String toString() {
    return "HubAttachedIOMessage Message: port=$portId, event=$event, type=$ioType, hwRev=$hardwareRevision, swRev=$softwareRevision";
  }
}

/// Fired when a peripheral is detached.
///
/// {@category messages}
class HubDetachedIOMessage extends HubAttachedIOBaseMessage {
  HubDetachedIOMessage(int portId) : super(portId, HubAttachedIOEvent.Detached, payload: []);

  String toString() {
    return "HubDetachedIOMessage Message: port=$portId, event=$event";
  }
}

/// Fired when a new virtual peripheral is created or on
/// first connection.
///
/// {@category messages}
class HubAttachedVirtualIOMessage extends HubAttachedIOBaseMessage {
  final IOType ioType;
  final int portA;
  final int portB;

  HubAttachedVirtualIOMessage(int portId, this.ioType, this.portA, this.portB)
      : super(portId, HubAttachedIOEvent.Attached, payload: [ioType.value, portA, portB]);

  String toString() {
    return "HubAttachedVirtualIOMessage Message: vport=$portId, event=$event, type=$ioType, portA=$portA, portB=$portB";
  }
}
