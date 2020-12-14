import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'MainPage.dart';
import 'Model.dart';

class App extends StatelessWidget {

  static const String title = "wordsearch";
  static const Color primaryColour = Color.fromARGB(255, 255, 0, 0);
  static const Color secondaryColour = Color.fromARGB(255, 0, 0, 255);

  final Store<AppState> store = Store<AppState>(
    appReducer, /* Function defined in the reducers file */
    initialState: AppState.initial(),
    //middleware: createStoreMiddleware(),
  );

  static double getScreenViewHeight(MediaQueryData mq) {
    var viewHeight = mq.size.height - mq.padding.top;
    if (kIsWeb)
      return viewHeight;
    if (Platform.isIOS)
      return viewHeight - kMinInteractiveDimensionCupertino;
    else if (Platform.isAndroid)
      return viewHeight - kToolbarHeight;
    else
      return viewHeight;
  }

  static bool showToolbar = !kIsWeb && (Platform.isIOS || Platform.isAndroid);
  static bool isCupertino = !kIsWeb && (Platform.isIOS || Platform.isMacOS);

  @override
  Widget build(BuildContext context) => StoreProvider(
    store: store,
    child: _buildApp(),
  );

  Widget _buildApp() {
    var home = MainPage();
    if (isCupertino) {
      return CupertinoApp(
        title: title,
        theme: CupertinoThemeData(
          primaryColor: primaryColour,
          primaryContrastingColor: secondaryColour,
        ),
        home: home,
      );
    }
    else {
      return MaterialApp(
        title: title,
        theme: ThemeData(
          primarySwatch: Colors.red,
          accentColor: secondaryColour,
        ),
        home: home,
      );
    }
  }
}