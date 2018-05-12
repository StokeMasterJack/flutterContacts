import 'dart:async';

import 'package:contacts/contact_list_view.dart';
import 'package:contacts/contacts.dart';
import 'package:contacts/fav_grid_view.dart';
import 'package:contacts/ui_common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ssutil_flutter/ssutil_flutter.dart';

class ContactsPage extends SsStatefulWidget {
  static const String prefix = "/";

  final Db db;
  final Listenable dbListenable;

  final MenuBuilder menuBuilder;
  final ContextCallback navToContactNew;
  final ContextAction<Id> navToContactEdit;
  final ContextCallback navToFavorites;
  final ContextAction<IdSet> onDeleteAll;

  ContactsPage({
    Key key,
    @required this.db,
    @required this.dbListenable,
    @required this.menuBuilder,
    @required this.navToContactNew,
    @required this.navToContactEdit,
    @required this.navToFavorites,
    @required this.onDeleteAll,
  }) : super(key: key);

  @override
  createState() => ContactsPageState();
}

enum TabKey { fav, active, inactive }

class TabInfo {
  final int index;
  final TabKey key;
  final String title;
  final IconData iconData;
  final Tab tab;

  TabInfo({this.index, this.key, this.title, this.iconData, this.tab});

  Tab buildTab(BuildContext context) {
    return Tab(
      key: ValueKey(key.toString()),
//      icon: new Icon(iconData),
      text: title,
    );
  }
}

