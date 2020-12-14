
import 'package:word_search/word_search.dart';

class AppState {
  final GameState state;
  final Settings settings;
  final List<GameWord> words;
  List<List<WordCell>> cells;

  final WordSearch _wordSearch = WordSearch();
  WSSettings _wordSettings;
  WSNewPuzzle _currentPuzzle;

  AppState(this.state, this.settings, this.words, this.cells) {
    _wordSettings = createSettings();
  }

  factory AppState.initial() {
    var state = AppState(
        GameState.New,
        Settings.initial(),
        AppState._randomWords(),
        List.unmodifiable([])
    );
    state._wordSettings = state.createSettings();
    state._currentPuzzle = state.createPuzzle();
    state.cells = state._currentPuzzle.puzzle.asMap().entries.map((entry) =>
      entry.value.asMap().entries.map((innerEntry) =>
          WordCell(innerEntry.value, entry.key, innerEntry.key)
      ).toList(growable: false)).toList(growable: false);
    return state;
  }

  WSSettings createSettings() {
    var o = [WSOrientation.horizontal];
    if (settings.difficulty != Difficulty.Easy) o.add(WSOrientation.vertical);
    if (settings.difficulty == Difficulty.Hard) o.add(WSOrientation.diagonal);
    return WSSettings(
      width: settings.size,
      height: settings.size,
      orientations: o,
    );
  }

  WSNewPuzzle createPuzzle() {
    return _wordSearch.newPuzzle(words.map((e) => e.word).toList(), _wordSettings);
  }

  static List<GameWord> _randomWords() => ['hello', 'world', 'foo', 'bar', 'baz', 'dart'].map((e) => GameWord(e, false)).toList(growable: false);
}

AppState appReducer(AppState state, action) => state;

enum GameState {
  New, Started, Selecting, Selected, Complete
}

class GameWord {
  String word;
  bool found;
  GameWord(this.word, this.found);
}

class WordCell {
  String letter;
  int x;
  int y;
  WordCell(this.letter, this.x, this.y);
}

class Settings {
  int size;
  Difficulty difficulty;
  Settings(this.size, this.difficulty);
  factory Settings.initial() => Settings(10, Difficulty.Easy);
}

enum Difficulty {
  Easy, Medium, Hard
}