import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../App.dart';
import '../AppState.dart';
import 'SettingsState.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => StoreConnector<AppState, _ViewModel>(
      distinct: true,
      converter: (Store<AppState> store) => _ViewModel.create(store),
      builder: (BuildContext context, _ViewModel viewModel) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!App.showToolbar) AutoSizeText("Settings", style: TextStyle(fontSize: 50, color: Theme.of(context).primaryColor)),
            Expanded(child: Center(
              child: ListView(shrinkWrap: true, children: [
                _forWordSearchSize(context, viewModel),
                _forWordsHorizontal(context, viewModel),
                _forWordsVertical(context, viewModel),
                _forWordsDiagonal(context, viewModel),
                _forNumWords(context, viewModel),
              ]),
            )),
            Text("Any changes will take effect for next new game.", style: TextStyle(color: Theme.of(context).primaryColor)),
          ]
          //_settingsList(context, viewModel),
        );
      }
  );

  List<Widget> _settingsList(BuildContext context, _ViewModel viewModel) {
    List<Widget> list = [];
    if (!App.showToolbar) {
      list.add(AutoSizeText("Settings", style: TextStyle(fontSize: 50, color: Theme.of(context).primaryColor)));
    }
    list.add(Expanded(child: Center(
      child: ListView(shrinkWrap: true, children: [
        _forWordSearchSize(context, viewModel),
        _forWordsHorizontal(context, viewModel),
        _forWordsVertical(context, viewModel),
        _forWordsDiagonal(context, viewModel),
        _forNumWords(context, viewModel),
      ]),
    )));
    list.add(Text("Any changes will take effect for next new game.", style: TextStyle(color: Theme.of(context).primaryColor)));
    return list;
  }

  Widget _forWordSearchSize(BuildContext context, _ViewModel viewModel) => _forSize(context, "Puzzle Size (${viewModel.settings.size} tiles)", viewModel.settings.size, 5, 17, 2, viewModel.onUpdateSize);
  Widget _forWordsHorizontal(BuildContext context, _ViewModel viewModel) => _forWord(context, "Horizontal", viewModel.settings.wordsHorizontal, viewModel.onUpdateWordsHorizontal);
  Widget _forWordsVertical(BuildContext context, _ViewModel viewModel) => _forWord(context, "Vertical", viewModel.settings.wordsVertical, viewModel.onUpdateWordsVertical);
  Widget _forWordsDiagonal(BuildContext context, _ViewModel viewModel) => _forWord(context, "Diagonal", viewModel.settings.wordsDiagonal, viewModel.onUpdateWordsDiagonal);
  Widget _forNumWords(BuildContext context, _ViewModel viewModel) => _forSize(context, "Number of Words (${viewModel.settings.numWords})", viewModel.settings.numWords, 6, 12, 1, viewModel.onUpdateNumWords);

  Widget _forWord(BuildContext context, String title, bool value, Function onChanged) {
    var view;
    if (App.isCupertino) {
      view = CupertinoSwitch(value: value, onChanged: onChanged, activeColor: Theme.of(context).primaryColor);
    } else {
      view = Checkbox(value: value, onChanged: onChanged);
    }
    return _settingsRow(context, title, view);
  }

  Widget _forSize(BuildContext context, String title, int value, int min, int max, int step, Function onChanged) {
    var view;
    if (App.isCupertino) {
      view = CupertinoSlider(value: value.toDouble(), min: min.toDouble(), max: max.toDouble(), divisions: (max - min) ~/ step, onChanged: (double newValue) => onChanged(newValue.toInt()), );
    } else {
      view = Slider(value: value.toDouble(), min: min.toDouble(), max: max.toDouble(), divisions: (max - min) ~/ step, onChanged: (double newValue) => onChanged(newValue.toInt()));
    }
    return _settingsRow(context, title, view);
  }

  Widget _settingsRow(BuildContext context, String title, Widget settingsView) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, textAlign: TextAlign.end, style: TextStyle(color: Theme.of(context).primaryColor)),
        settingsView,
        SizedBox(height: 10),
      ],
    );
  }
}

class _ViewModel {
  SettingsState settings;
  final Function onUpdateSize;
  final Function onUpdateWordsHorizontal;
  final Function onUpdateWordsVertical;
  final Function onUpdateWordsDiagonal;
  final Function onUpdateNumWords;
  _ViewModel(this.settings, this.onUpdateSize, this.onUpdateWordsHorizontal, this.onUpdateWordsVertical, this.onUpdateWordsDiagonal, this.onUpdateNumWords);
  factory _ViewModel.create(Store<AppState> store) => _ViewModel(
      store.state.settings,
        (value) => store.dispatch(UpdateSizeAction(value)),
        (value) => store.dispatch(UpdateWordsHorizontalAction(value)),
        (value) => store.dispatch(UpdateWordsVerticalAction(value)),
        (value) => store.dispatch(UpdateWordsDiagonalAction(value)),
        (value) => store.dispatch(UpdateNumWordsAction(value)),
  );
}