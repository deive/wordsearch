import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../AppState.dart';
import 'GameState.dart';
import 'WordSearchCell.dart';

class WordSearchWidget extends StatelessWidget {
  WordSearchWidget(this._cellSize);

  final double _cellSize;

  @override
  Widget build(BuildContext context) => StoreConnector<AppState, _ViewModel>(
      distinct: true,
      converter: (Store<AppState> store) => _ViewModel.create(store),
      builder: (BuildContext context, _ViewModel viewModel) {
        Map<GlobalKey, WordCell> keyCells = {};
        var columns = viewModel.cells
            .map((e) => Expanded(
                    child: Column(
                  children: e.map((c) {
                    GlobalKey cellKey = GlobalKey();
                    keyCells[cellKey] = c;
                    return Expanded(key: cellKey,
                        child: WordSearchCell(
                      size: _cellSize,
                      cell: c,
                    ));
                  }).toList(),
                )))
            .toList();
        return Listener(
            onPointerDown: (event) => viewModel.onStartSelecting(_cellForKeyAtLocation(event, keyCells)),
            onPointerMove: (event) => viewModel.onSelecting(_cellForKeyAtLocation(event, keyCells)),
            child: Row(children: columns));
      });

  WordCell _cellForKeyAtLocation(PointerEvent event, Map<GlobalKey, WordCell> keyCells) =>
      keyCells[keyCells.keys.firstWhere((element) => _getRectFromKey(element).contains(event.position))];

  Rect _getRectFromKey(GlobalKey key) {
    var object = key?.currentContext?.findRenderObject();
    var translation = object?.getTransformTo(null)?.getTranslation();
    var size = object?.semanticBounds?.size;

    if (translation != null && size != null) {
      return new Rect.fromLTWH(
          translation.x, translation.y, size.width, size.height);
    } else {
      return null;
    }
  }
}

class _ViewModel {
  List<List<WordCell>> cells;
  final Function onStartSelecting;
  final Function onSelecting;

  _ViewModel(this.cells, this.onStartSelecting, this.onSelecting);

  factory _ViewModel.create(Store<AppState> store) =>
      _ViewModel(store.state.game.cells,
            (cell) => store.dispatch(SelectCellAction(cell)),
            (cell) => store.dispatch(SelectCellAction(cell)),
      );
}
