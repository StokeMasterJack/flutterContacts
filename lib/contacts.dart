import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:contacts/sample_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiver/check.dart';
import 'package:ssutil/ssutil.dart' as ss;

enum Col { Red, Green, Blue }
enum Level { Beginner, Intermediate, Advanced }

typedef T ContactGetter<T>(Contact receiver);

class MutableContacts extends DelegatingList<Contact> {
  List<Contact> _base;

  MutableContacts(List<Contact> base) : super(base) {
    this._base = base;
  }

  Contacts immutable() {
    return Contacts(_base);
  }
}

class Contacts extends UnmodifiableListView<Contact> {
  final List<Contact> _base;

  Contacts([List<Contact> base])
      : this._base = base ?? <Contact>[],
        super(base ?? <Contact>[]);

  static final Contacts _empty = Contacts();

  static Contacts get empty => _empty;

  static List<Contact> fromJsonSync(dynamic jsonData) {
    List<Contact> a = <Contact>[];
    if (jsonData is Map) {
      Contact contact = Contact.fromJson(jsonData);
      a.add(contact);
    } else if (jsonData is List) {
      for (Map<String, dynamic> jsonMap in jsonData) {
        Contact contact = Contact.fromJson(jsonMap);
        a.add(contact);
      }
    } else {
      ss.throwStateErr();
    }
    return a;
  }

  static List<Contact> fromJsonTextSync(String jsonText) {
    dynamic jsonData = json.decode(jsonText);
    return fromJsonSync(jsonData);
  }

  static Future<List<Contact>> fromJsonText(String jsonText) {
    return compute(fromJsonTextSync, jsonText);
  }

  static List<Map<String, dynamic>> toJsonSync(List<Contact> contacts) {
    List<Map<String, dynamic>> a = <Map<String, dynamic>>[];
    for (Contact contact in contacts) {
      a.add(contact.toJson());
    }
    return a;
  }

  static String toJsonTextSync(List<Contact> contacts) {
    List<Map<String, dynamic>> jsonData = toJsonSync(contacts);
    return json.encode(jsonData);
  }

  static Future<String> toJsonText(List<Contact> contacts) {
    return compute(toJsonTextSync, contacts);
  }
}

class Id {
  static final _rng = Random();
  final int value;

  Id(this.value) : assert(value != null);

  @override
  String toString() {
    return value.toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Id && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;

  static Id gen() => new Id(_rng.nextInt(1 << 32));

  static Id parse(String sId) {
    checkArgument(int.tryParse != null);
    int iId = int.parse(sId);
    return Id(iId);
  }
}

class IdSet extends UnmodifiableSetView<Id> {
  static final IdSet _empty1 = new IdSet(Set<Id>());

  IdSet(Set<Id> ids)
      : assert(ids != null),
        super(ids);

  static IdSet get empty {
    assert(_empty1 != null);
    return _empty1;
  }
}

class MutableIdSet extends DelegatingSet<Id> {
  MutableIdSet() : super(new Set<Id>());

  IdSet immutable() {
    return IdSet(this);
  }

  void toggleSelection(Id id) {
    if (contains(id))
      remove(id);
    else
      add(id);
  }
}

Col parseCol(String sCol) {
  if (sCol == null || sCol.trim().isEmpty) return Col.Red;
  assert(sCol is String);
  for (Col value in Col.values) {
    if (describeEnum(value) == sCol) {
      assert(value is Col);
      return value;
    }
  }
  throw ArgumentError();
}

Level parseLevel(String sLevel) {
  if (sLevel == null || sLevel.trim().isEmpty) return Level.Beginner;
  for (Level value in Level.values) {
    if (describeEnum(value) == sLevel) {
      return value;
    }
  }
  throw ArgumentError();
}

class Contact {
  final Id id;
  final String firstName;
  final String lastName;
  final Col color;
  final Level level;
  final bool active;
  final bool favorite;
  final String nat;
  final String thumbnail;

  const Contact(
      {@required this.id,
      this.firstName,
      this.lastName,
      this.level = Level.Beginner,
      this.color = Col.Red,
      this.active = false,
      this.favorite = false,
      this.nat = "US",
      this.thumbnail});

  Contact.blank() : this(id: Id.gen());

  String get fullName => "$firstName $lastName";

