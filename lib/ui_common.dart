import 'package:collection/collection.dart';
import 'package:contacts/contacts.dart';
import 'package:flutter/material.dart';

typedef ContactCallback(BuildContext context, Contact contact);
typedef PopupMenuButton<Choice> MenuBuilder(GlobalKey<ScaffoldState> scaffoldKey);

typedef bool RtPredicate(Rt rt);
typedef Route RtBuilder(Rt rt);

typedef Widget PageBuilder(BuildContext context, Rt rt);

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

  bool get isLastSegmentId {
    String l = last;
    if (l == null) return false;
    return isInt(l);
  }

  Id parseId() {
    if (!isLastSegmentId) throw FormatException("isLastSegmentAnIntId = false");
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
    if (s == null) return false;
    if (s.trim().isEmpty) return false;
    return int.tryParse(s.trim()) != null;
  }

  Route<T> buildRoute<T>(PageBuilder pageBuilder) {
    Widget widgetBuilder(BuildContext context) {
      return pageBuilder(context, this);
    }

    return new MaterialPageRoute<T>(builder: widgetBuilder, settings: settings);
  }

  Id get lastSegmentAsId {
    return parseId();
  }

  Route<dynamic> badRoute() {
    Text w = Text("Bad Route:[${settings.name}]");
    Center c = Center(child: w);
    WidgetBuilder b = (_) => c;
    return MaterialPageRoute<dynamic>(builder: b, settings: settings);
  }
}

class Choices extends DelegatingList<Choice> {
  Choices([List<Choice> del]) : super(del ?? []);

  List<Choice> get primaryChoices => where((Choice c) => c.primary).toList();

  List<Choice> get secondaryChoices => where((Choice c) => !c.primary).toList();

  List<Widget> buildActions() {
    Widget choiceToAction(Choice choice) => choice.buildAction();
    List<Widget> actions = primaryChoices.map(choiceToAction).toList();
    actions.add(mkPopupMenuButton());
    return actions;
  }

  List<PopupMenuItem<Choice>> buildPopupMenuItems() {
    PopupMenuItem<Choice> buildPopupMenuItem(Choice choice) => choice.buildPopupMenuItem();
    return secondaryChoices.map(buildPopupMenuItem).toList();
  }

  PopupMenuButton<Choice> mkPopupMenuButton() {
    return new PopupMenuButton<Choice>(
        onSelected: (Choice choice) => choice.callback(), itemBuilder: (BuildContext context) => buildPopupMenuItems());
  }

  Choices plus(Choices other) {
    List<Choice> a = [];
    a.addAll(this);
    a.addAll(other);
    return Choices(a);
  }


  List<Widget> mkDrawerItems() {
     return map((Choice c) => c.mkDrawerItem()).toList();
   }
}

class Choice {
  Choice({this.primary = false, this.title = "None", this.icon, this.callback});

  final bool primary;
  final String title;
  final IconData icon;
  final VoidCallback callback;

  @override
  String toString() {
    return 'Choice{title: $title}';
  }

  PopupMenuItem<Choice> buildPopupMenuItem() {
    return new PopupMenuItem<Choice>(
        value: this,
        child: ListTile(
          title: new Text(title),
          leading: new Icon(icon),
        ));
  }

  Widget buildAction() {
    return IconButton(
      icon: new Icon(this.icon),
      onPressed: () {
        if (callback != null) {
          callback();
        }
      },
    );
  }

  Widget mkDrawerItem() {
    return ListTile(
      leading: Icon(icon),
      title: new Text(title),
      onTap: () => callback(),
    );
  }


}

class SsKey extends LocalKey {
  const SsKey(this.widgetType, [this.id1 = "1", this.id2 = ""]);

  final Type widgetType;
  final Object id1;
  final Object id2;

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final SsKey typedOther = other;
    return widgetType == typedOther.widgetType && id1 == typedOther.id1 && id2 == typedOther.id2;
  }

  @override
  int get hashCode => hashValues(runtimeType, id1, id2);

  @override
  String toString() {
    return 'SsKey($widgetType$id1$id2)';
  }
}
