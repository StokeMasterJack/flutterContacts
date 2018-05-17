import 'dart:async';
import 'dart:io';

import 'package:contacts/contact_list_view.dart';
import 'package:contacts/contacts.dart';
import 'package:contacts/fav_grid_view.dart';
import 'package:contacts/ui_common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:ssplugin/ssplugin.dart';
import 'package:ssutil/ssutil.dart' as ss;
import 'package:ssutil/ssutil.dart';
import 'package:ssutil_flutter/ssutil_flutter.dart';

class ContactsPage extends SsStatefulWidget {
  final ContactsCallbacks callbacks;
  final ContactsModel model;
  final WidgetBuilder drawerBuilder;

  ContactsPage({@required this.model, @required this.callbacks, this.drawerBuilder});

  @override
  createState() => ContactsPageState();

  static const String prefix = "/";

  final List<TabInfo> _tabInfos = <TabInfo>[
    TabInfo(key: TabKey.favorites, iconData: Icons.star),
    TabInfo(key: TabKey.active, iconData: Icons.people),
    TabInfo(key: TabKey.all, iconData: Icons.history)
  ];
}

class TabInfo {
  final TabKey key;
  final IconData iconData;

  TabInfo({this.key, this.iconData});

  Tab buildTab(BuildContext context) {
    return Tab(
      key: ValueKey(key.toString()),
      icon: new Icon(iconData),
      text: "$title",
    );
  }

  String get title {
    String enumName = describeEnum(key);
    return ss.capFirstLetter(enumName);
  }
}

