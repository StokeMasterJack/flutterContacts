import 'package:blackjack/blackjack.dart' as bj;
import 'package:blackjack/blackjack.dart';
import 'package:flutter/material.dart';

const title = 'Flutter Blackjack';

class BlackjackPage extends StatefulWidget {
  BlackjackPage({Key key, this.viewBuilder}) : super(key: key);

  final GameViewBuilder viewBuilder;

  @override
  _AppState createState() => new _AppState();
}

class _AppState extends State<BlackjackPage> {
  bj.Game _game = new bj.Game();

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
    return widget.viewBuilder(_game.copy(), _deal, _hit, _stay);
  }
}

typedef Widget GameViewBuilder(Game g, VoidCallback onDeal, VoidCallback onHit, VoidCallback onStay);
