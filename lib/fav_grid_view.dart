import 'package:contacts/contacts.dart';
import 'package:contacts/ui_common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ssutil/ssutil.dart' as ss;

class FavGridView extends StatelessWidget {
  final Contacts contacts;
  final IdSet selected;
  final ContactCallback onContactTap;
  final ContactCallback onContactLongPress;

  FavGridView({
    @required this.contacts,
    selected,
    @required this.onContactTap,
    this.onContactLongPress,
  })
      : assert(contacts != null),
        assert(onContactTap != null),
        this.selected = selected ?? IdSet.empty;

  @override
  Widget build(BuildContext context) {
    if (contacts.length == 0) {
      return Center(child: Text("You have no contacts"));
    }

    List<Widget> children = contacts.map((Contact contact) =>
    new FavTile(
        contact: contact,
        selected: selected,
        onTapContact: onContactTap,
        onLongPressContact: onContactLongPress)).toList();


    var g = new GridView.count(
        padding: const EdgeInsets.all(20.0),
        primary: false,
        crossAxisCount: 2,
        mainAxisSpacing: 10.0,
        children: children
    );




    return new Padding(padding: const EdgeInsets.only(top: 16.0), child: g);
  }
}


class FavTile extends StatelessWidget {
  final Contact contact;
  final IdSet selected;
  final ContactCallback onTapContact;
  final ContactCallback onLongPressContact;

  FavTile({@required this.contact, @required this.selected, @required this.onTapContact, this.onLongPressContact})
      : assert(contact != null),
        assert(selected != null),
        assert(onTapContact != null);

//  Widget buildAvatar() {
//    if (contact.thumbnail == null) {
//      return new CircleAvatar(radius: 32.0, child: new Text(contact.firstName[0].toUpperCase()));
//    } else {
//      ImageProvider<NetworkImage> img = new NetworkImage(contact.thumbnail);
//      return new CircleAvatar(radius: 32.0, backgroundImage: img);
//    }
//  }


  @override
  Widget build(BuildContext context) {
    Widget av = ss.isMissing(contact.thumbnail)
        ? new CircleAvatar(radius: 32.0, child: new Text(contact.firstName[0].toUpperCase()))
        : new CircleAvatar(radius: 32.0, backgroundImage: new NetworkImage(contact.thumbnail));

    return new InkWell(
        onTap: () => this.onTapContact(context, contact),
        onLongPress: onLongPressContact == null ? null : () => onLongPressContact(context, contact),
        child: Column(
          children: <Widget>[
            new SizedBox(height: 16.0),
            av,
            new SizedBox(height: 12.0),
            new Text(contact.fullName)
          ],
        )
    );
  }
}
