import 'package:flutter_lwp/flutter_lwp.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('adds one to input values', () async {
    IHubScanner scanner = IHubScanner.factory();
    scanner.startScanning();
  });
}
