import 'package:flutter/material.dart';
import './directions.dart';
import './bustimings.dart';
import './settings.dart';

class MenuDrawer extends StatefulWidget {
  MenuDrawer() {}
  State<StatefulWidget> createState() {
    return _MenuDrawerState();
  }
}

class _MenuDrawerState extends State<MenuDrawer> {
  void _closeDrawer() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    print('MenuDrawer opened');
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 120.0,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueGrey,
              ),
              child: Center(
                child: Text(
                  'Menu',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            title: Text(
              "Directions",
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Directions()),
              );
            },
          ),
          ListTile(
            title: Text(
              "Bus Timings",
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BusTimings()),
              );
            },
          ),
          ListTile(
            title: Text(
              "Settings",
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Settings()),
              );
            },
          ),
        ],
      ),
    );
  }
}
