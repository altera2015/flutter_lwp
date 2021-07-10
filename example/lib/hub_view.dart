import 'package:example/hub_details_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lwp/flutter_lwp.dart';

import 'hub_peripheral_list.dart';

class HubView extends StatefulWidget {
  final Hub hub;

  HubView({required this.hub, Key? key}) : super(key: key);
  @override
  _HubViewState createState() => _HubViewState();
}

class _HubViewState extends State<HubView> {
  int _selectedView = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hub View'),
      ),
      body: StreamBuilder<HubState>(
          stream: widget.hub.hubStateStream,
          initialData: widget.hub.hubState,
          builder: (BuildContext context, AsyncSnapshot<HubState> listSnapShot) {
            if (!listSnapShot.hasData) {
              return Center(child: LinearProgressIndicator());
            }

            switch (_selectedView) {
              case 0:
                return HubDetailView(hub: widget.hub);
              case 1:
                return HubPeripheralView(hub: widget.hub);
              default:
                return Text("Whoops");
            }
          }),
      bottomNavigationBar: BottomNavigationBar(
          onTap: (int index) {
            setState(() {
              _selectedView = index;
            });
          }, // new
          currentIndex: _selectedView, // new
          items: [
            new BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Details',
            ),
            new BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Peripherals',
            ),
          ]),
    );
  }
}
