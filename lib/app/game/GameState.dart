import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
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
  // Returns a copy of this state with the given cell selected.
  GameState withSelected(WordCell cell) => GameState(
      GameStateEnum.Selecting, words, puzzle,
      cells.map((e) => e.map((c) => c == cell ? c.asSelected() : c.asWantedComplete()).toList(growable: false)).toList(growable: false)
  );
  // Returns a copy of this state with the given word marked as found, and all cells unselected
  GameState withFound(WordCell cell, GameWord wordFound) {
    var wordsUpdated = words.map((e) => e == wordFound ? e.asFound() : e).toList(growable: false);
    return GameState(
        wordsUpdated.any((e) => !e.found) ? GameStateEnum.Started : GameStateEnum.Complete,
        wordsUpdated,
        puzzle,
        cells.map((e) => e.map((c) => (c.selected || c == cell) ? c.asSelectedFor(wordFound) : c.asWantedComplete()).toList(growable: false)).toList(growable: false)
    );
  }
  // Returns a copy of this state with all cells unselected.
  GameState withAllUnselected() => GameState(
      GameStateEnum.Started, words, puzzle,
      cells.map((e) => e.map((c) => c.selected ? c.asUnselected() : c).toList(growable: false)).toList(growable: false)
  );
  // Returns a copy of this state with the given cell last color marked the same as wanted color.
  GameState withWantedComplete(WordCell cell) => GameState(
      state, words, puzzle,
      cells.map((e) => e.map((c) => c == cell ? c.asWantedComplete() : c).toList(growable: false)).toList(growable: false)
  );
 
  List<WordCell> getSelected() => cells.map((e) => e.map((e) => e.selected ? e : null).where((e) => e != null && e.selected)).expand((e) => e).toList(growable: false);
  List<GameWord> getAvailableWords() => words.where((e) => !e.found).toList(growable: false);
}

enum GameStateEnum {
  Loading, New, Started, Selecting, Selected, Complete
}

class GameWord {
  String word;
  bool found;
  Color color;
  GameWord(this.word, this.found, this.color);
  GameWord asFound() => GameWord(word, true, color);

  @override
  bool operator ==(Object o) => (o is GameWord && o.word == word) || (o is String && o == word);

  @override
  int get hashCode => word.hashCode;
}

class WordCell {
  String letter;
  int x;
  int y;
  bool selected = false;
  GameWord selectedFor;
  Color lastColor;
  Color wantedColor;
  WordCell(this.letter, this.x, this.y, { this.selected = false, this.selectedFor, this.lastColor, this.wantedColor });
  WordCell asSelected() => WordCell(this.letter, this.x, this.y, selected: true, selectedFor: this.selectedFor, lastColor: this.wantedColor, wantedColor: App.selectedColor);
  WordCell asUnselected() => WordCell(this.letter, this.x, this.y, selected: false, selectedFor: this.selectedFor, lastColor: this.wantedColor, wantedColor: selectedFor == null ? null : selectedFor.color);
  WordCell asSelectedFor(GameWord selectedFor) => WordCell(this.letter, this.x, this.y, selected: false, selectedFor: selectedFor, lastColor: this.wantedColor, wantedColor: selectedFor.color);
  WordCell asWantedComplete() => WordCell(this.letter, this.x, this.y, selected: this.selected, selectedFor: this.selectedFor, lastColor: this.wantedColor, wantedColor: this.wantedColor);

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
  if (action is NewGameAction) return _newGameReducer(state, action);
  else if (action is SelectCellAction) return _selectCellReducer(state, action);
  else if (action is CellAnimationCompleteAction) return _cellAnimationCompleteReducer(state, action);
  else if (action is CompleteSelectingCellAction) return _completeSelectingReducer(state, action);
  else return state;
}

GameState _completeSelectingReducer(GameState state, CompleteSelectingCellAction action) {
  if (action.cell != null && state.state == GameStateEnum.Selecting) {
    // Check if word is found
    var selected = state.getSelected();
    var wordF = selected.map((e) => e.letter).join("");
    var wordR = selected.reversed.map((e) => e.letter).join("");
    var words = state.getAvailableWords();
    var foundIndex = words.indexWhere((e) => e.word == wordF);
    if (foundIndex == -1) foundIndex = words.indexWhere((e) => e.word == wordR);
    GameWord foundWord;
    if (foundIndex > -1) {
      foundWord = words[foundIndex];
      return state.withFound(action.cell, foundWord);
    }
    else {
      return state.withAllUnselected();
    }
  }
  return state;
}

