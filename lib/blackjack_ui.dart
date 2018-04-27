import 'package:blackjack/blackjack.dart' as bj;
import 'package:flutter/material.dart';

const title = 'Flutter Blackjack';

class GameView extends StatelessWidget {
  final bj.Game game;
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

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0).copyWith(bottom: 12.0),
      constraints: BoxConstraints(maxHeight: 340.00),
      child: mainCol,
    );
  }
}

class HandView extends StatelessWidget {
  final bj.Hand hand;

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
              buildCardsView1(context, hand.cards),
              new Text(hand.points.toString() + " points", style: Theme.of(context).textTheme.body2),
            ])));
  }

  Widget buildCardsView1(BuildContext context, List<bj.Card> cards) {
    return new Expanded(
        child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: hand.cards
                .map((bj.Card c) => new Text(
                      c.name,
                      style: Theme.of(context).textTheme.body1,
                    ))
                .toList()));
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
                key: new Key("Deal"),
                child: new Text("Deal"),
                onPressed: onDeal,
              )
            : null,
        !isGameOver
            ? new RaisedButton(
                key: new Key("Hit"),
                child: new Text("Hit"),
                onPressed: onHit,
              )
            : null,
        !isGameOver
            ? new RaisedButton(
                key: new Key("Stay"),
                child: new Text("Stay"),
                onPressed: onStay,
              )
            : null
      ],
    );
  }
}
