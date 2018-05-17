import 'package:contacts/contacts.dart';
import 'package:contacts/contacts_page.dart';
import 'package:flutter/material.dart';

class ContactDetailPage extends StatelessWidget {
  final Contact contact;
  final ContactsCallbacks callbacks;

  ContactDetailPage(this.contact, this.callbacks);

  final List<Widget> children = <Widget>[
    new Container(child: Text("Dave was here"), color: Colors.green, height: 100.0),
    new Container(child: Text("Dave was here"), color: Colors.green, height: 100.0),
    new Container(child: Text("Dave was here"), color: Colors.green, height: 100.0),
    new Container(child: Text("Dave was here"), color: Colors.green, height: 100.0),
    new Container(child: Text("Dave was here"), color: Colors.green, height: 100.0),
    new Container(child: Text("Dave was here"), color: Colors.green, height: 100.0),
    new Container(child: Text("Dave was here"), color: Colors.green, height: 100.0),
    new Container(child: Text("Dave was here"), color: Colors.green, height: 100.0),
    new Container(child: Text("Dave was here"), color: Colors.green, height: 100.0),
    new Container(child: Text("Dave was here"), color: Colors.green, height: 100.0),
    new Container(child: Text("Dave was here"), color: Colors.green, height: 100.0),
    new Container(child: Text("Dave was here"), color: Colors.green, height: 100.0),
    new Container(child: Text("Dave was here"), color: Colors.green, height: 100.0),
    new Container(child: Text("Dave was here"), color: Colors.green, height: 100.0),
    new Container(child: Text("Dave was here"), color: Colors.green, height: 100.0),
    new Container(child: Text("Dave was here"), color: Colors.green, height: 100.0),
    new Container(child: Text("Dave was here"), color: Colors.green, height: 100.0),
  ];

  @override
  Widget build(BuildContext context) {
    Stack ss = new Stack(
      fit: StackFit.expand,
      children: <Widget>[
        new Image.network(
          contact.bestImage,
          fit: BoxFit.cover,
          height: 256.0,
        ),
//        new Image.asset(
//          'images/ali_connors.jpg',
//          fit: BoxFit.cover,
//          height: 256.0,
//        ),
        // This gradient ensures that the toolbar icons are distinct
        // against the background image.
        const DecoratedBox(
          decoration: const BoxDecoration(
            gradient: const LinearGradient(
              begin: const Alignment(0.0, -1.0),
              end: const Alignment(0.0, -0.4),
              colors: const <Color>[const Color(0x60000000), const Color(0x00000000)],
            ),
          ),
        ),
      ],
    );

    return new Scaffold(
        floatingActionButton: new FloatingActionButton(
          child: const Icon(Icons.edit),
          onPressed: () {
            callbacks.navToContactEdit(context, contact);
          },
        ),
        body: new CustomScrollView(slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: 256.0,
            flexibleSpace: new FlexibleSpaceBar(
              title: new Text(contact.fullName),
              background: ss,
            ),
          ),
          new SliverList(delegate: new SliverChildListDelegate(children))
        ]));
  }
}
