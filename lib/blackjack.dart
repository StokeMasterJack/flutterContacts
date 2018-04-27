import 'package:meta/meta.dart';
import 'package:quiver/check.dart';

@Immutable()
class Card {
  final int value, suit;

  Card({this.value, this.suit}) {
    checkArgument(value >= 0 && value <= 13);
    checkArgument(suit >= 0 && suit <= 4);
  }

  //this is a similar way to check constructor args that only checks in dev mode
//  Card({this.value, this.suit}):assert(value >= 0 && value <= 13),assert(suit >= 0 && suit <= 4);

  String get suitName {
    switch (suit) {
      case 1:
        return "Spades";
      case 2:
        return "Hearts";
      case 3:
        return "Clubs";
      case 4:
        return "Diamonds";
      default:
        throw new StateError("Bad suit $suit");
    }
  }

  String get valueName {
    if (value == 1) return "Ace";
    if (value >= 2 && value <= 10) return value.toString();
    if (value == 11) return "Jack";
    if (value == 12) return "Queen";
    if (value == 13) return "King";
    throw new StateError("Bad value $value");
  }

  String get name => valueName + " of " + suitName;

  int get points {
    if (value >= 1 && value <= 10) return value;
    if (value >= 11 && value <= 13) return 10;
    throw new StateError("Bad value $value");
  }

  String get imageName  {
    String vChar = value != 10?valueName[0]:"t";
    String sChar = suitName[0];
    return "${vChar}${sChar}.gif".toLowerCase();
  }
}

class Hand {
  final bool isDealer;
  final List<Card> cards;

  Hand({this.isDealer, cards}) : this.cards = cards == null ? [] : cards;

  Hand.player() : this(isDealer: true);

  Hand.dealer() : this(isDealer: false);

  String get name => isDealer ? "Dealer" : "Player";

  void add(Card card) {
    cards.add(card);
  }

  int get points => cards.fold(0, (prev, cur) => prev + cur.points);

  int get size => cards.length;

  dump() {
    print("  $name Hand");
    for (Card c in cards) {
      print("    ${c.name}");
    }
    print("    $points points");
  }

  Hand copy() {
    final copy = List<Card>();
    copy.addAll(this.cards);
    return new Hand(isDealer: isDealer, cards: copy);
  }
}

class Deck {
  final List cards;
  int nextCard;

  Deck._(this.cards, this.nextCard) {
    checkArgument(nextCard < cards.length);
  }

  Deck.shuffle() : this.init(shuffle: true);

  Deck.clean() : this.init(shuffle: false);

  Deck.init({bool shuffle: true})
      : cards = _createCards(shuffle),
        nextCard = 0;

  static List<Card> _createCards(bool shuffle) {
    final a = [];
    for (int s = 1; s <= 4; s++) {
      for (int v = 1; v <= 13; v++) {
        a.add(Card(value: v, suit: s));
      }
    }
    if (shuffle) a.shuffle();
    return List.unmodifiable(a);
  }

  get size => cards.length - nextCard;

  Card take() {
    final ret = cards[nextCard];
    nextCard++;
    return ret;
  }

  void dump() {
    print("Deck:");
    for (var c in cards) {
      print("  ${c.name}");
    }
  }

  Deck copy() {
    return Deck._(cards, nextCard);
  }
}

class Game {
  bool shuffle;
  Deck deck;
  Hand ph = Hand.player();
  Hand dh = Hand.dealer();
  bool isStay = false;

  Game({this.shuffle: true}) {
    deck = Deck.init(shuffle: shuffle);
    deal();
  }

  Game._copy(Game g)
      : shuffle = g.shuffle,
        deck = g.deck.copy(),
        ph = g.ph.copy(),
        dh = g.dh.copy(),
        isStay = g.isStay;

  void deal() {
    if (deck.size < 30) deck = Deck.shuffle();
    ph = new Hand(isDealer: false);
    dh = new Hand(isDealer: true);
    ph.add(deck.take());
    dh.add(deck.take());
    ph.add(deck.take());
    dh.add(deck.take());
    isStay = false;
  }

  void hit() {
    if (deck.size < 30) deck = Deck.shuffle();
    ph.add(deck.take());
  }

  void stay() {
    if (deck.size < 30) deck = Deck.shuffle();
    while (dh.points < 17) dh.add(deck.take());
    isStay = true;
  }

  void dump() {
    print("Blackjack");
    ph.dump();
    print("");
    dh.dump();
    print("");
  }

  bool get isGameOver => isStay || ph.points > 21;

  String get msg {
    if (!isGameOver) return "Press Hit or Stay";
    if (ph.points > 21) return "Dealer Wins!";
    if (dh.points > 21) return "Player Wins!";
    if (ph.points == dh.points) return "Tie";
    if (ph.points > dh.points) return "Player Wins!";
    if (dh.points > ph.points) return "Dealer Wins!";
    throw new Exception();
  }

  Game copy() {
    return Game._copy(this);
  }
}
