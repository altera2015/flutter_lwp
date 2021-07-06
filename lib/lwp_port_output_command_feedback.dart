part of flutter_lwp;

/// {@category messages}
class PortOutputCommandFeedbackPort {
  final int portId;
  final List<PortOutputFeedback> feedback;
  PortOutputCommandFeedbackPort(this.portId, this.feedback);
}

/// {@category messages}
class PortOutputCommandFeedback extends Message {
  List<PortOutputCommandFeedbackPort> ports;

  PortOutputCommandFeedback(this.ports) : super(messageType: MessageType.PortOutputCommandFeedback);

  @override
  List<int> _encode() {
    List<int> data = [];
    ports.forEach((element) {
      data.add(element.portId);
      data.add(PortOutputFeedbackValue.fromList(element.feedback));
    });
    return data;
  }

  factory PortOutputCommandFeedback.decode(List<int> data, int offset) {
    if (data.length - offset < 2) {
      throw Exception("Not enough data");
    }

    List<PortOutputCommandFeedbackPort> ports = [];

    for (int i = offset; i < data.length; i += 2) {
      ports.add(PortOutputCommandFeedbackPort(data[i], PortOutputFeedbackValue.toList(data[i + 1])));
    }

    return PortOutputCommandFeedback(ports);
  }

  String toString() {
    String s = "PortOutputCommandFeedback Message\n";
    ports.forEach((element) {
      s += "${element.portId} - ${element.feedback}\n";
    });
    return s;
  }
}
