import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ssplugin/ssplugin.dart';

class PermPage extends StatefulWidget {
  @override
  State createState() => PermPageState();
}

class PermPageState extends State<PermPage> {
  final SsPlugin _ssPlugin = new SsPlugin();

  Map<Perm, bool> _permMap = {};



   @override
  Widget build(BuildContext context) {

    List<ListTile> tiles = Perm.values.map(permToListTile).toList();


    return Scaffold(
        appBar: AppBar(
          title: Text("Perms")
        ),
        body: ListView(
            children:tiles
        )
    );

  }

  _fetchPerm(Perm perm) async {
    bool value = await _ssPlugin.getPerm(perm);
    setState(() {
      _permMap[perm] = value;
    });
  }

  ListTile permToListTile(Perm p) {

    void requestPerm() {
      _fetchPerm(p);
    }

    String name = describeEnum(p);

    bool value = _permMap[p];

    Widget btnRequestPerm = new FlatButton.icon(
        icon: const Icon(Icons.add_circle_outline, size: 18.0),
        label: const Text("REQUEST PERMISSION"),
        onPressed: requestPerm);

    Widget trailing;
    if (value == null) {
      trailing = btnRequestPerm;
    } else if (value) {
      trailing = Text("GRANTED", style: const TextStyle(fontSize: 18.0).copyWith());
    } else {
      trailing = Text("Denied");
    }

    return ListTile(dense: true, title: Text(name), trailing: trailing, onLongPress: () {});
  }
}
