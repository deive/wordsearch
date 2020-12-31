import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../App.dart';
import '../AppState.dart';
import 'GameState.dart';

class WordListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => StoreConnector<AppState, _ViewModel>(
      distinct: true,
      converter: (Store<AppState> store) => _ViewModel.create(store),
      builder: (BuildContext context, _ViewModel viewModel) => _buildList(context, viewModel)
  );

  Widget _buildList(BuildContext context, _ViewModel viewModel) {
    var wordList = _buildWordListList(context, viewModel);
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        wordList,
        if (App.isCupertino)
          CupertinoButton(child: Icon(CupertinoIcons.restart), onPressed: viewModel.onRestartGame)
        else
          IconButton(icon: Icon(Icons.refresh), onPressed: viewModel.onRestartGame)
      ],
    );
  }

  Widget _buildWordListList(BuildContext context, _ViewModel viewModel) {
    var mq = MediaQuery.of(context);
    var height = App.getScreenViewHeight(mq);

    if (mq.size.width > height) {
      return Column(
        children: viewModel.words.map((e) => Expanded(child: buildWord(context, e))).toList(growable: false),
      );
    }
    else {
      var wordEntries = viewModel.words.asMap().entries;
      return Row(
        children: [
          Expanded(child: Column(
            children: wordEntries.where((e) => e.key.isEven).map((e) => Expanded(child: buildWord(context, e.value))).toList(growable: false),
          ),),
          Expanded(child: Column(
            children: wordEntries.where((e) => e.key.isOdd).map((e) => Expanded(child: buildWord(context, e.value))).toList(growable: false),
          ),)
        ],
      );
    }
  }

  Widget buildWord(BuildContext context, GameWord word) => Center(child: AutoSizeText(
    word.word,
    style: TextStyle(
        fontSize: 50,
        color: word.color,
        decoration: word.found ? TextDecoration.lineThrough : null),
    textAlign: TextAlign.center,
    maxLines: 1,
  ));
}

class _ViewModel {
  List<GameWord> words;
  final Function onRestartGame;
  _ViewModel(this.words, this.onRestartGame);
  factory _ViewModel.create(Store<AppState> store) => _ViewModel(
      store.state.game.words,
      () => store.dispatch(NewGameAction(store.state.settings))
  );
}