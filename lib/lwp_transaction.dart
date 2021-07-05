part of flutter_lwp;

class RetryException {}

class Transaction<T> {
  final Future<T?> Function(IHubSendFunction send, Stream<Message> stream) callback;
  final Completer<T?> _completer = Completer<T?>();
  final int maxTries;
  Transaction({required this.callback, this.maxTries = 4});

  Future<void> run(IHubSendFunction send, Stream<Message> stream) async {
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

class SimpleTransaction<T> extends Transaction<T> {
  final Message msgToSend;

  SimpleTransaction({required this.msgToSend, int maxTries = 4, Duration timeout = const Duration(seconds: 1)})
      : super(
            maxTries: maxTries,
            callback: (IHubSendFunction send, Stream<Message> stream) async {
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

  Future<T?> queue(IHub hub) async {
    return await hub.queue(this);
  }
}
