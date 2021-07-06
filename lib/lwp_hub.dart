part of flutter_lwp;

/// {@category API}
typedef Future<bool> IHubTransportSendFunction(Message msg);

/// HubState contains the state of the hub
/// This includes which peripherals are attached
/// and if the hub is currently connected.
///
/// {@category API}
class HubState {
  /// map of #Peripherals by port id.
  Map<int, Peripheral> peripherals = {};

  /// connected is true when the hub is
  /// connected.
  bool connected = false;
}

/// The main hub interaction class.
/// {@category API}
class Hub {
  final IHubTransport transport;
  HubState _hubState = HubState();
  StreamSubscription<Message>? _messageStreamSubscription;
  StreamController<HubState> _hubStateStreamController = StreamController.broadcast();

  Hub(this.transport);

  /// returns the name of the hub.
  String get name {
    return transport.name;
  }

  /// returns the identifier of the hub.
  ///
  /// This should not change between connections.
  String get id {
    return transport.id;
  }

  /// Dispose should be called when you are finished with a hub.
  /// it is automatically called when IHubScanner is disposed.
  void dispose() {
    transport.dispose();

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
  Future<bool> connect() async {
    bool success = await transport.connect();
    if (!success) {
      print("Failed to connect;");
      return false;
    }

    _messageStreamSubscription = transport.stream.listen((msg) async {
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
    return true;
  }

  bool _transactionBusy = false;
  Future<void> _processTransaction(Transaction transaction) async {
    await transaction.run(transport.transmit, transport.stream);
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
    transport.disconnect();
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
/// {@category API}
typedef HubList = List<Hub>;
