part of flutter_blue_transport;

/// The flutter_blue advertising packet.
///
/// {@category backend}
class FlutterBlueHubManufacturerData {
  static const int LegoManufacturerId = 0x0397;

  final bool buttonState;
  final int systemType;
  final int capabilities;

  final int lastNetworkId;
  final int status;
  final int option;

  FlutterBlueHubManufacturerData(
      {required this.buttonState,
      required this.systemType,
      required this.capabilities,
      required this.lastNetworkId,
      required this.status,
      required this.option});

  static FlutterBlueHubManufacturerData? fromList(List<int>? data) {
    if (data == null) {
      return null;
    }

    Helper.dprint("Advertisement data ${Helper.toHex(data)}");

    if (data.length < 6) {
      print("Incorrect length, needs as least 6 bytes");
      return null;
    }

    return FlutterBlueHubManufacturerData(
        buttonState: data[0] != 0, systemType: data[1], capabilities: data[2], lastNetworkId: data[3], status: data[4], option: data[5]);
  }

  @override
  String toString() {
    return "button=$buttonState systemType=$systemType, capability=$capabilities, lastNetwork=$lastNetworkId, status=$status, option=$option";
  }
}

/// The flutter_blue IHubScanner implementation
///
/// {@category backend}
class HubScanner extends IHubScanner {
  static FlutterBlue _flutterBlue = FlutterBlue.instance;

  StreamSubscription<List<ScanResult>>? _subscription;
  StreamController<HubList> _controller = new StreamController();
  Map<String, Hub> _hubs = {};

  HubScanner() {
    _flutterBlue.setLogLevel(LogLevel.critical);
    _subscription = _flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        if (!result.advertisementData.serviceUuids.contains("00001623-1212-efde-1623-785feabcd123")) {
          continue;
        }

        Helper.dprint("Detected ${result.device.name}");

        if (_hubs.containsKey(result.device.id.id)) {
          Helper.dprint("Already have this hub.");
          continue;
        }

        if (Helper.debug) {
          result.advertisementData.serviceData.forEach((key, value) {
            Helper.dprint("service data $key : ${Helper.toHex(value)}");
          });

          result.advertisementData.manufacturerData.forEach((key, value) {
            Helper.dprint("manufacturer data $key : ${Helper.toHex(value)}");
          });

          result.advertisementData.serviceUuids.forEach((element) {
            Helper.dprint("Service uuid: $element");
          });
        }

        if (!result.advertisementData.manufacturerData.containsKey(FlutterBlueHubManufacturerData.LegoManufacturerId)) {
          Helper.dprint("Didn't find expected manufacturer data.");
          continue;
        }

        FlutterBlueHubManufacturerData? hubManufacturerData =
            FlutterBlueHubManufacturerData.fromList(result.advertisementData.manufacturerData[FlutterBlueHubManufacturerData.LegoManufacturerId]);

        if (hubManufacturerData != null) {
          Helper.dprint("Found a hub!!!!");
          Hub hub = new Hub(HubTransport(result.device, hubManufacturerData));
          _hubs[result.device.id.id] = hub;
          _controller.add(this.list);
        }
      }
    });
  }

  @override
  void dispose() {
    _hubs.forEach((key, hub) {
      hub.dispose();
    });
    _hubs.clear();

    _subscription?.cancel();
    _subscription = null;
    _controller.close();
  }

  @override
  void startScanning() {
    _flutterBlue.startScan();
  }

  @override
  void stopScanning() {
    _flutterBlue.stopScan();
  }

  @override
  Stream<HubList> get stream {
    return _controller.stream;
  }

  @override
  HubList get list {
    HubList list = [];
    _hubs.forEach((key, value) {
      list.add(value);
    });
    return list;
  }
}
