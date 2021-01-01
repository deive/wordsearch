import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'GameState.dart';

class WordSearchCell extends StatelessWidget {
  WordSearchCell({Key key, this.size, this.cell}) : super(key: key);

  final double size;
  final WordCell cell;

  @override
  Widget build(BuildContext context) {
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
      duration: Duration(milliseconds: 300),
    );
  }
}
