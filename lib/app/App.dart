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

  static Color _lightThemePrimaryColor = Colors.blue[800];
  static Color _lightThemeAccentColorColor = Colors.lightBlue[400];
  static Color _darkThemePrimaryColor = Colors.lightBlue[600];
  static Color _darkThemeAccentColorColor = Colors.blue[900];

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
  static bool hasDarkTheme = !kIsWeb && Platform.isAndroid;

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
    if (isCupertino) {
      return Theme(
          data: ThemeData(
            brightness: Brightness.dark,
            primaryColor: _darkThemePrimaryColor,
            accentColor: _darkThemeAccentColorColor,
          ), 
          child: CupertinoApp(
            title: title,
            theme: CupertinoThemeData(
              brightness: Brightness.dark,
              primaryColor: _darkThemePrimaryColor,
              primaryContrastingColor: _darkThemeAccentColorColor
            ),
            home: home,
          )
      );
    }
    else {
      return MaterialApp(
        title: title,
        theme: _ThemeMaterialData(!hasDarkTheme),
        darkTheme: _ThemeMaterialData(true),
        home: home,
      );
    }
  }

  ThemeData _ThemeMaterialData(bool dark) {
    if (dark) {
      return ThemeData(
        brightness: Brightness.dark,
        primaryColor: _darkThemePrimaryColor,
        sliderTheme: SliderThemeData(activeTrackColor: _darkThemePrimaryColor, thumbColor: _darkThemePrimaryColor, inactiveTrackColor: _darkThemeAccentColorColor),
        checkboxTheme: CheckboxThemeData(fillColor: MaterialStateProperty.resolveWith((states) => _darkThemePrimaryColor)),
      );
    } else {
      return ThemeData(
        brightness: Brightness.light,
        primaryColor: _lightThemePrimaryColor,
        sliderTheme: SliderThemeData(activeTrackColor: _lightThemePrimaryColor, thumbColor: _lightThemePrimaryColor, inactiveTrackColor: _lightThemeAccentColorColor),
        checkboxTheme: CheckboxThemeData(fillColor: MaterialStateProperty.resolveWith((states) => _lightThemePrimaryColor)),
      );
    }
  }
}