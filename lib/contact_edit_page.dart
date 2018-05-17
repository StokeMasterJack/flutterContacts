import 'dart:async';

import 'package:contacts/contacts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ssutil_flutter/ssutil_flutter.dart';

const itemPaddingText = EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0);
const itemPaddingOther = EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 0.0);

class ContactEditPage extends StatefulWidget {
  final Contact initContact;
  final bool isNew;

  ContactEditPage({@required Contact initContact})
      : this.initContact = initContact == null ? Contact.empty() : initContact.nullNormalize(),
        this.isNew = initContact == null ? true : false;

  static const String prefix = "ContactEdit";

  @override
  State createState() => _ContactEditPageState();
}

List<DropdownMenuItem<Level>> buildDropdownItems(BuildContext context) {
  final yy = Level.values.map((Level level) {
    final lev = level ?? Level.Beginner;
    return DropdownMenuItem<Level>(key: ValueKey(lev.toString()), value: lev, child: new Text(describeEnum(lev)));
  }).toList();

  return yy;
}

class _ContactEditPageState extends SsState<ContactEditPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey(debugLabel: "contactEditScaffoldKey");
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController largeImg = TextEditingController();
  final TextEditingController mediumImg = TextEditingController();
  final TextEditingController thumbnail = TextEditingController();
  final TextEditingController nat = TextEditingController();
  Col col;
  Level level;
  bool active;
  bool favorite;

  Listenable _listenable;

  void _myListener() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _initFromContact();

    _listenable = new Listenable.merge([firstName, lastName, largeImg, mediumImg, thumbnail, nat]);
    _listenable.addListener(_myListener);
  }

  @override
  void dispose() {
    _listenable.removeListener(_myListener);
    super.dispose();
  }

  void _initFromContact() {
    Contact c = widget.initContact;
    firstName.text = c.firstName;
    lastName.text = c.lastName;
    thumbnail.text = c.thumbnail;
    mediumImg.text = c.mediumImg;
    largeImg.text = c.largeImg;
    col = c.color;
    level = c.level;
    active = c.active;
    favorite = c.favorite;
  }

  bool _isDirty() {
    Contact c1 = widget.initContact;
    Contact c2 = _buildContact();
    return c1 != c2;
  }

  Contact init() => widget.initContact ?? Contact.empty();

  Contact _buildContact() {
    Contact c = widget.initContact;
    return new Contact(
      id: c.id,
      firstName: firstName.text,
      lastName: lastName.text,
      color: col,
      level: level,
      active: active,
      favorite: favorite,
      nat: c.nat,
      largeImg: largeImg.text,
      mediumImg: mediumImg.text,
      thumbnail: thumbnail.text,
    ).nullNormalize();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new Scaffold(
      key: scaffoldKey,
      appBar: new AppBar(title: Text(title), actions: _computeActions()),
      body: _buildBody(context),
    );
  }

  String get title {
    if (_isDirty())
      return "Edit Contact*";
    else
      return "Edit Contact";
  }

  List<Widget> _computeActions() {
    final List<Widget> a = [];
    if (_isDirty()) {
      a.add(new FlatButton(
        child: Text("SAVE", style: Theme.of(context).primaryTextTheme.button),
        onPressed: () {
          _onSavePressed(context);
        },
      ));
    }
    a.add(new IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}));
    return a;
  }

  void _onSavePressed(BuildContext context) {
    Navigator.pop(context, _buildContact());
  }

  Widget _buildBody(BuildContext context) {
    return _buildForm(context);
  }

  Form _buildForm(BuildContext context) {
    ListView listView = new ListView(children: <Widget>[
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

    return new Form(
        key: _formKey,
        child: listView,
        onWillPop: () async {
          if (_isDirty()) {
            bool save = await _showOkCancelDialog(
                msg: "Your changes have not been saved?", cancelText: "Discard", okText: "Save");
            if (save) {
              Navigator.pop(context, _buildContact());
              return false;
            } else {
              return true;
            }
          }
          return true;
        });
  }

  Future<bool> _showOkCancelDialog(
      {@required String msg, String title = "Confirm", String okText = "Ok", String cancelText = "Cancel"}) async {
    return showOkCancelDialog(
        context: scaffoldKey.currentContext, msg: msg, title: title, okText: okText, cancelText: cancelText);
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
