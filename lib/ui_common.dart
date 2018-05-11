import 'package:contacts/contacts.dart';
import 'package:flutter/material.dart';
import 'package:ssutil/ssutil.dart' as ss;
import 'package:ssutil_flutter/ssutil_flutter.dart';

typedef ContactCallback(BuildContext context, Contact contact);
typedef PopupMenuButton<Choice> MenuBuilder(BuildContext context);

abstract class ContactCallbacks {
  //db
  void dbDelete(BuildContext context, Id id);

  void dbDeleteAll(BuildContext context, IdSet ids);

  void dbPut(BuildContext context, Contact contact);

  void dbClear(BuildContext context);

  void dbSerialize(BuildContext context);

  void dbPopulateFromRandomUser(BuildContext context);
}

class Rt {
  static const String newSuffix = "/new";
  static const String rootName = "/";

  final RouteSettings settings;

  Rt(this.settings) : assert(settings != null);

  bool get isNew {
    return settings.name.endsWith(newSuffix);
  }

  bool isPrefix(String prefix) {
    return settings.name.startsWith(prefix);
  }

  bool get isRoot => nameEquals(rootName);

  bool nameEquals(String name) => settings.name == name;

  List<String> get path => settings.name.split("/").where((String s) => s != null && s.trim().isNotEmpty).toList();

  String get last {
    List<String> p = path;
    if (p == null) return null;
    if (p.isEmpty) return null;
    return p.last.trim();
  }

  bool get isLastSegmentAnIntId {
    String l = last;
    if (l == null) return false;
    return isInt(l);
  }

  Id parseId() {
    if (!isLastSegmentAnIntId) throw FormatException("isLastSegmentAnIntId = false");
    String sId = last;
    int iId = int.tryParse(sId);
    if (iId == null) {
      debugPrint("Failed to parse id[$sId]");
      throw new FormatException("Failed to parse id[$sId]");
    } else {
      return Id(iId);
    }
  }

  void dump() {
    print(settings);
    print("path[$path]");
    print("isNew[$isNew]");
    print("isRoot[$isRoot]");
  }

  bool isInt(String s) {
    try {
      int.parse(s);
      return true;
    } catch (e) {
      return false;
    }
  }
}

typedef bool RtPredicate(Rt rt);
typedef Route RtBuilder(Rt rt);

class RtBuilderFactory<T> {
  String prefix = "PREFIX";

  bool isMatch(Rt rt, T t) {
    return isPrefix(rt, t);
  }

  bool isPrefix(Rt rt, T t) {
    return rt.isPrefix(prefix);
  }

  Route<dynamic> maybeBuildRoute(Rt rt, T t) {
    if (!isMatch(rt, t)) return null;
    return buildRoute(rt, t);
  }

  Route<dynamic> buildRoute(Rt rt, T t) {
    return new MaterialPageRoute<void>(
        settings: rt.settings, builder: (BuildContext context) => buildPage(context, rt, t));
  }

  Widget buildPage(BuildContext context, Rt rt, T t) => ss.unsupported();
}

class Choice {
  Choice({this.title, this.icon, this.action});

  final String title;
  final IconData icon;
  final ContextCallback action;

  @override
  String toString() {
    return 'Choice{title: $title}';
  }
}
