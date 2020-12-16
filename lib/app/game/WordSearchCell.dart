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
    return Container(
      constraints: BoxConstraints.expand(),
      decoration: new BoxDecoration(color: App.primaryColour, border: Border.all()),
      padding: EdgeInsets.all(widget.size / 10),
      child: FittedBox(child: Text(widget.cell.letter)),
    );
  }
}
