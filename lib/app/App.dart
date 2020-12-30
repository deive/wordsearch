import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:word_search/word_search.dart';
import 'package:wordsearch/app/game/GameState.dart';

import 'MainPage.dart';
import 'AppState.dart';

class App extends StatelessWidget {

  static const String title = "wordsearch";

  static final _random = new Random();
  static List<String> allWords;
  static WordSearch wordSearch;

  final Store<AppState> store = Store<AppState>(
    appReducer, /* Function defined in the reducers file */
    initialState: AppState.initial(),
    middleware: [loadGameMiddleware],
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

  static List<String> pickRandomWords(int numWords) {
    List<String> picked = [];
    for (var i = 0; i < numWords; i++) {
      picked.add(allWords[_random.nextInt(allWords.length)]);
    }
    return picked;
  }

  App() {
    store.dispatch(LoadGameAction());
  }

  @override
  Widget build(BuildContext context) => StoreProvider(
    store: store,
    child: _buildApp(context),
  );

  Widget _buildApp(BuildContext context) {
    var home = MainPage();
    var primaryColorLight = Colors.blue[800];
    var primaryColorDark = Colors.lightBlue[600];
    var secondaryColour = Color.fromARGB(255, 255, 0, 0);
    if (isCupertino) {
      return CupertinoApp(
        title: title,
        theme: CupertinoThemeData(
          primaryColor: primaryColorLight,
          primaryContrastingColor: secondaryColour,
        ),
        home: home,
      );
    }
    else {
      return MaterialApp(
        title: title,
        darkTheme: ThemeData(
          brightness: Brightness.light,
          primaryColor: primaryColorLight,
          sliderTheme: SliderThemeData(activeTrackColor: primaryColorLight, thumbColor: primaryColorLight, inactiveTrackColor: primaryColorDark),
          checkboxTheme: CheckboxThemeData(fillColor: MaterialStateProperty.resolveWith((states) => primaryColorLight)),
        ),
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: primaryColorDark,
          sliderTheme: SliderThemeData(activeTrackColor: primaryColorDark, thumbColor: primaryColorDark, inactiveTrackColor: primaryColorLight),
          checkboxTheme: CheckboxThemeData(fillColor: MaterialStateProperty.resolveWith((states) => primaryColorDark)),
        ),
        home: home,
      );
    }
  }
}