  @override
  String toString() {
    return 'Person{firstName: $firstName, lastName: $lastName, col: $color, active: $active}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Contact && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id != null ? id.hashCode : 0;

  Map<String, dynamic> toJson() {
    assert(nat == null || nat is String);
    assert(color != null && color is Col);
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'color': describeEnum(color),
      'level': describeEnum(level),
      'active': active,
      'favorite': favorite,
      'nat': nat,
      'thumbnail': thumbnail,
    };
  }

  String toJsonText() {
    Map<String, dynamic> jsonMap = toJson();
    String jsonText = json.encode(jsonMap);
    return jsonText;
  }

  static Contact fromJson(Map<String, dynamic> map) {
    return new Contact(
      id: Id(map["id"]),
      firstName: map["firstName"],
      lastName: map["lastName"],
      color: parseCol(map["color"]),
      level: parseLevel(map["level"]),
      active: map["active"],
      favorite: map["favorite"],
      nat: map["nat"],
      thumbnail: map["thumbnail"],
    );
  }

  static Contact fromJsonText(String jsonText) {
    Map<String, dynamic> map = json.decode(jsonText);
    return fromJson(map);
  }

  String get avatarChar => ss.avatarChar(fullName);

//  matches(String query, TabKey tab) {
//
//  }

  bool matchesSearchFilter(String query) {
    assert(query != null);
    String q = query.trim().toUpperCase();
    if (q == "") return true;
    return fullName.toUpperCase().contains(q);
  }
}

class Field<T> {
  final ContactGetter<T> getter;
  final ss.EzComparator<T> ezComparator;

  const Field(this.getter, this.ezComparator);

  void sort(MutableContacts contacts, [bool asc = true]) {
    return contacts.sort(comparator(asc));
  }

  Comparator<Contact> comparator(bool asc) {
    return asc ? compareAsc : compareDesc;
  }

  int compareAsc(Contact a, Contact b) {
    return _nullSafeFieldCompare(a, b);
  }

  int compareDesc(Contact a, Contact b) {
    return -_nullSafeFieldCompare(a, b);
  }

  int _nullSafeFieldCompare(Contact a, Contact b) {
    return ss.nullSafeCompare<Contact>(a, b, _ezFieldCompare);
  }

  int _ezFieldCompare(Contact a, Contact b) {
    T aa = getter(a);
    T bb = getter(b);
    return ss.nullSafeCompare<T>(aa, bb, ezComparator);
  }

  static String _fullNameGetter(Contact c) => c.fullName;

  static bool _activeGetter(Contact c) => c.active;

  static const Field fullName = const Field<String>(_fullNameGetter, ss.ezStringCompare);
  static final Field active = Field<bool>(_activeGetter, ss.ezBoolCompare);
}

class Sort {
  final Field field;
  final bool asc;

  const Sort({this.field = Field.fullName, this.asc = true});

  void sort(MutableContacts contacts) {
    field.sort(contacts, asc);
  }

  static final Sort fullNameAsc = new Sort(field: Field.fullName, asc: true);
  static final Sort fullNameDesc = new Sort(field: Field.fullName, asc: false);

  static final Sort activeAsc = new Sort(field: Field.active, asc: true);
  static final Sort activeDesc = new Sort(field: Field.active, asc: false);
}

typedef bool Filter(Contact contact);

class Filters {
  static bool activeFilter(Contact c) => c.active;
  static bool inactiveFilter(Contact c) => !c.active;

  static bool trueFilter(Contact c) => true;

  static bool favFilter(Contact c) => c.favorite;

  static Filter createSearchStringFilter(String q) {
    return (Contact c) => c.matchesSearchFilter(q);
  }
}

class DbQuery {
  final Sort _sort;
  final Filter _filter;

  DbQuery([Filter filter, Sort sort])
      : this._sort = sort ?? Sort.fullNameAsc,
        this._filter = filter ?? Filters.trueFilter;

  static DbQuery fav = new DbQuery(Filters.favFilter, Sort.fullNameAsc);

  void sort(MutableContacts a) {
    _sort.sort(a);
  }

  Filter get filter => _filter;
}

class Db extends ChangeNotifier {
  static const defaultLocalFileName = "contacts.json";
  static const defaultLocalAssetName = "data/contacts.json";

  final Map<Id, Contact> map = <Id, Contact>{};

  Contact init() {
    return new Contact.blank();
  }

  Sort defaultSort = Sort.fullNameAsc;

