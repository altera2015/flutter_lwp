part of flutter_blue_transport;

/// The flutter_blue transport.
///
/// {@category backend}
class HubTransport extends IHubTransport {
  final BluetoothDevice device;
  final FlutterBlueHubManufacturerData manufacturerData;
  BluetoothService? _service;
  BluetoothCharacteristic? _characteristic;
  StreamSubscription<List<int>>? _subscription;

  StreamController<Message> _controller = StreamController<Message>.broadcast();

  String get name {
    return device.name;
  }

  String get id {
    return device.id.toString();
  }

  Stream<Message> get stream {
    return _controller.stream;
  }

  @override
  Future<bool> connect() async {
    print("Connecting....");
    await this.device.connect();
    List<BluetoothService> services = await device.discoverServices();
    services.forEach((service) {
      if (service.uuid == Guid("00001623-1212-efde-1623-785feabcd123")) {
        _service = service;
      }
    });
    if (_service == null) {
      await disconnect();
      return false;
    }

    _service!.characteristics.forEach((characteristic) {
      if (characteristic.uuid == Guid("00001624 -1212-EFDE-1623-785FEABCD123")) {
        print("Found characteristic");
        _characteristic = characteristic;
      }
    });

    if (_characteristic == null) {
      await disconnect();
      return false;
    }

    await _characteristic!.setNotifyValue(true);
    _subscription = _characteristic!.value.listen((List<int> data) {
      _process(data);
    });

    return true;
  }

  HubTransport(this.device, this.manufacturerData);

  void _process(List<int> data) {
    try {
      if (data.length > 0) {
        Helper.dprint("Received : ${Helper.toHex(data)}");
        Message msg = Message.factory(data);
        print(msg.toString());
        _controller.add(msg);
      }
    } catch (e) {
      print("Could not decode ${e.toString()} ${Helper.toHex(data)}");
    }
  }

  Future<void> disconnect() async {
    print("Disconnecting... $_service, $_characteristic");

    _subscription?.cancel();
    _subscription = null;

    if (_service != null || _characteristic != null) {
      _service = null;
      _characteristic = null;
      await device.disconnect();
      print("Disconnected");
    }
  }

  Future<bool> transmit(Message msg) async {
    if (_characteristic == null) {
      throw Exception("Not connected");
    }
    List<int> data = msg.encode();
    print("Sending: ${Helper.toHex(data)}");
    await _characteristic!.write(data);
    return true;
  }

  void dispose() {
    disconnect();
    _controller.close();
  }
}
