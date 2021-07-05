part of flutter_lwp;

typedef Future<void> IHubSendFunction(Message msg);

/// The main class used to discover hubs.
abstract class IHubScanner {
  IHubScanner();

  /// dispose should be called when done with the scanner.
  /// this will also destroy all hubs attached.
  void dispose();

  /// starts scanning for the hub, depending on the backend
  /// implementation. Currently this scans for Bluetooth
  /// hubs.
  void startScanning();

  /// Stop scanning for Hubs.
  void stopScanning();

  /// This stream is updated whenever the list of hubs
  /// changes.
  Stream<HubList> get stream;

  /// The hub list.
  /// This is not a copy of the list so don't modify it.
  HubList get list;

  /// IHubScanner factory. Used to instantiate an
  /// object of IHubScanner depending on what platform
  /// it is running on.
  factory IHubScanner.factory() {
    // only one transport implemented currently.
    return flutter_blue_transport.HubScanner();
  }
}

/// HubState contains the state of the hub
/// This includes which peripherals are attached
/// and if the hub is currently connected.
class HubState {
  /// map of #Peripherals by port id.
  Map<int, Peripheral> peripherals = {};

  /// connected is true when the hub is
  /// connected.
  bool connected = false;
}

/// The main hub interaction class.
abstract class IHub {
  HubState _hubState = HubState();
  StreamSubscription<Message>? _messageStreamSubscription;
  StreamController<HubState> _hubStateStreamController = StreamController.broadcast();

  /// transmit places the message on the wire immediately
  /// this bypasses the transaction mechanism completely.
  /// implemented in the backend.
  Future<void> transmit(Message msg);

  /// returns the name of the hub
  String get name;

  /// Initiates the connection to the hub.
  Future<bool> connect();

  /// Broadcast stream of messages coming from the hub hardware.
  Stream<Message> get stream;

  /// Dispose should be called when you are finished with a hub.
  /// it is automatically called when IHubScanner is disposed.
  void dispose() {
    _messageStreamSubscription?.cancel();
    _messageStreamSubscription = null;
    _hubState.peripherals.forEach((key, value) {
      value.dispose();
    });
    _hubState.peripherals.clear();
    _transactions.clear();
    _hubStateStreamController.close();
  }

  /// Stream to listen to hub state changes
  Stream<HubState> get hubStateStream {
    return _hubStateStreamController.stream;
  }

  /// Access the hub state.
  HubState get hubState {
    return _hubState;
  }

  /// access a peripheral directly.
  Peripheral? peripheral(int port) {
    return _hubState.peripherals[port];
  }

  /// internal function called from backend. Don't use.
  void postConnect() {
    _messageStreamSubscription = stream.listen((msg) async {
      if (msg is HubAttachedIOMessage) {
        if (_hubState.peripherals.containsKey(msg.portId)) {
          _hubState.peripherals[msg.portId]!.dispose();
          _hubState.peripherals.remove(msg.portId);
        }
        Peripheral p = Peripheral.factory(this, msg);
        _hubState.peripherals[msg.portId] = p;
        // await p.interrogate();
        _hubStateStreamController.add(_hubState);
        // print(jsonEncode(p.toJsonObject()));
      }

      if (msg is HubDetachedIOMessage) {
        if (_hubState.peripherals.containsKey(msg.portId)) {
          _hubState.peripherals[msg.portId]!.dispose();
          _hubState.peripherals.remove(msg.portId);
          _hubStateStreamController.add(_hubState);
        }
      }
    });

    _hubState.connected = true;
    _hubStateStreamController.add(_hubState);
  }

  bool _transactionBusy = false;
  Future<void> _processTransaction(Transaction transaction) async {
    await transaction.run(transmit, stream);
    _processTransactions();
  }

  void _processTransactions() async {
    if (_transactionBusy) {
      return;
    }

    _transactionBusy = true;
    while (_transactions.length > 0) {
      Transaction tx = _transactions.removeFirst();
      await _processTransaction(tx);
    }
    _transactionBusy = false;
  }

  Queue<Transaction> _transactions = Queue<Transaction>();

  /// Messages to the hub tend to be request response patterns
  /// queue takes a #Transaction object that hides the complications
  /// from the user.
  Future queue(Transaction transaction) {
    _transactions.addLast(transaction);
    _processTransactions();
    return transaction.future;
  }

  /// Sends a message to he hub without waiting for a response. It is
  /// still queued in the transaction system waiting for a slot.
  Future<void> send(Message message) {
    return queue(Transaction<void>(callback: (send, stream) async {
      await send(message);
      return null;
    }));
  }

  /// Disconnect from the Hub.
  Future<void> disconnect() async {
    _messageStreamSubscription?.cancel();
    _messageStreamSubscription = null;
    _hubState.peripherals.forEach((key, value) {
      value.dispose();
    });
    _hubState.peripherals.clear();
    _transactions.clear();
    _hubState.connected = false;
  }
}

/// List of Hubs.
typedef HubList = List<IHub>;
