import 'dart:async';

import 'package:contacts/contact_list_view.dart';
import 'package:contacts/contacts.dart';
import 'package:contacts/ui_common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ssutil_flutter/ssutil_flutter.dart';

class ContactsPage extends SsStatefulWidget {
  static const String prefix = "/";

  final Db db;
  final Listenable dbListenable;

//  final DbQuery<int> getCount;
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
  State createState() {
    return new ContactsPageState();
  }

  List<Tab> createTabs() {
    return [createAllTab(), createActiveTab()];
  }

  Tab createAllTab() {
    return createTab(TabId.all, 0, Icons.favorite, "All");
  }

  Tab createTab(TabId tabId, int index, IconData iconData, String title) {
    return Tab(tabId: tabId, index: index, iconData: iconData, title: title);
  }

  Tab createActiveTab() {
    return createTab(TabId.active, 1, Icons.favorite, "Active");
  }
}

class Tab {
  final TabId tabId;
  final int index;
  final IconData iconData;
  final String title;

  Tab({this.tabId, this.index, this.iconData, this.title});

  BottomNavigationBarItem buildBottomNavigationBarItem(BuildContext context) {
    return new BottomNavigationBarItem(
      icon: new Icon(iconData),
      title: Text(title.toUpperCase()),
    );
  }
}

class ContactsPageState extends SsState<ContactsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: "ContactsPageKey");

  bool _isSearchMode = false;

  MutableIdSet _selected = MutableIdSet();

  List<Tab> tabs;
  Tab currentTab;

  Contacts contacts = Contacts.empty;

  final TextEditingController controller = new TextEditingController();

  Listenable listenable;

  @override
  void initState() {
    super.initState();
    tabs = widget.createTabs();
    setCurrentTab(0);

    listenable = new Listenable.merge(<Listenable>[widget.dbListenable, controller]);

    listenable.addListener(this.myListener);
  }

  void myListener() {
    print("change event");
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
        bottomNavigationBar: _buildBottomNavBar(),
        body: buildBody(context));
  }

  Widget buildDataView(BuildContext context, Contacts contacts) {
    return new ContactListView(
        contacts: contacts,
        selected: this._selected.immutable(),
        onContactTap: onContactTap,
        onContactLongPress: onContactLongPress);
  }

  Widget buildBody(BuildContext context) {
    Contacts contacts = computeCurrentContacts();
    return buildDataView(context, contacts);
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
      onBeginSelectionMode(context, contact.id);
    }
  }

  void onBeginSelectionMode(BuildContext context, Id firstId) {
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

  void onBeginSearchMode(BuildContext context) {
    ModalRoute.of(context).addLocalHistoryEntry(new LocalHistoryEntry(
      onRemove: () {
        setState(() {
          _isSearchMode = false;
          controller.clear();
        });
      },
    ));
    setState(() {
      this._isSearchMode = true;
    });
  }

  void onSearchModeEnd(BuildContext context) {
    setState(() {
      _isSearchMode = false;
    });
  }

  void setCurrentTab(int index) {
    setState(() {
      currentTab = tabs[index];
    });
  }

  List<BottomNavigationBarItem> buildBottomItems() {
    List<BottomNavigationBarItem> a = [];
    for (Tab tab in tabs) {
      a.add(new BottomNavigationBarItem(
        backgroundColor: Colors.yellow,
        icon: new Icon(tab.iconData),
        title: Text(tab.title.toUpperCase()),
      ));
    }
    return a;
  }

  BottomNavigationBar _buildBottomNavBar() {
    return new BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      onTap: setCurrentTab,
      items: buildBottomItems(),
      currentIndex: currentTab.index,
    );
  }

  String buildPageTitle() {
    int length = computeCurrentLength();
    String title = currentTab.title;
    return "$title Contacts [$length]";
  }

  Widget _buildSearchAppBar(BuildContext context) {
    return new AppBar(
      title: new TextField(
        //        autofocus: true,
        controller: controller,
        decoration: new InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: "Find contacts",
            isDense: true,
            suffixIcon: (controller.text == null || controller.text.isEmpty)
                ? null
                : new IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: () {
                      setState(() {
                        controller.clear();
                      });
                    })),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    if (_isSelectionMode) {
      return _buildSelectionAppBar(context);
    } else if (_isSearchMode) {
      return _buildSearchAppBar(context);
    } else {
      return _buildMainAppBar(context);
    }
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
        ]);
  }

  Widget _buildMainAppBar(BuildContext context) {
    String title = buildPageTitle();
    return new AppBar(
      title: Text(title),
      actions: <Widget>[
        new IconButton(icon: Icon(Icons.search), onPressed: () => onBeginSearchMode(context)),
        new IconButton(icon: Icon(Icons.favorite), onPressed: () => onPressedNavToFavorites(context)),
        widget.menuBuilder(context)
      ],
    );
  }

  void onPressedNavToFavorites(BuildContext context) {
    widget.navToFavorites(context);
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

  bool get _isActiveMode {
    return currentTab.tabId == TabId.active;
  }

  Future<bool> _showDeleteDialog(BuildContext context) async {
    return showOkCancelDialog(
        context: context, content: 'Delete ${_selected.length} selected records?', okText: "Delete");
  }

  String get currentQuery {
    return controller.text;
  }

  bool searchFilter(Contact c) {
    String q = currentQuery;
    return Filters.createSearchStringFilter(q)(c);
  }

  bool currentFilter(Contact c) {
    Filter f1 = _isActiveMode ? Filters.activeFilter : Filters.trueFilter;
    Filter f2 = _isSearchMode ? searchFilter : Filters.trueFilter;
    return f1(c) && f2(c);
  }

  Contacts computeCurrentContacts() {
    List<Contact> list = db.selectDefaultSort(currentFilter);
    return new Contacts(list);
  }

  int computeCurrentLength() {
    return db.count(currentFilter);
  }

  void dumpCurrentFilterInfo() {
    Filter f = currentFilter;
    print("currentFilter[$f]");
    print("  isActiveMode[$_isActiveMode");
    print("  isSearchMode[$_isSearchMode");
    print("  isSelectionMode[$_isSelectionMode");
    print("  currentQuery[$currentQuery]");
  }

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