class ContactsPageState extends SsState<ContactsPage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: "ContactsPageKey");

  bool _isSearchMode = false;

  MutableIdSet _selected = MutableIdSet();

  Contacts contacts = Contacts.empty;

  final TextEditingController _searchController = new TextEditingController();
  TabController _tabController;

  final _tabInfos = <TabInfo>[
    TabInfo(index: 0, key: TabKey.fav, title: "Favorites", iconData: Icons.star),
    TabInfo(index: 1, key: TabKey.active, title: "Active", iconData: Icons.people),
    TabInfo(index: 2, key: TabKey.inactive, title: "Inactive", iconData: Icons.history)
  ];

  Listenable listenable;

  @override
  void initState() {
    super.initState();

    _tabController = new TabController(vsync: this, length: _tabInfos.length);

    Listenable listenable = new Listenable.merge([db, _searchController, _tabController]);

    listenable.addListener(this.myListener);
  }

  void myListener() {
    setState(() {});
  }

  Db get db => widget.db;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new Scaffold(
        key: _scaffoldKey,
        floatingActionButton: buildActionButton(context),
        appBar: _buildAppBar(context),
        body: new TabBarView(
          controller: _tabController,
          children: [
            buildFavViewGrid(context, computeContactsFavTab()),
            buildContentListView(context, computeContactsActiveTab()),
            buildContentListView(context, computeContactsInactiveTab()),
          ],
        ));
  }

  Widget _buildAppBar(BuildContext context) {
    if (_isSelectionMode) {
      return _buildSelectionAppBar(context);
    } else if (_isSearchMode) {
      return _buildSearchAppBar(context);
    } else {
      return buildMainAppBar(context);
    }
  }

  Widget buildContentListView(BuildContext context, Contacts contacts) {
    return new ContactListView(
        contacts: contacts,
        selected: _selected.immutable(),
        onContactTap: onContactTap,
        onContactLongPress: onContactLongPress);
  }

  Widget buildFavViewGrid(BuildContext context, Contacts contacts) {
    return new FavGridView(
        contacts: contacts,
        selected: _selected.immutable(),
        onContactTap: onContactTap,
        onContactLongPress: onContactLongPress);
  }

  void onContactTap(BuildContext context, Contact contact) {
    if (_isSelectionMode) {
      setState(() {
        _selected.toggleSelection(contact.id);
      });
    } else {
      widget.navToContactEdit(context, contact.id);
    }
  }

  void onContactLongPress(BuildContext context, Contact contact) {
    if (!_isSelectionMode) {
      onSelectionModeBegin(context, contact.id);
    }
  }

  void onSelectionModeBegin(BuildContext context, Id firstId) {
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

  @override
  void dispose() {
    super.dispose();
    listenable.removeListener(this.myListener);
  }

  void onSearchModeBegin(BuildContext context) {
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
    });
  }

  String get currentQuery {
    return _searchController.text;
  }

  bool searchFilter(Contact c) {
    String q = currentQuery;
    return Filters.createSearchStringFilter(q)(c);
  }

  bool currentFilterFavTab(Contact c) {
    Filter f1 = Filters.favFilter;
    Filter f2 = _isSearchMode ? searchFilter : Filters.trueFilter;
    return f1(c) && f2(c);
  }

  bool currentFilterActiveTab(Contact c) {
    Filter f1 = Filters.activeFilter;
    Filter f2 = _isSearchMode ? searchFilter : Filters.trueFilter;
    return f1(c) && f2(c);
  }

  bool currentFilterInactiveTab(Contact c) {
    Filter f1 = Filters.inactiveFilter;
    Filter f2 = _isSearchMode ? searchFilter : Filters.trueFilter;
    return f1(c) && f2(c);
  }

  Contacts computeContactsFavTab() {
    List<Contact> list = db.selectDefaultSort(currentFilterFavTab);
    return new Contacts(list);
  }

  Contacts computeContactsActiveTab() {
    List<Contact> list = db.selectDefaultSort(currentFilterActiveTab);
    return new Contacts(list);
  }

  Contacts computeContactsInactiveTab() {
    List<Contact> list = db.selectDefaultSort(currentFilterInactiveTab);
    return new Contacts(list);
  }

  Widget buildActionButton(BuildContext context) {
    if (_isSelectionMode) return null;
    if (_isSearchMode) return null;
    return new FloatingActionButton(
        onPressed: () {
          widget.navToContactNew(context);
        },
        child: const Icon(Icons.add));
  }

  Filter computeCurrentFilter(int currentTabIndex) {
    switch (currentTabIndex) {
      case 0:
        return currentFilterFavTab;
      case 1:
        return currentFilterActiveTab;
      case 2:
        return currentFilterInactiveTab;
      default:
        throw new StateError("");
    }
  }

  int computeCurrentLength() {
    Filter currentFilter = computeCurrentFilter(currentTabIndex);
    return db.count(currentFilter);
  }

  String buildPageTitle() {
    int length = computeCurrentLength();
    String title = tabInfo.title;
    return "$title [$length]";
  }

  Widget _buildSearchAppBar(BuildContext context) {
    return new AppBar(
      title: new TextField(
        //        autofocus: true,
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
      bottom: buildTabBar(context),
    );
  }

  void onPressedNavToFavorites(BuildContext context) {
    widget.navToFavorites(context);
  }

  Widget _buildSelectionAppBar(BuildContext context) {
    return new AppBar(
      //      backgroundColor: Theme.of(context).canvasColor,
      leading: new IconButton(
          icon: const Icon(Icons.cancel),
          onPressed: () {
            setState(() {
              Navigator.pop(context);
            });
          }),
      title: new Text(_selected.length.toString()),
      actions: <Widget>[
        new IconButton(
          icon: Icon(Icons.delete),
          onPressed: () async {
            bool confirmed = await _showDeleteDialog(context);
            if (confirmed) {
              widget.onDeleteAll(context, IdSet(_selected));
              postDeleteSnack();
              Navigator.pop(context);
            }
          },
        )
      ],
      bottom: buildTabBar(context),
    );
  }

  Widget buildMainAppBar(BuildContext context) {
    String title = buildPageTitle();
    return AppBar(
        title: Text(title),
        actions: <Widget>[
          new IconButton(icon: Icon(Icons.search), onPressed: () => onSearchModeBegin(context)),
          new IconButton(icon: Icon(Icons.favorite), onPressed: () => onPressedNavToFavorites(context)),
          widget.menuBuilder(context)
        ],
        bottom: buildTabBar(context));
  }

  TabBar buildTabBar(BuildContext context) {
    Tab f(TabInfo ti) => ti.buildTab(context);
    List<Tab> tabs = _tabInfos.map(f).toList();
    return TabBar(controller: _tabController, tabs: tabs);
  }

  Future<bool> _showDeleteDialog(BuildContext context) async {
    return showOkCancelDialog(
        context: context, content: 'Delete ${_selected.length} selected records?', okText: "Delete");
  }

  int get currentTabIndex => _tabController.index;

  TabInfo get tabInfo => _tabInfos[currentTabIndex];

  void postDeleteSnack() {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text('Purchased ${43} for ${"fred"}'),
      action: new SnackBarAction(
        label: 'BUY MORE',
        onPressed: () {
          print("onPressed");
        },
      ),
    ));
  }
}
