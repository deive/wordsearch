import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../AppState.dart';

/// Shows how long the game is taking/has taken.
class GameTime extends StatelessWidget {

  @override
  Widget build(BuildContext context) => StoreConnector<AppState, _GameTimeViewModel>(
      distinct: true,
      converter: (Store<AppState> store) => _GameTimeViewModel.create(store),
      builder: (BuildContext context, _GameTimeViewModel viewModel) =>
        viewModel.gameCompleteTime == null ? GameTimer(fromDateTime: viewModel.gameStartTime) : GameDuration(duration: viewModel.gameCompleteTime)
  );
}

class _GameTimeViewModel {
  final DateTime gameStartTime;
  final Duration gameCompleteTime;
  final Function onTimerUpdate;

  _GameTimeViewModel(this.gameStartTime, this.gameCompleteTime, this.onTimerUpdate);

  factory _GameTimeViewModel.create(Store<AppState> store) =>
      _GameTimeViewModel(
          store.state.game.gameStartTime,
          store.state.game.gameCompleteTime,
              () => store.dispatch(0)
      );

  @override
  bool operator ==(Object o) => o is _GameTimeViewModel && gameStartTime == o.gameStartTime && gameCompleteTime == o.gameCompleteTime;

  @override
  int get hashCode => gameStartTime.hashCode ^ gameCompleteTime.hashCode;

}

/// Shows a duration.
class GameDuration extends StatelessWidget {
  final Duration duration;

  const GameDuration({Key key, this.duration}) : super(key: key);

  @override
  Widget build(BuildContext context) => Text(_format(duration));

  _format(Duration d) => d == null ? "00:00" : d.toString().substring(2, 7);

}

/// Shows the duration since a given time, updated every second.
class GameTimer extends StatefulWidget {
  final DateTime fromDateTime;

  const GameTimer({Key key, this.fromDateTime}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GameTimerState();
}

class _GameTimerState extends State<GameTimer> {

  Timer timer;

  @override
  Widget build(BuildContext context) => GameDuration(duration: widget.fromDateTime == null ? null : DateTime.now().difference(widget.fromDateTime));

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => setState(() {}));
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

}

/// Shows how many selection attempts the user has made.
class GameSelections extends StatelessWidget {

  @override
  Widget build(BuildContext context) => StoreConnector<AppState, _GameSelectionsViewModel>(
      distinct: true,
      converter: (Store<AppState> store) => _GameSelectionsViewModel.create(store),
      builder: (BuildContext context, _GameSelectionsViewModel viewModel) => Text("${viewModel.selections}")
  );
}

class _GameSelectionsViewModel {
  final int selections;

  _GameSelectionsViewModel(this.selections);

  factory _GameSelectionsViewModel.create(Store<AppState> store) =>
      _GameSelectionsViewModel(
        store.state.game.selections,
      );

  @override
  bool operator ==(Object o) => o is _GameSelectionsViewModel && selections == o.selections;

  @override
  int get hashCode => selections;

}