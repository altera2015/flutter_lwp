import 'package:flutter/material.dart';
import 'package:flutter_lwp/flutter_lwp.dart';

import 'hub_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter LWP example',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'flutter_lwp example'));
    //home: BuggyView(hub: null));
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final IHubScanner _scanner = IHubScanner.factory();

  MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    widget._scanner.startScanning();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: StreamBuilder<HubList>(
            stream: widget._scanner.stream,
            initialData: widget._scanner.list,
            builder: (BuildContext context, AsyncSnapshot<HubList> listSnapShot) {
              if (!listSnapShot.hasData) {
                return Center(child: Text("Loading..."));
              }
              HubList list = listSnapShot.data!;
              print(list);
              return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (BuildContext context, int index) {
                    Hub hub = list[index];
                    return ListTile(
                      title: Text("${hub.name}"),
                      subtitle: Text("${hub.id}"),
                      onTap: () async {
                        hub.connect();
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HubView(hub: hub)),
                        );
                        hub.disconnect();
                      },
                    );
                  });
            }));
  }
}
