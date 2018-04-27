import 'package:blackjack/blackjack.dart' as bj;
import 'package:flutter/material.dart';

class GGameView extends StatelessWidget {
  final bj.Game game;
  final VoidCallback onDeal;
  final VoidCallback onHit;
  final VoidCallback onStay;

  GGameView(this.game, this.onDeal, this.onHit, this.onStay);

  @override
  Widget build(BuildContext context) {
    var handsColumn = new Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      new GHandView(game.ph),
      new Padding(padding: EdgeInsets.only(top: 12.0)),
      new GHandView(game.dh),
    ]);

    var mainCol = new Column(children: <Widget>[
      new Padding(padding: const EdgeInsets.only(top: 6.0)),
      new ButtonsView(game.isGameOver, onDeal, onHit, onStay),
      new Padding(padding: EdgeInsets.only(top: 12.0)),
      handsColumn,
      new Container(
          padding: EdgeInsets.all(10.0),
          child: new Text(game.msg,
              style: Theme.of(context).textTheme.title.copyWith(color: Theme.of(context).primaryColorDark)))
    ]);

    final gameContainer = new Container(child: mainCol, padding: new EdgeInsets.all(8.0));
    final scroll = new SingleChildScrollView(
      child: gameContainer,
      scrollDirection: Axis.vertical,
    );
   
    return scroll;
  }
}

class GHandView extends StatelessWidget {
  final bj.Hand hand;

  GHandView(this.hand);

  @override
  Widget build(BuildContext context) {
    final pointsTheme = Theme.of(context).textTheme.body2.copyWith(color: Theme.of(context).primaryColorDark);
    Widget gw = new Container(
        margin: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
        decoration:
            new BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: new BorderRadius.circular(4.0)
            ),
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        child: new Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          new Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: new Text(hand.name + " Hand", style: pointsTheme),
          ),
          buildCardsView2(context, hand.cards),
//              new Expanded(child: buildCardsView2(context, hand.cards)),

          new Padding(padding: EdgeInsets.only(bottom: 8.0)),
          new Text(hand.points.toString() + " points", style: pointsTheme),
        ]));

    return gw;
  }

  Widget buildCardsView2(BuildContext context, List<bj.Card> cards) {
    List<Widget> children = <Widget>[];
    for (bj.Card card in cards) {
      var cardView = buildCardView(context, card);
      children.add(cardView);
    }
    ListView listView = new ListView(scrollDirection: Axis.horizontal, children: children);

    Container c = new Container(
      child: listView,
      height: 80.0,
    );

    return c;
  }

  Widget buildCardView(BuildContext context, bj.Card card) {
    String path = "images/${card.imageName}";

    AssetImage asset = new AssetImage(path);
    final image = new DecoratedBox(
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: asset,
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
    );

    Widget item3 = new SizedBox(width: 54.0, height: 75.0, child: image);

    return Padding(padding: EdgeInsets.only(right: 8.0, bottom: 4.0), child: item3);
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
    return new ButtonTheme.bar(
        padding: EdgeInsets.all(12.0),
        child: new ButtonBar(
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
        ));
  }
}