GameState _newGameReducer(GameState state, NewGameAction action) {
  var colours = _shuffleList(App.wordColors);
  var words = App.pickRandomWords(action.settings.numWords, action.settings.size).asMap().map((index, e) => MapEntry(index, GameWord(e, false, colours[index]))).values.toList(growable: false);
  var puzzle = App.wordSearch.newPuzzle(words.map((e) => e.word).toList(), action.settings.wordSettings);
  var cells = puzzle.puzzle.asMap().entries.map((entry) =>
      entry.value.asMap().entries.map((innerEntry) =>
          WordCell(innerEntry.value, entry.key, innerEntry.key)
      ).toList(growable: false)).toList(growable: false);
  return GameState(GameStateEnum.New, words, puzzle, cells);
}

GameState _selectCellReducer(GameState state, SelectCellAction action) {
  if (action.cell != null) {
    if (state.state == GameStateEnum.New ||
        state.state == GameStateEnum.Started) {
      // First letter selected
      if (state.state == GameStateEnum.New) {
        // TODO: Dispatch started action, to start a timer or something?
      }
      return state.withSelected(action.cell);
    } else if (state.state == GameStateEnum.Selecting) {
      // Another letter selected
      var selected = state.getSelected();
      if (!selected.contains(action.cell)) {
        bool isSelected = false;
        if (selected.length == 1) {
          // Allow selection in any direction
          var selectedCell = selected.first;
          if (action.cell.isNextTo(selectedCell))
            isSelected = true;
        }
        else {
          isSelected = _canSelectCell(state, action, selected);
        }

        if (isSelected) {
          return state.withSelected(action.cell);
        }
      }
    }
  }
  return state;
}

GameState _cellAnimationCompleteReducer(GameState state, CellAnimationCompleteAction action) {
  if (action.cell != null) {
    return state.withWantedComplete(action.cell);
  }
  return state;
}

class LoadGameAction {}

class NewGameAction {
  final SettingsState settings;
  NewGameAction(this.settings);
}

abstract class CellAction {
  final WordCell cell;
  CellAction(this.cell);
}

class SelectCellAction extends CellAction {
  SelectCellAction(WordCell cell) : super(cell);
}

class CellAnimationCompleteAction extends CellAction {
  CellAnimationCompleteAction(WordCell cell) : super(cell);
}

class CompleteSelectingCellAction extends CellAction {
  CompleteSelectingCellAction(WordCell cell) : super(cell);
}

bool _canSelectCell(GameState state, SelectCellAction action, List<WordCell> selected) {
  // Only allow selection if in line with current selection...
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
    return false;
  }

  if (nextTo.x == inLineWith.x && action.cell.x == nextTo.x) {
    // Same x, must be different y by 1
    if (nextTo.y == inLineWith.y - 1 && action.cell.y == nextTo.y - 1) return true;
    else if (nextTo.y == inLineWith.y + 1 && action.cell.y == nextTo.y + 1) return true;
  } else if (nextTo.y == inLineWith.y && action.cell.y == nextTo.y) {
    // Same y, must be different x by 1
    if (nextTo.x == inLineWith.x - 1 && action.cell.x == nextTo.x - 1) return true;
    else if (nextTo.x == inLineWith.x + 1 && action.cell.x == nextTo.x + 1) return true;
  } else {
    // Diagonal, check direction
    if (nextTo.x == inLineWith.x + 1 &&
        nextTo.y == inLineWith.y + 1 &&
        action.cell.x == nextTo.x + 1 &&
        action.cell.y == nextTo.y + 1)
      return true;
    else if (nextTo.x == inLineWith.x + 1 &&
        nextTo.y == inLineWith.y - 1 &&
        action.cell.x == nextTo.x + 1 &&
        action.cell.y == nextTo.y - 1)
      return true;
    else if (nextTo.x == inLineWith.x - 1 &&
        nextTo.y == inLineWith.y + 1 &&
        action.cell.x == nextTo.x - 1 &&
        action.cell.y == nextTo.y + 1)
      return true;
    else if (nextTo.x == inLineWith.x - 1 &&
        nextTo.y == inLineWith.y - 1 &&
        action.cell.x == nextTo.x - 1 &&
        action.cell.y == nextTo.y - 1)
      return true;
  }
  return false;
}

List _shuffleList(List items) {
  var random = new Random();

  // Go through all elements.
  for (var i = items.length - 1; i > 0; i--) {

    // Pick a pseudorandom number according to the list length
    var n = random.nextInt(i + 1);

    var temp = items[i];
    items[i] = items[n];
    items[n] = temp;
  }

  return items;
}