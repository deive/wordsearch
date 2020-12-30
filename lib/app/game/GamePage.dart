import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:math';

import 'WordSearch.dart';
import 'WordList.dart';
import '../App.dart';

class GamePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          var mq = MediaQuery.of(context);
          var height = App.getScreenViewHeight(mq);
          var size = min(mq.size.width / 11, height / 11);
          var wordList = Expanded(child: WordListWidget(), flex: 1);
          var wordSearch = Expanded(child: WordSearchWidget(size), flex: 2);
          if (mq.size.width > height) {
            return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [wordList, wordSearch],
            );
          }
          else {
            return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [wordSearch, wordList],
            );
          }
        }
    );
  }
}