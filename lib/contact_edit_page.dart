import 'dart:async';

import 'package:contacts/contacts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ssutil_flutter/ssutil_flutter.dart';

const itemPaddingText = EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0);
const itemPaddingOther = EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 0.0);

class ContactEditPage extends StatefulWidget {
  final Contact initContact;
  final Db db;

  ContactEditPage({@required this.db, @required this.initContact})
      : assert(db != null),
        assert(initContact != null);

  @override
  State createState() => _ContactEditPageState();

  static const String prefix = "/ContactEdit";

  static void navToContactEdit(BuildContext context, Id id) {
    Navigator.pushNamed(context, '/ContactEdit/$id');
  }

  static void navToContactNew(BuildContext context) {
    Navigator.pushNamed(context, '/ContactEdit/new');
  }
}

List<DropdownMenuItem<Level>> buildDropdownItems(BuildContext context) {
  final yy = Level.values.map((Level level) {
    final lev = level ?? Level.Beginner;
    return DropdownMenuItem<Level>(key: ValueKey(lev.toString()), value: lev, child: new Text(describeEnum(lev)));
  }).toList();

  return yy;
}

class _ContactEditPageState extends SsState<ContactEditPage> {
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController thumbnail = TextEditingController();
  Col col;
  Level level;
  bool active;
  bool favorite;

  @override
  void initState() {
    super.initState();
    final Contact c = widget.initContact;
    firstName.text = c.firstName;
    lastName.text = c.lastName;
    thumbnail.text = c.thumbnail;
    col = c.color;
    level = c.level;
    active = c.active;
    favorite = c.favorite;
  }

  Contact _buildContact() {
    Contact c = widget.initContact;
    return new Contact(
        id: c.id,
        firstName: firstName.text,
        lastName: lastName.text,
        thumbnail: thumbnail.text,
        color: col,
        level: level,
        active: active,
        nat: c.nat,
        favorite: favorite);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new Scaffold(
      appBar: new AppBar(
        title: Text("Edit Contact"),
        actions: <Widget>[
          new FlatButton(
            child: Text("SAVE", style: Theme.of(context).primaryTextTheme.button),
            onPressed: () {
              _onSavePressed(context);
            },
          ),
          new IconButton(icon: const Icon(Icons.more_vert), onPressed: () {})
        ],
      ),
      body: buildForm(context),
    );
  }

  Db get db => widget.db;

  void _onSavePressed(BuildContext context) {
    db.put(_buildContact());
    Navigator.pop(context);
  }

  Widget buildForm(BuildContext context) {
    return new ListView(children: <Widget>[
      const SizedBox(height: 24.0),
      new ListTile(
        title: new TextField(
          decoration: new InputDecoration(labelText: "First name"),
          controller: firstName,
        ),
      ),
      new ListTile(
        title: new TextField(
          decoration: new InputDecoration(labelText: "Last name"),
          controller: lastName,
        ),
      ),
      new ListTile(
        title: new TextField(
          decoration: new InputDecoration(labelText: "Thumbnail URL"),
          controller: thumbnail,
        ),
      ),
      const SizedBox(height: 12.0),
      const Divider(),
      new CheckboxListTile(
          title: Text("Active", style: Theme.of(context).textTheme.caption),
          value: active,
          onChanged: (bool value) {
            setState(() {
              active = value;
            });
          }),
      const Divider(),
      new SwitchListTile(
          title: Text("Favorite", style: Theme.of(context).textTheme.caption),
          value: favorite,
          onChanged: (bool value) {
            setState(() {
              favorite = value;
            });
          }),
      const Divider(),
      new ListTile(
        title: Text("Level", style: Theme.of(context).textTheme.caption),
        trailing: new DropdownButton<Level>(
            hint: const Text("Select a level"),
            value: level,
            onChanged: (Level value) {
              setState(() {
                level = value;
              });
            },
            items: buildDropdownItems(context)),
      ),
      const Divider(),
      new ListTile(
        onTap: () async {
          final c = await _promptForColor(context, col);
          if (c != null) {
            setState(() {
              col = c;
            });
          }
        },
        title: Text("Favorite Color", style: Theme.of(context).textTheme.caption),
        trailing: Text(describeEnum(col)),
      )
    ]);
  }
}

class ColorPicker extends StatelessWidget {
  final Col col;
  final ValueChanged<Col> onChanged;

  ColorPicker({this.col, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final xx = Col.values
        .map((Col col) => new Radio<Col>(
              value: col,
              groupValue: this.col,
              onChanged: this.onChanged,
            ))
        .toList();
    return new ListView(
      children: xx,
    );
  }
}

Future<Col> _promptForColor(BuildContext context, Col currentValue) async {
  Widget getChild(BuildContext context, Col color) {
    return new SimpleDialogOption(
      onPressed: () {
        Navigator.pop(context, color);
      },
      child: new Row(
        children: <Widget>[
          new Radio<Col>(
            value: color,
            groupValue: currentValue,
            onChanged: (Col s) {
              Navigator.pop(context, color);
            },
          ),
          new Text(describeEnum(color))
        ],
      ),
    );
  }

  List<Widget> getChildren(BuildContext context) {
    return Col.values.map((Col color) => getChild(context, color)).toList();
  }

  return showDialog<Col>(
      context: context,
      builder: (BuildContext context) {
        List<Widget> a = getChildren(context);
        a.add(new Align(
          alignment: Alignment.centerRight,
          child: new FlatButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text("Cancel", style: Theme.of(context).textTheme.button)),
        ));

        return new SimpleDialog(
          title: const Text('Select Color'),
          children: a,
        );
      });
}
