import 'package:contacts/contacts.dart';
import 'package:contacts/fav_grid_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ssutil_flutter/ssutil_flutter.dart';

class FavoritesPage extends SsStatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: "FavoritesPageKey");
  final Contacts contacts;
  final ContextCallback navToContactNew;
  final ContextAction<Id> navToContactEdit;

  static const String prefix = "/Favorites";

  FavoritesPage({@required this.contacts, @required this.navToContactEdit, @required this.navToContactNew})
      : assert(contacts != null),
        assert(navToContactEdit != null),
        assert(navToContactNew != null);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new Scaffold(
      key: _scaffoldKey,
      floatingActionButton: buildActionButton(context),
      appBar: buildAppBar(context),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return new FavGridView(
        contacts: contacts,
        onContactTap: (BuildContext context, Contact contact) => navToContactEdit(context, contact.id));
  }

  String buildPageTitle() {
    int length = contacts.length;
    return "Favorites [$length]";
  }

  Widget buildAppBar(BuildContext context) {
    var tt = buildPageTitle();
    return new AppBar(title: Text(tt));
  }

  Widget buildActionButton(BuildContext context) {
    return new FloatingActionButton(onPressed: () => navToContactNew(context), child: const Icon(Icons.add));
  }

  static void navToFavorites(BuildContext context) {
    Navigator.pushNamed(context, prefix);
  }
}
