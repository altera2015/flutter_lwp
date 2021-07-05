part of flutter_lwp;

typedef Future<void> IHubSendFunction(Message msg);

abstract class IHubScanner {
  IHubScanner();

  void dispose();
  void startScanning();
  void stopScanning();
  Stream<HubList> get stream;
  HubList get list;

  factory IHubScanner.factory() {
    // only one transport implemented currently.
    return flutter_blue_transport.HubScanner();
  }
}

class HubState {
  Map<int, Peripheral> peripherals = {};
  bool connected = false;
}

abstract class IHub {
  Future<void> transmit(Message msg);
  String get name;
  Future<bool> connect();

  HubState _hubState = HubState();

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

  Stream<Message> get stream;

  StreamSubscription<Message>? _messageStreamSubscription;
  StreamController<HubState> _hubStateStreamController = StreamController.broadcast();

  Stream<HubState> get hubStateStream {
    return _hubStateStreamController.stream;
  }

  HubState get hubState {
    return _hubState;
  }

  Peripheral? peripheral(int port) {
    return _hubState.peripherals[port];
  }

  void postConnect() {
    _messageStreamSubscription = stream.listen((msg) async {
      if (msg is HubAttachedIOMessage) {
        if (_hubState.peripherals.containsKey(msg.portId)) {
          _hubState.peripherals[msg.portId]!.dispose();
          _hubState.peripherals.remove(msg.portId);
        }
        Peripheral p = Peripheral.factory(this, msg);
        _hubState.peripherals[msg.portId] = p;
        await p.interrogate();
        _hubStateStreamController.add(_hubState);
        print(jsonEncode(p.toJsonObject()));
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
  Future queue(Transaction transaction) {
    _transactions.addLast(transaction);
    _processTransactions();
    return transaction.future;
  }

  Future<void> send(Message message) {
    return queue(Transaction<void>(callback: (send, stream) async {
      await send(message);
      return null;
    }));
  }

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

typedef HubList = List<IHub>;
