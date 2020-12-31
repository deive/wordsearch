import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../App.dart';
import 'GameState.dart';

class WordSearchCell extends StatefulWidget {
  WordSearchCell({Key key, this.size, this.cell}) : super(key: key);

  final double size;
  final WordCell cell;

  @override
  _WordCellState createState() => _WordCellState();
}

class _WordCellState extends State<WordSearchCell> {

  @override
  Widget build(BuildContext context) {
    Color color = widget.cell.selectedFor != null ? widget.cell.selectedFor.color : widget.cell.selected ? App.selectedColor : null;
    return Container(
      constraints: BoxConstraints.expand(),
      decoration: new BoxDecoration(border: Border.all(color: Theme.of(context).primaryColor), color: color),
      padding: EdgeInsets.all(widget.size / 10),
      child: FittedBox(
          child: Text(widget.cell.letter,
            style: TextStyle(color: Theme.of(context).primaryColor))),
    );
  }
}