class ContactsPageState extends SsState<ContactsPage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey(debugLabel: "contactsScaffoldKey");

  ContactsModel get _model => widget.model;

  ContactsCallbacks get _callbacks => widget.callbacks;

  //mutable state

  bool _isSearchMode = false;
  MutableIdSet _selected = MutableIdSet();
  final TextEditingController _searchController = new TextEditingController();
  TabController _tabController;

  Listenable _masterEventSource;

  String _statusBarText;

  final Map<Perm, bool> permMap = {};

  void _onChange() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _tabController = new TabController(vsync: this, length: widget._tabInfos.length);

    _masterEventSource = new Listenable.merge([_tabController, _searchController, _model.db]);

    _masterEventSource.addListener(_onChange);
  }

  @override
  void dispose() {
    super.dispose();
    _masterEventSource.removeListener(_onChange);
  }

  ContactsData _selectContacts() {
    return widget.model.computeData(_currentFilter);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    ContactsData data = _selectContacts();

    return new Scaffold(
      key: _scaffoldKey,
      drawer: _maybeMkDrawer(context),
      floatingActionButton: _buildActionButton(context),
      appBar: _buildAppBar(context),
      body: _buildBody(context, data),
      bottomNavigationBar: _buildStatusBar(context),
    );
  }

  Drawer _maybeMkDrawer(BuildContext context) {
    if (_isSelectionMode) {
      return null;
    } else if (_isSearchMode) {
      return null;
    } else {
      return widget.drawerBuilder(context);
    }
  }

  Widget _buildBody(BuildContext context, ContactsData data) {
    return new TabBarView(
      controller: _tabController,
      children: [
        _buildFavViewGrid(context, data.favs),
        _buildContentListView(context, data.actives),
        _buildContentListView(context, data.all),
      ],
    );
  }

  _buildStatusBar(BuildContext context) {
    if (_statusBarText == null) return null;
    return Container(
      color: Colors.grey,
      child: Text(_statusBarText, style: Theme.of(context).textTheme.body2.copyWith(color: Colors.red)),
      height: 30.0,
      alignment: Alignment.center,
      padding: EdgeInsets.all(10.0),
    );
  }

  Widget _buildContentListView(BuildContext context, Contacts contacts) {
    return new ContactListView(
        contacts: contacts,
        selected: _selected.immutable(),
        onContactTap: _onContactTap,
        onContactLongPress: _onContactLongPress);
  }

  Widget _buildFavViewGrid(BuildContext context, Contacts contacts) {
    return new FavGridView(
        contacts: contacts,
        selected: _selected.immutable(),
        onContactTap: _onContactTap,
        onContactLongPress: _onContactLongPress);
  }

  void _onContactTap(BuildContext context, Contact contact) {
    if (_isSelectionMode) {
      setState(() {
        _selected.toggleSelection(contact.id);
      });
    } else {
      _callbacks.navToContactDetail(context, contact);
//      _callbacks.navToContactEdit(context, contact);
    }
  }

  void _onContactLongPress(BuildContext context, Contact contact) {
    if (!_isSelectionMode) {
      _onSelectionModeBegin(contact.id);
    }
  }

  void _onSelectionModeBegin(Id firstId) {
    BuildContext context = _scaffoldKey.currentContext;
    ModalRoute.of(context).addLocalHistoryEntry(new LocalHistoryEntry(
      onRemove: () {
        setState(() {
          _selected.clear();
        });
      },
    ));
    setState(() {
      _selected.add(firstId);
    });
  }

  bool get _isSelectionMode => _selected.isNotEmpty;

  void _onSearchModeBegin() {
    BuildContext context = _scaffoldKey.currentContext;
    ModalRoute.of(context).addLocalHistoryEntry(new LocalHistoryEntry(
      onRemove: () {
        setState(() {
          _isSearchMode = false;
          _searchController.clear();
        });
      },
    ));
    setState(() {
      this._isSearchMode = true;
      _tabController.index = 2;
    });
  }

  bool _currentFilter(Contact c) {
    if (!_isSearchMode || ss.isMissing(_searchController.text)) return true;
    return c.matchesSearchFilter(_searchController.text);
  }

  Widget _buildActionButton(BuildContext context) {
    if (_isSelectionMode || _isSearchMode) return null;
    return new FloatingActionButton(
        onPressed: () {
          _callbacks.navToContactEdit(context, null);
        },
        child: const Icon(Icons.add));
  }

  AppBar _buildAppBar(BuildContext context) {
    TabBar tabBar = _buildTabBar(context);
    if (_isSelectionMode) {
      return new AppBar(
        leading: new IconButton(
            padding: EdgeInsets.all(0.0),
            icon: const Icon(Icons.cancel),
            onPressed: () {
              setState(() {
                Navigator.pop(context);
              });
            }),
        title: Text("${_selected.length} selected"),
        actions: _buildActionsSelectedMode(context),
        bottom: tabBar,
        titleSpacing: 0.0,
      );
    } else if (_isSearchMode) {
      return new AppBar(
        title: new TextField(
          autofocus: true,
          controller: _searchController,
          decoration: new InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "Find contacts",
              isDense: true,
              suffixIcon: (_searchController.text == null || _searchController.text.isEmpty)
                  ? null
                  : new IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                        });
                      })),
        ),
        bottom: tabBar,
      );
    } else {
      return AppBar(title: Text("Contacts"), actions: _buildActionsMain(context), bottom: tabBar);
    }
  }

  TabBar _buildTabBar(BuildContext context) {
    Tab f(TabInfo ti) => ti.buildTab(context);
    List<TabInfo> tabInfos = widget._tabInfos;
    List<Tab> tabs = tabInfos.map(f).toList();
    return TabBar(
      controller: _tabController,
      tabs: tabs,
    );
  }

  void _onClearDb() async {
    bool confirm = await _showOkCancelDialog(msg: "Delete all data?");
    if (confirm) {
      this._callbacks.clearDb();
      _snack("DB Reset!");
    }
  }

  void _onExportToJson() async {
    File file = await _callbacks.exportToJson();
    String localName = basename(file.path);
    _snack("Export to file [$localName] complete");
  }

  void _onImportRandom() async {
    setState(() {
      _statusBarText = "Importing random data...";
    });

    await _callbacks.importRandom();
    _statusBarText = null;
    _snack("Random import complete");
  }

  void _onImportFromAsset() async {
    await _callbacks.importFromAsset();
    _snack("Import complete!");
  }

  void _onImportFromExtFile() async {
    await _callbacks.importFromAsset();

    _snack("Import complete!");
  }

  void _onDeleteSelected() async {
    final int count = _selected.length;
    bool confirm = await _showOkCancelDialog(msg: 'Delete $count selected records?', okText: "Delete");
    if (confirm) {
      _callbacks.deleteAll(_selected.immutable());
      _selected.clear();
      Navigator.pop(_scaffoldKey.currentContext);
      _snack("$count records deleted");
    }
  }

  void _onTodo() async {
    _snack("Todo");
  }

  List<Widget> _buildActionsMain(BuildContext context) {
    return Choices([
      Choice(title: 'Search Mode', primary: true, icon: Icons.search, callback: _onSearchModeBegin),
      Choice(title: 'Clear DB', icon: Icons.directions_car, callback: _onClearDb),
      Choice(title: 'Export to JSON', icon: Icons.directions_boat, callback: _onExportToJson),
      Choice(title: 'Import random contacts', icon: Icons.directions_bike, callback: _onImportRandom),
      Choice(title: 'Import from JSON Asset', icon: Icons.directions_bike, callback: _onImportFromAsset),
      Choice(title: 'Import from JSON External File', icon: Icons.directions_bike, callback: _onImportFromExtFile),
    ]).buildActions();
  }

  List<Widget> _buildActionsSelectedMode(BuildContext context) {
    return Choices([
      Choice(title: 'Delete selected', primary: true, icon: Icons.delete, callback: _onDeleteSelected),
      Choice(title: 'Export selected', icon: Icons.directions_bike, callback: _onTodo),
      Choice(title: 'Share selected', icon: Icons.directions_boat, callback: _onTodo),
    ]).buildActions();
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _snack(String msg) {
    return snack(_scaffoldKey, msg);
  }

  Future<bool> _showOkCancelDialog(
      {@required String msg, String title = "Confirm", String okText = "Ok", String cancelText = "Cancel"}) async {
    return showOkCancelDialog(
        context: _scaffoldKey.currentContext, msg: msg, title: title, okText: okText, cancelText: cancelText);
  }
}

class ContactsData {
  final Map<TabKey, Contacts> _map;

  ContactsData(Contacts contacts)
      : this._map = {TabKey.favorites: contacts.favorites(), TabKey.active: contacts.actives(), TabKey.all: contacts};

  Contacts get favs => _map[TabKey.favorites];

  Contacts get actives => _map[TabKey.active];

  Contacts get all => _map[TabKey.all];
}

class ContactsModel {
  final ContactsData Function(Filter filter) computeData;
  final Listenable db;

  ContactsModel({this.computeData, this.db});
}

class ContactsCallbacks {
  VoidCallback clearDb;
  AsyncAction<File> exportToJson;
  AsyncAction<void> importRandom;
  AsyncAction<bool> importFromAsset;

  Command<IdSet> deleteAll;
  Command<IdSet> onShareSelected;
  Command<IdSet> onExportSelected;

  ContextAction<Contact> navToContactEdit;
  ContextAction<Contact> navToContactDetail;

  ContactsCallbacks({
    this.clearDb,
    this.exportToJson,
    this.importRandom,
    this.importFromAsset,
    this.deleteAll,
    this.onShareSelected,
    this.onExportSelected,
    this.navToContactEdit,
    this.navToContactDetail,
  });
}
