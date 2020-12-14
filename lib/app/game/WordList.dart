import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

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
    const itemPadding = EdgeInsets.only(top: 10, bottom: 10);
    if (mq.size.width > height) {
      return ListView(
        children: viewModel.words.map((e) =>
          Container(padding: itemPadding, child: buildWord(e))
        ).toList(),
      );
    }
    else {
      return StaggeredGridView.count(
        crossAxisCount: 2,
        staggeredTiles: viewModel.words.map((e) => StaggeredTile.fit(1)).toList(growable: false),
        children: viewModel.words.map((e) =>
            Container(height: textHeight, padding: itemPadding, child: buildWord(e),)
        ).toList(),
      );
    }
  }

  Widget buildWord(GameWord word) => AutoSizeText(
    word.word,
    style: TextStyle(fontSize: 50),
    textAlign: TextAlign.center,
    maxLines: 1,
  );
}

class _ViewModel {
  List<GameWord> words;
  _ViewModel(this.words);
  factory _ViewModel.create(Store<AppState> store) => _ViewModel(store.state.words);
}