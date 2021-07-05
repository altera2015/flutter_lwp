part of flutter_lwp;

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

    int portId = data[offset];
    HubAttachedIOEvent event = HubAttachedIOEventValue.fromInt(data[offset + 1]);

    switch (event) {
      case HubAttachedIOEvent.Attached:
        if (data.length - offset < 12) {
          throw Exception("Not enough data (Attached)");
        }
        int hardwareRevision = Helper.decodeInt32LE(data, offset + 4);
        int softwareRevision = Helper.decodeInt32LE(data, offset + 8);
        return HubAttachedIOMessage(portId, IOTypeValue.fromInt(Helper.decodeInt16LE(data, offset + 2)), hardwareRevision, softwareRevision);

      case HubAttachedIOEvent.Detached:
        return HubDetachedIOMessage(portId);

      case HubAttachedIOEvent.AttachedVirtual:
        if (data.length - offset < 9) {
          throw Exception("Not enough data (AttachedVirtual)");
        }
        int portA = data[offset + 4];
        int portB = data[offset + 5];
        return HubAttachedIOMessage(portId, IOTypeValue.fromInt(Helper.decodeInt16LE(data, offset + 2)), portA, portB);
    }
  }

  String toString() {
    return "HubAttachedIOMessage Message: $portId, $event";
  }
}

class HubAttachedIOMessage extends HubAttachedIOBaseMessage {
  final IOType ioType;
  final int hardwareRevision;
  final int softwareRevision;

  HubAttachedIOMessage(int portId, this.ioType, this.hardwareRevision, this.softwareRevision)
      : super(portId, HubAttachedIOEvent.Attached,
            payload: [ioType.value, ...Helper.encodeInt32LE(hardwareRevision), ...Helper.encodeInt32LE(softwareRevision)]);

  String toString() {
    return "HubAttachedIOMessage Message: port=$portId, event=$event, type=$ioType, hwRev=$hardwareRevision, swRev=$softwareRevision";
  }
}

class HubDetachedIOMessage extends HubAttachedIOBaseMessage {
  HubDetachedIOMessage(int portId) : super(portId, HubAttachedIOEvent.Detached, payload: []);

  String toString() {
    return "HubDetachedIOMessage Message: port=$portId, event=$event";
  }
}

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
