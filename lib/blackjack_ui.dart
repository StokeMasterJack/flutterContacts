import 'package:blackjack/blackjack.dart';
import 'package:flutter/material.dart';

const title = 'Flutter Blackjack';

class App extends StatefulWidget {
  App({Key key}) : super(key: key);

  @override
  _AppState createState() => new _AppState();
}

class _AppState extends State<App> {
  Game _game = new Game();

  void _hit() {
    setState(() {
      _game.hit();
    });
  }

  void _stay() {
    setState(() {
      _game.stay();
    });
  }

  void _deal() {
    setState(() {
      _game.deal();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new GameView(_game.copy(), _deal, _hit, _stay);
  }
}

class GameView extends StatelessWidget {
  final Game game;
  final VoidCallback onDeal;
  final VoidCallback onHit;
  final VoidCallback onStay;

  GameView(this.game, this.onDeal, this.onHit, this.onStay);

  @override
  Widget build(BuildContext context) {
    var handsRow = new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      new HandView(game.ph),
      new HandView(game.dh),
    ]);

    var mainCol = new Column(children: <Widget>[
      new ButtonsView(game.isGameOver, onDeal, onHit, onStay),
      new Expanded(child: handsRow),
      new Text(game.msg, style: Theme.of(context).textTheme.headline)
    ]);

    var materialApp = new MaterialApp(
        title: title,
        theme: new ThemeData(scaffoldBackgroundColor: Colors.green),
        home: new Scaffold(
            appBar: new AppBar(
              title: new Text(title),
            ),
            body: Container(
              padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0).copyWith(bottom: 12.0),
              constraints: BoxConstraints(maxHeight: 300.00),
              child: mainCol,
            )));

    return materialApp;
  }
}

class HandView extends StatelessWidget {
  final Hand hand;

  HandView(this.hand);

  @override
  Widget build(BuildContext context) {
    double rMargin = hand.isDealer ? 0.0 : 8.0;

    double lMargin = hand.isDealer ? 8.0 : 0.0;
    return new Expanded(
        child: new Container(
            margin: EdgeInsets.fromLTRB(lMargin, 0.0, rMargin, 8.0),
            decoration: new BoxDecoration(color: Theme.of(context).cardColor),
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            child: new Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              new Padding(
                padding: EdgeInsets.only(bottom: 5.0),
                child: new Text(hand.name + " Hand", style: Theme.of(context).textTheme.body2),
              ),
              new Expanded(
                  child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: hand.cards
                          .map((c) => new Text(
                                c.name,
                                style: Theme.of(context).textTheme.body1,
                              ))
                          .toList())),
              new Text(hand.points.toString() + " points", style: Theme.of(context).textTheme.body2),
            ])));
  }
}

class ButtonsView extends StatelessWidget {
  final bool isGameOver;
  final VoidCallback onDeal;
  final VoidCallback onHit;
  final VoidCallback onStay;

  ButtonsView(this.isGameOver, this.onDeal, this.onHit, this.onStay);

  @override
  Widget build(BuildContext context) {
    return new ButtonBar(
      alignment: MainAxisAlignment.center,
      children: <Widget>[
        isGameOver
            ? new RaisedButton(
                child: new Text("Deal"),
                onPressed: onDeal,
              )
            : null,
        !isGameOver
            ? new RaisedButton(
                child: new Text("Hit"),
                onPressed: onHit,
              )
            : null,
        !isGameOver
            ? new RaisedButton(
                child: new Text("Stay"),
                onPressed: onStay,
              )
            : null
      ],
    );
  }
}
