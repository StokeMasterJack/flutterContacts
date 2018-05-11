import 'package:contacts/contacts.dart';
import 'package:contacts/ui_common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ssutil_flutter/ssutil_flutter.dart';

class ContactListView extends SsStatelessWidget {
  final Contacts contacts;
  final IdSet selected;
  final ContactCallback onContactTap;
  final ContactCallback onContactLongPress;

  ContactListView({
    @required this.contacts,
    IdSet selected,
    this.onContactTap,
    this.onContactLongPress,
  })  : assert(contacts != null),
        this.selected = selected ?? IdSet.empty;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (contacts.length == 0) {
      return Center(child: Text("You have no favorites"));
    }

    return new ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) => buildContactTile(context, contacts[index]));
  }

  Widget buildContactTile(BuildContext context, Contact contact) {
    bool anySelected = selected.isNotEmpty;
    bool thisSelected = selected.contains(contact.id);

    final onTap = onContactTap == null ? null : () => onContactTap(context, contact);
    final onLongPress = onContactLongPress == null ? null : () => onContactLongPress(context, contact);
    final onCheckboxChanged = (_) => onContactTap(context, contact);

    final checkbox = anySelected ? Checkbox(value: thisSelected, onChanged: onCheckboxChanged) : null;

    final avatar = new CircleAvatar(radius: 16.0, child: new Text(contact.avatarChar));

    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      leading: avatar,
      title: Text(contact.fullName),
      trailing: checkbox,
    );
  }
}
