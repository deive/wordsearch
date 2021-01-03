import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../AppState.dart';
import 'GameState.dart';

class WordSearchCell extends StatelessWidget {
  WordSearchCell({Key key, this.size, this.cell}) : super(key: key);

  final double size;
  final WordCell cell;

  @override
  Widget build(BuildContext context) => StoreConnector<AppState, _ViewModel>(
    distinct: true,
    converter: (Store<AppState> store) => _ViewModel.create(store),
    builder: (BuildContext context, _ViewModel viewModel) {
      Color begin = cell.lastColor == null ? Theme.of(context).scaffoldBackgroundColor : cell.lastColor;
      Color end = cell.wantedColor == null ? Theme.of(context).scaffoldBackgroundColor : cell.wantedColor;
      return TweenAnimationBuilder(
        tween: ColorTween(begin: begin, end: end),
        builder: (context, value, child) {
          return Container(
            constraints: BoxConstraints.expand(),
            decoration: new BoxDecoration(
                border: Border.all(color: Theme.of(context).primaryColor),
                color: value),
            padding: EdgeInsets.all(size / 10),
            child: FittedBox(
                child: Text(cell.letter,
                    style: TextStyle(
                        color: Theme.of(context).primaryColor
                    )
                )
            ),
          );
        },
        duration: Duration(milliseconds: cell.selected ? 30 : 300),
        onEnd: () => viewModel.onAnimationComplete(cell),
      );
  });
}

class _ViewModel {
  final Function onAnimationComplete;

  _ViewModel(this.onAnimationComplete);

  factory _ViewModel.create(Store<AppState> store) =>
      _ViewModel(
            (cell) => store.dispatch(CellAnimationCompleteAction(cell)),
      );

  @override
  bool operator ==(Object o) => o is _ViewModel;

  @override
  int get hashCode => 1;

}