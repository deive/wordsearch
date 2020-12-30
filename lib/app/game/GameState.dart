import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:redux/redux.dart';
import 'package:word_search/word_search.dart';

import '../App.dart';
import '../AppState.dart';
import '../settings/SettingsState.dart';

class GameState {
  final GameStateEnum state;
  final List<GameWord> words;
  final WSNewPuzzle puzzle;
  final List<List<WordCell>> cells;
  GameState(this.state, this.words, this.puzzle, this.cells);

  factory GameState.initial() => GameState(GameStateEnum.Loading, null, null, null);
}

enum GameStateEnum {
  Loading, New, Started, Selecting, Selected, Complete
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

void loadGameMiddleware(Store<AppState> store, action, NextDispatcher next) {
  if (action is LoadGameAction) {
    rootBundle.loadString("assets/words.json").then((String value) {
      App.allWords = jsonDecode(value).cast<String>();
      App.wordSearch = WordSearch();
      store.dispatch(new NewGameAction(store.state.settings));
    });
  }
  next(action);
}

GameState gameReducer(GameState state, action) {
  if (action is NewGameAction) return newGameReducer(state, action);
  else return state;
}

GameState newGameReducer(GameState state, NewGameAction action) {
  var words = App.pickRandomWords(action.settings.numWords).map((e) => GameWord(e, false)).toList(growable: false);
  var puzzle = App.wordSearch.newPuzzle(words.map((e) => e.word).toList(), action.settings.wordSettings);
  var cells = puzzle.puzzle.asMap().entries.map((entry) =>
      entry.value.asMap().entries.map((innerEntry) =>
          WordCell(innerEntry.value, entry.key, innerEntry.key)
      ).toList(growable: false)).toList(growable: false);
  return GameState(GameStateEnum.New, words, puzzle, cells);
}

class LoadGameAction {}

class NewGameAction {
  final SettingsState settings;
  NewGameAction(this.settings);
}