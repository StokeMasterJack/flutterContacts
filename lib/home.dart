import 'package:flutter/material.dart';

typedef ContextAction(BuildContext context);

class HomePage extends StatelessWidget {
  final ContextAction onTextClick;
  final ContextAction onGraphicClick;

  HomePage({this.onTextClick, this.onGraphicClick});

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new RaisedButton(
                key: new Key("Text"),
                child: new Text("Text Blackjack"),
                onPressed: () {
                  print("Text Blackjack");
                  this.onTextClick(context);
                }),
            new Padding(padding: const EdgeInsets.all(24.0)),
            new RaisedButton(
                key: new Key("Graphic"),
                child: new Text("Graphic Blackjack"),
                onPressed: () {
                  print("Graphic Blackjack");
                  this.onGraphicClick(context);
                }),
          ],
        ),
      ),
    );
  }
}
