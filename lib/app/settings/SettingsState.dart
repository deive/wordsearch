import 'package:word_search/word_search.dart';

class SettingsState {
  final int size;
  final bool wordsHorizontal;
  final bool wordsVertical;
  final bool wordsDiagonal;
  final int numWords;
  WSSettings wordSettings;
  SettingsState(this.size, this.wordsHorizontal, this.wordsVertical, this.wordsDiagonal, this.numWords) {
    wordSettings = _createSettings();
  }

  factory SettingsState.initial() => SettingsState(10, true, true, true, 8);

  WSSettings _createSettings() {
    List<WSOrientation> o = [];
    if (wordsHorizontal) o.add(WSOrientation.horizontal);
    if (wordsVertical) o.add(WSOrientation.vertical);
    if (wordsDiagonal) o.add(WSOrientation.diagonal);
    return WSSettings(
      width: size,
      height: size,
      orientations: o,
    );
  }
}

SettingsState settingsReducer(SettingsState state, action) {
  // if (action is LoadGameAction) return loadGameReducer(state, action);
  // else if (action is NewGameAction) return newGameReducer(state, action);
  // else return state;
  return state;
}