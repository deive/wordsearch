import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import '../Model.dart';

import 'WordSearchCell.dart';

class WordSearchWidget extends StatelessWidget {
  WordSearchWidget(this._cellSize);
  final double _cellSize;
  @override
  Widget build(BuildContext context) => StoreConnector<AppState, _ViewModel>(
      converter: (Store<AppState> store) => _ViewModel.create(store),
      builder: (BuildContext context, _ViewModel viewModel) => Row(
          children: viewModel.cells.map((e) => Expanded(child: Column(
            children: e.map((c) => Expanded(child: WordSearchCell(
              size: _cellSize,
              cell: c,
            ))).toList(),
          ))).toList()
      )
  );
}

class _ViewModel {
  List<List<WordCell>> cells;
  _ViewModel(this.cells);
  factory _ViewModel.create(Store<AppState> store) => _ViewModel(store.state.cells);
}