import 'dart:async';

import 'package:flutter_lwp/flutter_lwp.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Connect to hub and list peripherals', () async {
    final IHubScanner scanner = IHubScanner.factory();
    final Timer timeout = new Timer(new Duration(seconds: 5), () => fail("timed out"));

    scanner.stream.listen((HubList hubList) async {
      if (hubList.length < 0) {
        return;
      }

      Hub hub = hubList[0];

      hub.hubStateStream.listen((HubState state) async {
        print(state.peripherals);

        if (state.peripherals.length > 0) {
          expect(state.peripherals.length > 0, equals(true));
          timeout.cancel();
        }
      });

      bool success = await hub.connect();
      if (!success) {
        print("failed to connect");
      }
    });
    scanner.startScanning();
  });
}
