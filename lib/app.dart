import 'package:contacts/PermPage.dart';
import 'package:contacts/contact_detail.dart';
import 'package:contacts/contact_edit_page.dart';
import 'package:contacts/contacts.dart';
import 'package:contacts/contacts_page.dart';
import 'package:contacts/ui_common.dart';
import 'package:flutter/material.dart';
import 'package:ssutil_flutter/ssutil_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class App extends SsStatefulWidget {
  @override
  createState() => AppState();
}

class AppState extends SsState<App> {
  final Db db = Db();

  @override
  void initState() {
    super.initState();
    db.importFromJsonAsset();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: _buildContactsPage(context),
    );
  }

  ContactsCallbacks mkCallbacks() {
    return ContactsCallbacks(
      exportToJson: db.serializeToDocDir,
      clearDb: db.clearDb,
      importRandom: db.importRecordsFromRandomUser,
      importFromAsset: db.importFromJsonAsset,
      deleteAll: db.deleteAll,
      navToContactDetail: _navToContactDetail,
      navToContactEdit: _navToContactEdit,
    );
  }

  Widget _buildContactsPage(BuildContext context) {
    return ContactsPage(
      model: ContactsModel(computeData: (Filter f) => ContactsData(db.select(f)), db: db),
      callbacks: mkCallbacks(),
      drawerBuilder: mkDrawer,
    );
  }

  Widget _buildContactEditPage(BuildContext context, Contact contact) {
    return new ContactEditPage(initContact: contact);
  }

  Widget _buildContactDetailPage(BuildContext context, Contact contact) {
    return new ContactDetailPage(contact, mkCallbacks());
  }

  void _navToContactEdit(BuildContext context, Contact contact) async {
    Widget buildPage(BuildContext context) {
      return _buildContactEditPage(context, contact ?? Contact.empty());
    }

    Contact updatedContact = await navPush(context, buildPage);

    if (updatedContact != null) {
      setState(() {
        db.put(updatedContact);
      });
    }
  }

  void _navToContactDetail(BuildContext context, Contact contact) async {
    Widget buildPage(BuildContext context) {
      return _buildContactDetailPage(context, contact);
    }

    navPush(context, buildPage);
  }

  void _onWriteExtFile() async {
    db.serializeToExtDir();
  }

  _launchURL() async {
    const url = 'https://drive.google.com/a/smart-soft.com/file/d/1Na4PcxJn_NbHcPNut171L4u-8lah5Kpy/view?usp=drivesdk';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

//
//  void _onSliv(BuildContext ctx) {
//    Widget b(BuildContext c) {
//      return new ContactDetailPage();
//    }
//
//    MaterialPageRoute r = MaterialPageRoute(builder: b);
//    Navigator.push(ctx, r);
//  }

  Choices mkGeneralDrawerChoices(BuildContext context) {
    return Choices([
      Choice(title: 'External File', primary: true, icon: Icons.search, callback: _onWriteExtFile),
      Choice(title: 'Request ', primary: true, icon: Icons.search, callback: _onWriteExtFile),
      Choice(title: 'Nav to Perm Page ', primary: true, icon: Icons.search, callback: () => navToPermPage(context)),
    ]);
  }

  void navToPermPage(BuildContext context) async {
    PermPage p = PermPage();
    await navPush(context, (_) => p);
  }

  Widget mkDrawer(BuildContext context) {
    final List<Widget> children = <Widget>[
      new DrawerHeader(
          child: new Text('Drawer Header'),
          decoration: new BoxDecoration(
            color: Colors.blue,
          ))
    ];

    Choices gen = mkGeneralDrawerChoices(context);
    children.addAll(gen.mkDrawerItems());

    children.add(Divider());
    children.add(Divider());

    final d = new Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the Drawer if there isn't enough vertical
      // space to fit everything.
      child: new ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: children),
    );

    return d;
  }
}
