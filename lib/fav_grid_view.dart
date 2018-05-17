import 'package:contacts/contacts.dart';
import 'package:contacts/ui_common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ssutil/ssutil.dart' as ss;

const String backupUrl = "https://randomuser.me/api/portraits/women/72.jpg";

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
  })  : assert(contacts != null),
        assert(onContactTap != null),
        this.selected = selected ?? IdSet.empty;

  @override
  Widget build(BuildContext context) {
    if (contacts.length == 0) {
      return Center(child: Text("You have no contacts"));
    }

    Widget contactToTile(Contact contact) {
      return buildContactTile(context, contact);
    }

    var g = new GridView.count(
        padding: const EdgeInsets.all(0.0),
        primary: true,
        crossAxisCount: 2,
        mainAxisSpacing: 0.0,
        crossAxisSpacing: 0.0,
        children: contacts.map(contactToTile).toList());

    return new Padding(padding: const EdgeInsets.all(0.0).copyWith(top: 10.0), child: g);
  }

  Widget buildContactTile(BuildContext context, Contact contact) {
    List<Color> colors = [Colors.red, Colors.grey, Colors.yellowAccent, Colors.grey];

    colors = colors.map((_) => null).toList();

    Color tileColor = colors[0];
    Color h1Color = colors[1];
    Color avColor = colors[2];
    Color lblColor = colors[3];

    int id = contact.id.value;

    double avRadius = 52.0;

    CircleAvatar av = ss.isMissing(contact.thumbnail)
        ? new CircleAvatar(
            key: SsKey(CircleAvatar, id), radius: avRadius, child: new Text(contact.firstName[0].toUpperCase()))
        : new CircleAvatar(
            key: SsKey(CircleAvatar, id), radius: avRadius, backgroundImage: new NetworkImage(contact.thumbnail));

    final onTap = onContactTap == null ? null : () => onContactTap(context, contact);
    final onLongPress = onContactLongPress == null ? null : () => onContactLongPress(context, contact);
    final onCheckboxChanged = (_) => onContactTap(context, contact);

    Widget wName = Text(contact.fullName, key: SsKey(Text, id));

    Widget checkbox = Container(
        alignment: Alignment.topLeft,
        height: 20.0,
        padding: EdgeInsets.all(0.0),
        child: Opacity(
            key: SsKey(Opacity, id, 1),
            opacity: selected.isNotEmpty ? 1.0 : 0.0,
            child: Checkbox(
              key: SsKey(Checkbox, id),
              value: selected.contains(contact.id),
              onChanged: onCheckboxChanged,
            )));

    double h1 = 12.0;
    double avHeight = avRadius * 2;
    double h2 = 5.0;
    double titleHeight = 16.0;

    Column column = Column(
      key: SsKey(Column, id),
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
            child: Container(
          color: h1Color,
          padding: EdgeInsets.all(0.0),
          child: checkbox,
        )),
        Container(child: av, color: avColor, alignment: Alignment.center),
        Expanded(
            child: Container(
          child: wName,
          color: lblColor,
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(top: 10.0),
        ))
      ],
    );

    double tileHeight = h1 + avHeight + h2 + titleHeight - 40.0;

    final box = Container(
        constraints: BoxConstraints(minHeight: tileHeight),
//        alignment: Alignment.bottomCenter,
        color: tileColor,
        child: column);

//    return new GestureDetector(key: SsKey(InkWell, id), onTap: onTap, onLongPress: onLongPress, child: box);
    return new InkWell(key: SsKey(InkWell, id), onTap: onTap, onLongPress: onLongPress, child: box);
  }
}
