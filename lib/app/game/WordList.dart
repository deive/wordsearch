import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../App.dart';
import '../Model.dart';

class WordListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => StoreConnector<AppState, _ViewModel>(
      converter: (Store<AppState> store) => _ViewModel.create(store),
      builder: (BuildContext context, _ViewModel viewModel) => _buildList(context, viewModel)
  );

  Widget _buildList(BuildContext context, _ViewModel viewModel) {
    var mq = MediaQuery.of(context);
    var height = App.getScreenViewHeight(mq);
    var textHeight = height / 10;

    if (mq.size.width > height) {
      return Column(
        children: viewModel.words.map((e) => Expanded(child: buildWord(e))).toList(growable: false),
      );
    }
    else {
      var wordEntries = viewModel.words.asMap().entries;
      return Row(
        children: [
          Expanded(child: Column(
            children: wordEntries.where((e) => e.key.isEven).map((e) => Expanded(child: buildWord(e.value))).toList(growable: false),
          ),),
          Expanded(child: Column(
            children: wordEntries.where((e) => e.key.isEven).map((e) => Expanded(child: buildWord(e.value))).toList(growable: false),
          ),)
        ],
      );
    }
  }

  Widget buildWord(GameWord word) => Center(child: AutoSizeText(
    word.word,
    style: TextStyle(fontSize: 50),
    textAlign: TextAlign.center,
    maxLines: 1,
  ));
}

class _ViewModel {
  List<GameWord> words;
  _ViewModel(this.words);
  factory _ViewModel.create(Store<AppState> store) => _ViewModel(store.state.words);
}