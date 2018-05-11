import 'package:collection/collection.dart';

enum Col { Red, Green, Blue }
enum Level { Beginner, Intermediate, Advanced }

class Contact {
  final Id id;
  final String firstName;
  final String lastName;
  final bool active;
  final bool favorite;
  final String nat;
  final String thumbnail;

  const Contact(
      {this.id,
      this.firstName,
      this.lastName,
      this.active = false,
      this.favorite = false,
      this.nat = "US",
      this.thumbnail});

  String get fullName => "$firstName $lastName";

  @override
  String toString() {
    return 'Person{firstName: $firstName, lastName: $lastName active: $active}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Contact && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id != null ? id.hashCode : 0;
}

class MutableContacts extends DelegatingList<Contact> {
  final List<Contact> _base;

  MutableContacts([List<Contact> base])
      : this._base = base ?? <Contact>[],
        super(base ?? <Contact>[]);

  Contacts toImmutable() {
    return Contacts(_base);
  }
}

class Contacts extends UnmodifiableListView<Contact> {
  Contacts(List<Contact> delegate) : super(delegate ?? []);

  static final Contacts _empty = Contacts([]);

  static Contacts get empty => _empty;
}

class Id {
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
}

void main() {
  MutableContacts xx = new MutableContacts([]);
  for (var o in xx) {
    print(o);
  }


}
