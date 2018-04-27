import 'package:blackjack/blackjack.dart';
import 'package:blackjack/blackjack_ui.dart';
import 'package:blackjack/blackjack_ui_graphics.dart';
import 'package:blackjack/controller.dart';
import 'package:blackjack/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(new App(shuffle: false,));
}

class App extends StatelessWidget {
  bool shuffle;

  App({this.shuffle: true});

  void onTextClick(BuildContext context) {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) {
        return new BlackjackPage(shuffle:this.shuffle,viewBuilder: (Game g, VoidCallback d, VoidCallback h, VoidCallback s) {
          return buildPage(context, new GameView(g, d, h, s), "Text Blackjack");
        });
      }),
    );
  }

  void onGraphicClick(BuildContext context) {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) {
        return new BlackjackPage(shuffle:this.shuffle,viewBuilder: (Game g, VoidCallback d, VoidCallback h, VoidCallback s) {
          return buildPage(context, new GGameView(g, d, h, s), "Graphic Blackjack");
        });
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: "Blackjack",
        home: buildPage(
            context,
            new HomePage(
              onTextClick: this.onTextClick,
              onGraphicClick: this.onGraphicClick,
            ),
            "Blackjack Home"));
  }

  Widget buildPage(BuildContext context, Widget body, String title) {
    return new Scaffold(
        backgroundColor: Theme.of(context).primaryColorLight,
        appBar: new AppBar(
          title: new Text(title),
        ),
        body: body);
  }
}
