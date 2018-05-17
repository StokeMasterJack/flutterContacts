import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:contacts/contacts.dart';
import 'package:http/http.dart' as h;
import 'package:ssutil/ssutil.dart';

final Random _rng = new Random();

Future<Contacts> fetchSampleDataFromRandomUser3(int n) async {
  List<Contact> data1 = await fetchSampleDataFromRandomUser2(n);
  List<Contact> noNulls = data1.where((c) => c != null).toList();
  return Contacts(noNulls);
}

Future<List<Contact>> fetchSampleDataFromRandomUser2(int n) {
  List<Future<Contact>> futures = fetchSampleDataFromRandomUser1(n);
  return Future.wait(futures);
}

List<Future<Contact>> fetchSampleDataFromRandomUser1(int n) {
  List<Future<Contact>> futures = [];
  for (int i = 0; i < n; i++) {
    Future<Contact> ff = new Future.delayed(new Duration(milliseconds: i * 10), () async {
      h.Response response = await h.get("https://randomuser.me/api/");
      if (response.statusCode == 200) {
        final map1 = json.decode(response.body);
        bool fav = i < 30 ? _rng.nextBool() : false;
        Contact c = _createContactFromRandomUserJson(i, map1, fav);
        if (c.nat == "IR") return null;
        return c;
      } else {
//        print(response.statusCode);
//        print(response.body);
        return null;
      }
    });

    futures.add(ff);
  }

  return futures;
}

Level _randomLevel() {
  int i = _rng.nextInt(3);
  return Level.values[i];
}

Col _randomColor() {
  int i = _rng.nextInt(3);
  return Col.values[i];
}

Contact _createContactFromRandomUserJson(int id, Map<String, dynamic> map1, bool fav) {
  final map2 = map1["results"][0];
  return new Contact(
    id: Id(id),
    firstName: capFirstLetter(map2['name']['first']),
    lastName: capFirstLetter(map2['name']['last']),
    active: _rng.nextBool(),
    color: _randomColor(),
    level: _randomLevel(),
    favorite: fav,
    nat: map2["nat"],
    largeImg: map2["picture"]["large"],
    mediumImg: map2["picture"]["medium"],
    thumbnail: map2["picture"]["thumbnail"],
  );
}

/*
 "picture": {
        "large": "https://randomuser.me/api/portraits/men/83.jpg",
        "medium": "https://randomuser.me/api/portraits/med/men/83.jpg",
        "thumbnail": "https://randomuser.me/api/portraits/thumb/men/83.jpg"
      }
 */
