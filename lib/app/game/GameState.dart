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
  GameState withSelected(WordCell cell) => GameState(GameStateEnum.Selecting, words, puzzle, cells.map((e) => e.map((c) => c == cell ? c.asSelected() : c).toList(growable: false)).toList(growable: false));

  List<WordCell> getSelected() => cells.map((e) => e.map((e) => e.selected ? e : null).where((e) => e != null && e.selected)).expand((e) => e).toList(growable: false);
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
  bool selected = false;
  WordCell(this.letter, this.x, this.y, { this.selected = false });
  WordCell asSelected() => WordCell(this.letter, this.x, this.y, selected: true);

  @override
  bool operator ==(Object o) => o is WordCell && o.x == x && o.y == y;

  @override
  int get hashCode => x ^ y;

  bool isNextTo(WordCell o) => (x == o.x-1 || x == o.x || x == o.x+1) && (y == o.y-1 || y == o.y || y == o.y+1);

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
  else if (action is SelectCellAction) {
    if (state.state == GameStateEnum.New || state.state == GameStateEnum.Started) {
      // First letter selected
      if (state.state == GameStateEnum.New) {
        // TODO: Dispatch started action, to start a timer or something?
      }
      return state.withSelected(action.cell);
    } else if (state.state == GameStateEnum.Selecting) {
      // Another letter selected
      var selected = state.getSelected();
      if (!selected.contains(action.cell)) {
        if (selected.length == 1) {
          // Allow selection in any direction
          var selectedCell = selected.first;
          if (action.cell.isNextTo(selectedCell))
            return state.withSelected(action.cell);
        }
        else {
          // TODO: Only allow selection if in line with current selection...
          WordCell nextTo, inLineWith;
          if (action.cell.isNextTo(selected.first)) {
            nextTo = selected.first;
            inLineWith = selected[1];
          } else if (action.cell.isNextTo(selected.last)) {
            nextTo = selected.last;
            inLineWith = selected[selected.length - 2];
          }
          else {
            // Not next to the first or last selected, so not in line.
            return state;
          }

          if (nextTo.x == inLineWith.x && action.cell.x == nextTo.x) {
            // Same x, must be different y by 1
            if (nextTo.y == inLineWith.y - 1 && action.cell.y == nextTo.y - 1) return state.withSelected(action.cell);
            else if (nextTo.y == inLineWith.y + 1 && action.cell.y == nextTo.y + 1) return state.withSelected(action.cell);
          } else if (nextTo.y == inLineWith.y && action.cell.y == nextTo.y) {
            // Same y, must be different x by 1
            if (nextTo.x == inLineWith.x - 1 && action.cell.x == nextTo.x - 1) return state.withSelected(action.cell);
            else if (nextTo.x == inLineWith.x + 1 && action.cell.x == nextTo.x + 1) return state.withSelected(action.cell);
          } else {
            // Diagonal, check direction
            if (nextTo.x == inLineWith.x + 1 && nextTo.y == inLineWith.y + 1 && action.cell.x == nextTo.x + 1 && action.cell.y == nextTo.y + 1) return state.withSelected(action.cell);
            else if (nextTo.x == inLineWith.x + 1 && nextTo.y == inLineWith.y - 1 && action.cell.x == nextTo.x + 1 && action.cell.y == nextTo.y - 1) return state.withSelected(action.cell);
            else if (nextTo.x == inLineWith.x - 1 && nextTo.y == inLineWith.y + 1 && action.cell.x == nextTo.x - 1 && action.cell.y == nextTo.y + 1) return state.withSelected(action.cell);
            else if (nextTo.x == inLineWith.x - 1 && nextTo.y == inLineWith.y - 1 && action.cell.x == nextTo.x - 1 && action.cell.y == nextTo.y - 1) return state.withSelected(action.cell);
          }
        }
      }
    }
  }
  return state;
}

GameState newGameReducer(GameState state, NewGameAction action) {
  var words = App.pickRandomWords(action.settings.numWords, action.settings.size).map((e) => GameWord(e, false)).toList(growable: false);
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

class SelectCellAction {
  final WordCell cell;
  SelectCellAction(this.cell);
}