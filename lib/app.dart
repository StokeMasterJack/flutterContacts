import 'package:contacts/contact_edit_page.dart';
import 'package:contacts/contacts.dart';
import 'package:contacts/contacts_page.dart';
import 'package:contacts/favorites_page.dart';
import 'package:contacts/ui_common.dart';
import 'package:flutter/material.dart';
import 'package:ssutil_flutter/ssutil_flutter.dart';

const String materialApp = "MaterialApp";
const String contactsApp = "ContactsApp";
const String contactsPage = "ContactsPage";
const String favoritesPage = "FavoritesPage";

const Key materialAppKey = const ValueKey("${materialApp}Key");
const Key contactsAppKey = const ValueKey("${contactsApp}Key");
const Key contactsPageKey = const ValueKey<String>("${contactsPage}Key");
const Key favoritesKey = const ValueKey<String>("${favoritesPage}Key");

class App extends SsStatefulWidget {
  final MutableDb db = MutableDb();

  @override
  State createState() {
    return new AppState();
  }

  App() : super(key: contactsAppKey);
}

class AppState extends SsState<App> implements ContactCallbacks {
  MutableDb get db => widget.db;

  Key contactsKeyNonNullDb;

  @override
  void initState() {
    super.initState();
    db.populateFromJsonAsset();
  }

  void refresh() {
    throw StateError("");
//    print("App.refresh");
//    setState(() {});
  }

//  static Key _appKey = new ObjectKey("App");
  Key genNonNullDbKey(String prefix) {
    return new ValueKey("${prefix}Db[${db.hashCode}]");
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new MaterialApp(key: materialAppKey, onGenerateRoute: buildRoute);
  }

  @override
  void dbDelete(BuildContext context, Id id) async {
    db.delete(id);
  }

  @override
  void dbDeleteAll(BuildContext context, IdSet ids) {
    db.deleteAll(ids);
  }

  @override
  void dbPut(BuildContext context, Contact contact) {
    db.put(contact);
  }

  @override
  void dbClear(BuildContext context) {
    db.clear();
  }

  @override
  void dbSerialize(BuildContext context) {
    db.serializeToFile();
  }

  @override
  void dbPopulateFromRandomUser(BuildContext context) {
    db.populateFromRandomUser(500);
  }

//  Future<void> navToContactSelection(BuildContext context, Contacts contacts, Id initSelection) {
//    Widget page = new ContactSelectionPage(contacts: contacts, initSelection: initSelection, callbacks: this);
//    return navPush<void>(context, page, desc: "NavToContactSelection");
//  }
//
//  Future<void> navToContactFilter(BuildContext context, Contacts contacts) {
//    Widget page = new ContactFilterPage(db: db, callbacks: this, initContacts: contacts);
//    return navPushNoAnimation<void>(context, page);
//  }

  Route<dynamic> buildRoute(RouteSettings settings) {
    return _buildRoute(new Rt(settings));
  }

  static List<RtBuilderFactory> factories = [ContactEditRtBuilder(), FavoritesRtBuilder(), ContactsRtBuilder()];

  Route<dynamic> _buildRoute(Rt rt) {
    for (RtBuilderFactory f in factories) {
      Route<dynamic> r = f.maybeBuildRoute(rt, this);
      if (r != null) return r;
    }
    return null;
  }

  List<Choice> buildChoices() {
    return <Choice>[
      Choice(title: 'clearDb', icon: Icons.directions_car, action: this.dbClear),
      Choice(title: 'populateDbFromRandomUser', icon: Icons.directions_bike, action: dbPopulateFromRandomUser),
      Choice(title: 'serializeDbToJson', icon: Icons.directions_boat, action: dbSerialize),
    ];
  }

  PopupMenuButton<Choice> buildPopupMenuButton(BuildContext context) {
    return new PopupMenuButton<Choice>(
      onSelected: (Choice choice) {
        choice.action(context);
      },
      itemBuilder: (BuildContext context) {
        List<Choice> choices = buildChoices();
        return choices.map((Choice choice) {
          return new PopupMenuItem<Choice>(
              value: choice,
              child: ListTile(
                title: new Text(choice.title),
                leading: new Icon(choice.icon),
              ));
        }).toList();
      },
    );
  }
}

class ContactEditNav {
  static ContextAction<Id> navToContactEdit = ContactEditPage.navToContactEdit;
  static ContextCallback navToContactNew = ContactEditPage.navToContactNew;
}

class ContactEditRtBuilder extends RtBuilderFactory<AppState> {
  @override
  String prefix = ContactEditPage.prefix;

  @override
  Widget buildPage(BuildContext context, Rt rt, AppState app) {
//    rt.dump();
    Id id;
    if (rt.isLastSegmentAnIntId) {
      id = rt.parseId();
    } else {
      id = null;
    }
    Contact c = app.db.initContact(id);
    return ContactEditPage(db: app.db, callbacks: app, initContact: c);
  }
}

class FavoritesRtBuilder extends RtBuilderFactory<AppState> {
  @override
  String prefix = FavoritesPage.prefix;

  @override
  Widget buildPage(BuildContext context, Rt rt, AppState app) {
    Contacts contacts = app.db.favorites();
    return FavoritesPage(
      contacts: contacts,
      navToContactEdit: ContactEditNav.navToContactEdit,
      navToContactNew: ContactEditNav.navToContactNew,
    );
  }
}

class ContactsRtBuilder extends RtBuilderFactory<AppState> {
  @override
  @override
  Widget buildPage(BuildContext context, Rt rt, AppState app) {
    return ContactsPage(
        key: contactsPageKey,
        db: app.db,
        dbListenable: app.db,
        menuBuilder: app.buildPopupMenuButton,
        navToContactEdit: ContactEditNav.navToContactEdit,
        navToContactNew: ContactEditNav.navToContactNew,
        navToFavorites: FavoritesPage.navToFavorites,
        onDeleteAll: app.dbDeleteAll);
  }

  @override
  bool isMatch(Rt rt, AppState t) => rt.isPrefix("/");
}
