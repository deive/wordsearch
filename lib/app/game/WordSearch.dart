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
            onPointerMove: (event) => viewModel.onSelecting(_cellForKeyAtLocation(viewModel, event, keyCells)),
            onPointerUp: (event) => viewModel.onEndSelecting(_cellForKeyAtLocation(viewModel, event, keyCells)),
            onPointerCancel: (event) => viewModel.onEndSelecting(_cellForKeyAtLocation(viewModel, event, keyCells)),
            child: Row(children: columns));
      });

  WordCell _cellForKeyAtLocation(_ViewModel viewModel, PointerEvent event, Map<GlobalKey, WordCell> keyCells) {
    final key = keyCells.keys.firstWhere((element) => _getRectFromKey(element).contains(event.position), orElse: () => null);
    if (key != null && viewModel.state == GameStateEnum.Selecting) {
      // If we are already selecting, then we take a smaller circle around the cell.
      final rect = _getRectFromKey(key);
      final distance = (rect.center - event.position).distance;
      return distance < (rect.width / 2) ? keyCells[key] : null;
    }
    else return key == null ? null : keyCells[key];
  }

  Rect _getRectFromKey(GlobalKey key) {
    final object = key?.currentContext?.findRenderObject();
    final translation = object?.getTransformTo(null)?.getTranslation();
    final size = object?.semanticBounds?.size;

    if (translation != null && size != null) {
      return new Rect.fromLTWH(
          translation.x, translation.y, size.width, size.height);
    } else {
      return null;
    }
  }
}

class _ViewModel {
  final GameStateEnum state;
  final List<List<WordCell>> cells;
  final Function onSelecting;
  final Function onEndSelecting;

  _ViewModel(this.state, this.cells, this.onSelecting, this.onEndSelecting);

  factory _ViewModel.create(Store<AppState> store) =>
      _ViewModel(store.state.game.state,
            store.state.game.cells,
            (cell) => store.dispatch(SelectCellAction(cell)),
            (cell) => store.dispatch(CompleteSelectingCellAction(cell)),
      );

}