  MutableContacts filter(Filter filter) {
    MutableContacts results = MutableContacts([]);
    for (Contact contact in iterable) {
      assert(contact != null);
      if (filter(contact)) {
        results.add(contact);
      }
    }
    return results;
  }

  Contacts select(DbQuery q) {
    MutableContacts a = filter(q.filter);
    q.sort(a);
    return a.immutable();
  }

  Contacts selectDefaultSort(Filter filter) {
    return select(DbQuery(filter, defaultSort));
  }

  int count(Filter filter) {
    int cnt = 0;
    for (Contact c in iterable) {
      if (filter(c)) {
        cnt++;
      }
    }
    return cnt;
  }

  int favCount() {
    return count(Filters.favFilter);
  }

  Contacts favorites() {
    return select(DbQuery.fav);
  }

  String toString() {
    return Db.safeToString(this);
  }

  void delete(Id id) {
    map.remove(id);
  }

  void deleteAll(IdSet ids) {
    map.removeWhere((Id id, _) => ids.contains(id));
  }

  void clear() {
    map.clear();
  }

  Contact getById(Id id) {
    return map[id];
  }

  void put(Contact contact) {
    map[contact.id] = contact;
  }

  void putJsonText(String jsonText) {
    dynamic jsonSomething = json.decode(jsonText);
    putJson(jsonSomething);
  }

  void putJson(dynamic jsonSomething) {
    if (jsonSomething is Map) {
      putJsonObject(jsonSomething);
    } else if (jsonSomething is List) {
      putJsonList(jsonSomething);
    } else {
      ss.throwStateErr();
    }
  }

  void putJsonObject(Map<String, dynamic> jsonObject) {
    Contact contact = Contact.fromJson(jsonObject);
    put(contact);
  }

  void putJsonList(List<Map<String, dynamic>> jsonContacts) {
    for (Map<String, dynamic> m in jsonContacts) {
      putJsonObject(m);
    }
  }

  void putContact(Map<String, dynamic> jsonContact) {
    Contact contact = Contact.fromJson(jsonContact);
    put(contact);
  }

  void putAll(Iterable<Contact> contacts) {
    for (Contact contact in contacts) {
      map[contact.id] = contact;
    }
  }

  Iterable<Contact> get iterable {
    return map.values;
  }

  Future<void> populateFromRandomUser(int n) async {
    await fetchSampleDataFromRandomUser(n);
  }

  Contact initContact(Id idOrNull) {
    if (idOrNull == null)
      return init();
    else
      return getById(idOrNull);
  }

  int get hashCode => identityHashCode(this);

  bool operator ==(other) {
    return identical(this, other);
  }

  Future<void> populateFromJsonAsset() async {
    String jsonText = await loadJsonAsset();
    List<Contact> contacts = await Contacts.fromJsonText(jsonText);
    putAll(contacts);
    notifyListeners();
  }

  Future<File> serializeToFile() async {
    List<Contact> list = toList();
    String jsonText = await Contacts.toJsonText(list);
    return writeTextFileToLocalDocDir(defaultLocalFileName, jsonText);
  }

  List<Map<String, dynamic>> toJsonSync() {
    List<Map<String, dynamic>> a = <Map<String, dynamic>>[];
    for (Contact c in iterable) {
      Map<String, dynamic> jsonMap = c.toJson();
      a.add(jsonMap);
    }
    return a;
  }

  String toJsonTextSync() {
    List<Map<String, dynamic>> a = toJsonSync();
    return json.encode(a);
  }

  List<Contact> toList() {
    List<Contact> a = <Contact>[];
    for (Contact contact in iterable) {
      a.add(contact);
    }
    return a;
  }

  static Future<String> loadJsonAsset() async {
    return rootBundle.loadString(defaultLocalAssetName);
  }

  static Future<File> writeTextFileToLocalDocDir(String localName, String data) async {
    final directory = await getApplicationDocumentsDirectory();
    String dirPath = directory.path;
    File file = new File('$dirPath/$localName');
    print("writing text file to file[$file]");
    return file.writeAsString(data);
  }

  static int safeHash(Db db) {
    return identityHashCode(db);
  }

  static String safeToString(Db db) {
    if (db == null)
      return "DbNull[${safeHash(db)}]";
    else
      return "DbNonNull[${safeHash(db)}]";
  }
}
