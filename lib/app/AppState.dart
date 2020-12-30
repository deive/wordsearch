import 'game/GameState.dart';
import 'settings/SettingsState.dart';

class AppState {
  final GameState game;
  final SettingsState settings;

  AppState(this.game, this.settings);

  factory AppState.initial() => AppState(
    GameState.initial(),
    SettingsState.initial(),
  );

  static AppState fromJson(dynamic json) => AppState(GameState.initial(), json != null ? SettingsState(json["size"], json["wordsHorizontal"], json["wordsVertical"], json["wordsDiagonal"], json["numWords"]) : SettingsState.initial());
  dynamic toJson() => {'size': settings.size, 'wordsHorizontal': settings.wordsHorizontal, 'wordsVertical': settings.wordsVertical, 'wordsDiagonal': settings.wordsDiagonal, 'numWords': settings.numWords};
}

AppState appReducer(AppState state, action) => new AppState(
    gameReducer(state.game, action),
    settingsReducer(state.settings, action)
);