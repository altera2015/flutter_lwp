# flutter_lwp

![Flutter LWP](https://altera2015.github.io/flutter_lwp/lwp.png)

Dart implementation of LWP protocol

# Supports

Currently this library uses flutter_blue as the Bluetooth back-end. This means the library runs on
Android, iOS and MacOS.

The backend can be trivially replaced/augmented when new backends become available.

# Lego Hub support

Currently tested against Hub 2.0 (https://brickset.com/parts/6142536/hub-no-2)

# Getting Started

Have a look at the [example directory](https://github.com/altera2015/flutter_lwp/tree/master/example) 
or the [API topic](https://altera2015.github.io/flutter_lwp/topics/API-topic.html).

The example code allows control of Lego Buggy (42124), and is IMHO better than the
OEM control, which was very jittery. ( remember to hit calibrate at least once with the wheels
off the ground.)

# API Docs

https://altera2015.github.io/flutter_lwp/

# Source code

https://github.com/altera2015/flutter_lwp

# Disclaimer

This product is not written nor endorsed by Lego. It was built using the publicly available LWP
documentation available here:

[Lego LWP documention](https://lego.github.io/lego-ble-wireless-protocol-docs/index.html)