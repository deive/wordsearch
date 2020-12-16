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
}

AppState appReducer(AppState state, action) => new AppState(
    gameReducer(state.game, action),
    settingsReducer(state.settings, action)
);