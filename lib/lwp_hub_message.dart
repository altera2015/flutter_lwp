part of flutter_lwp;

/// Bases class for hub properties.
///
/// {@category messages}
class HubPropertyMessage extends Message {
  HubProperty property;
  HubOperation operation;
  List<int> payload;

  HubPropertyMessage(this.property, this.operation, {this.payload = const []}) : super(messageType: MessageType.HubProperties);

  @override
  List<int> _encode() {
    return [property.value, operation.value]..addAll(payload);
  }

  factory HubPropertyMessage.decode(List<int> data, int offset) {
    if (data.length - offset < 2) {
      throw Exception("Not enough data");
    }

    HubProperty property = HubPropertyValue.fromInt(data[offset]);
    HubOperation operation = HubOperationValue.fromInt(data[offset + 1]);

    var getInt = (List<int> data, int pos, int def) {
      if ((data.length - offset) < pos) {
        return def;
      }
      return data[offset + pos];
    };

    var getBool = (List<int> data, int pos, bool def) {
      return getInt(data, pos, 0) != 0;
    };

    switch (property) {
      case HubProperty.Battery:
        return new HubBatteryPropertyMessage(operation, batteryPct: getInt(data, 2, 0));
      case HubProperty.ButtonState:
        return new HubButtonPropertyMessage(operation, buttonState: getBool(data, 2, false));

      default:
        return new HubPropertyMessage(HubPropertyValue.fromInt(data[offset]), HubOperationValue.fromInt(data[offset + 1]));
    }
  }

  String toString() {
    return "HubProperty Message: $property, $operation";
  }
}

/// Battery State message.
///
/// {@category messages}
class HubBatteryPropertyMessage extends HubPropertyMessage {
  HubBatteryPropertyMessage(HubOperation operation, {int batteryPct = 0}) : super(HubProperty.Battery, operation, payload: [batteryPct]);

  int get state {
    if (payload.length > 0) {
      return payload[0];
    } else {
      return -1;
    }
  }

  String toString() {
    if (payload.length > 0) {
      return "HubBatteryProperty Message: $operation, battery=$state%";
    } else {
      return "HubBatteryProperty Message: $operation";
    }
  }
}

/// Button State message
///
/// {@category messages}
class HubButtonPropertyMessage extends HubPropertyMessage {
  HubButtonPropertyMessage(HubOperation operation, {bool buttonState = false}) : super(HubProperty.ButtonState, operation, payload: [buttonState ? 1 : 0]);

  bool get state {
    if (payload.length > 0) {
      return payload[0] != 0 ? true : false;
    } else {
      return false;
    }
  }

  String toString() {
    if (payload.length > 0) {
      return "HubButtonPropertyMessage Message: $operation, button=$state";
    } else {
      return "HubButtonPropertyMessage Message: $operation";
    }
  }
}
