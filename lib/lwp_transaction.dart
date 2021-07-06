part of flutter_lwp;

/// If a transaction has failed and should retry, throw [RetryException] inside the transaction.
/// The [Transaction] class will retry [Transaction.maxTries] number of times.
/// {@category API}
class RetryException {}

/// transactions are used to facilitate communications with the hub.
///
/// Typical message flow is an request and answer pattern. The [SimpleTransaction] handles
/// this most simple case. If there is any other pattern [Transaction] is flexible enough
/// to account for most cases.
///
/// Have a look at the [SimpleTransaction] implementation on how to use this.
///
/// {@category API}
class Transaction<T> {
  final Future<T?> Function(IHubTransportSendFunction send, Stream<Message> stream) callback;
  final Completer<T?> _completer = Completer<T?>();
  final int maxTries;
  Transaction({required this.callback, this.maxTries = 4});

  Future<void> run(IHubTransportSendFunction send, Stream<Message> stream) async {
    for (int i = 0; i < maxTries; i++) {
      try {
        _completer.complete(await callback(send, stream));
        return;
      } catch (e) {
        if (e is RetryException) {
          // Try again if possible.
          print("Attempt ${i + 1} out of $maxTries failed.");
        } else {
          print(e);
          _completer.complete(null);
          return;
        }
      }
    }

    // maxTries exceeded.
    _completer.complete(null);
    return;
  }

  Future<T?> get future {
    return _completer.future;
  }
}

/// Simple transaction provides an easy way to interact with the Hub using the
/// request/response pattern with retries.
///
/// ```
/// SimpleTransaction<PortOutputCommandFeedback> tx = SimpleTransaction<PortOutputCommandFeedback>(
///        msgToSend: StartSpeedMessage(portId, PortOutputStartup.BufferIfNeeded, PortOutputCompletion.Feedback, speed, maxPower, useProfile));
///    PortOutputCommandFeedback? msg = await tx.queue(hub);
/// ```
///
/// {@category API}
class SimpleTransaction<T> extends Transaction<T> {
  final Message msgToSend;

  SimpleTransaction({required this.msgToSend, int maxTries = 4, Duration timeout = const Duration(seconds: 1)})
      : super(
            maxTries: maxTries,
            callback: (IHubTransportSendFunction send, Stream<Message> stream) async {
              await send(msgToSend);

              Message msg = await stream.where((event) => event is T).timeout(timeout, onTimeout: (sink) {
                // on timeout just queue an empty message to break out of
                // wait.
                sink.add(EmptyMessage());
              }).first;

              if (msg is EmptyMessage) {
                // yep, retry if possible.
                throw RetryException();
              }

              if (msg is T) {
                // Cool got the right message.
                return msg as T;
              }

              // bummer somehow we got the wrong message.
              return null;
            });

  Future<T?> queue(Hub hub) async {
    return await hub.queue(this);
  }
}
