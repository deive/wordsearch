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

  SettingsState copyWith({ int size, bool wordsHorizontal, bool wordsVertical, bool wordsDiagonal, int numWords }) {
    return SettingsState(
      size ?? this.size,
      wordsHorizontal ?? this.wordsHorizontal,
      wordsVertical ?? this.wordsVertical,
      wordsDiagonal ?? this.wordsDiagonal,
      numWords ?? this.numWords,
    );
  }

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
  if (action is UpdateSizeAction) return state.copyWith(size: action.size);
  else if (action is UpdateWordsHorizontalAction) return state.copyWith(wordsHorizontal: action.useDirection);
  else if (action is UpdateWordsVerticalAction) return state.copyWith(wordsVertical: action.useDirection);
  else if (action is UpdateWordsDiagonalAction) return state.copyWith(wordsDiagonal: action.useDirection);
  else if (action is UpdateNumWordsAction) return state.copyWith(numWords: action.size);
  else return state;
}

class UpdateSizeAction extends _UpdateSizeAction {
  UpdateSizeAction(int size) : super(size);
}
class UpdateWordsHorizontalAction extends _UpdateWordsDirectionAction {
  UpdateWordsHorizontalAction(bool useDirection) : super(useDirection);
}
class UpdateWordsVerticalAction extends _UpdateWordsDirectionAction {
  UpdateWordsVerticalAction(bool useDirection) : super(useDirection);
}
class UpdateWordsDiagonalAction extends _UpdateWordsDirectionAction {
  UpdateWordsDiagonalAction(bool useDirection) : super(useDirection);
}
class UpdateNumWordsAction extends _UpdateSizeAction {
  UpdateNumWordsAction(int size) : super(size);
}
abstract class _UpdateWordsDirectionAction {
  final bool useDirection;
  _UpdateWordsDirectionAction(this.useDirection);
}
abstract class _UpdateSizeAction {
  final int size;
  _UpdateSizeAction(this.size);
}