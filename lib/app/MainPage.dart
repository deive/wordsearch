import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'App.dart';
import 'game/GamePage.dart';
import 'settings/SettingsPage.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Widget> _tabs = [
      GamePage(), // see the FrontPage class
      SettingsPage() // see the SettingsPage class
    ];

    if (App.isCupertino) {
      return CupertinoPageScaffold(
        navigationBar: _cupertinoToolbar(),
        child: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.subject)),
              BottomNavigationBarItem(icon: Icon(Icons.settings)),
            ],
          ),
          tabBuilder: (context, index) => SafeArea(child: _tabs[index]),
        ),
      );
    }
    else {
      return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: _materialToolbar(),
            body: TabBarView(
              children: [
                _tabs[0],
                _tabs[1]
              ],
            ),
            bottomNavigationBar: TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.subject)),
                  Tab(icon: Icon(Icons.settings)),
                ]
            ),
          )
      );
    }
  }

  Widget _cupertinoToolbar() {
    if (App.showToolbar) {
      return CupertinoNavigationBar(middle: Text(App.title),);
    }
    return null;
  }

  Widget _materialToolbar() {
    if (App.showToolbar) {
      return AppBar(title: Text(App.title),);
    }
    return null;
  }
}