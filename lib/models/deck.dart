import 'dart:async';
import 'dart:core';

import 'package:firebase_database/firebase_database.dart';
import 'package:meta/meta.dart';

import 'base/enum.dart';
import 'base/keyed_list.dart';
import 'base/observable_list.dart';
import 'deck_access.dart';

enum DeckType { basic, german, swiss }

class Deck implements KeyedListItem {
  final String uid;
  String key;

  String name;
  bool markdown;
  DeckType type;
  bool accepted;
  DateTime lastSyncAt;
  String category;

  Deck(
    this.uid, {
    @required this.name,
    this.markdown: false,
    this.type: DeckType.basic,
    this.accepted: true,
    this.lastSyncAt,
    this.category,
  }) {
    lastSyncAt ??= new DateTime.fromMillisecondsSinceEpoch(0);
  }

  Deck.fromSnapshot(this.key, snapshotValue, this.uid) {
    _parseSnapshot(snapshotValue);
  }

  void _parseSnapshot(snapshotValue) {
    name = snapshotValue['name'];
    markdown = snapshotValue['markdown'] ?? false;
    type = Enum.fromString(
        snapshotValue['deckType']?.toString()?.toLowerCase(), DeckType.values);
    accepted = snapshotValue['accepted'] ?? false;
    lastSyncAt = new DateTime.fromMillisecondsSinceEpoch(
        snapshotValue['lastSyncAt'],
        isUtc: true);
    category = snapshotValue['category'];
  }

  static Stream<KeyedListEvent<Deck>> getDecks(String uid) async* {
    yield new KeyedListEvent(
        eventType: ListEventType.set,
        fullListValueForSet: ((await FirebaseDatabase.instance
                    .reference()
                    .child('decks')
                    .child(uid)
                    .orderByKey()
                    .onValue
                    .first)
                .snapshot
                .value as Map)
            .entries
            .map((item) => new Deck.fromSnapshot(item.key, item.value, uid)));
    yield* childEventsStream(
        FirebaseDatabase.instance
            .reference()
            .child('decks')
            .child(uid)
            .orderByKey(),
        (snapshot) => new Deck.fromSnapshot(snapshot.key, snapshot.value, uid));
  }

  Stream<void> get updates => FirebaseDatabase.instance
      .reference()
      .child('decks')
      .child(key)
      .onValue
      .map((event) => _parseSnapshot(event.snapshot));

  Future<void> save() {
    var data = new Map<String, dynamic>();

    if (key == null) {
      key = FirebaseDatabase.instance
          .reference()
          .child('decks')
          .child(uid)
          .push()
          .key;
      data['deck_access/$key'] = {
        '$uid': {
          'access': Enum.asString(AccessType.owner),
        },
      };
    }

    data['decks/$uid/$key'] = _toMap();
    return FirebaseDatabase.instance.reference().update(data);
  }

  Stream<AccessType> getAccess() => FirebaseDatabase.instance
      .reference()
      .child('deck_access')
      .child(key)
      .child(uid)
      .child('access')
      .onValue
      .map((evt) => Enum.fromString(evt.snapshot.value, AccessType.values));

  Stream<int> getNumberOfCardsToLearn([int limit = 201]) =>
      FirebaseDatabase.instance
          .reference()
          .child('learning')
          .child(uid)
          .child(key)
          .orderByChild('repeatAt')
          .endAt(new DateTime.now().toUtc().millisecondsSinceEpoch)
          .limitToFirst(limit)
          .onValue
          .map((evt) => (evt.snapshot.value as Map)?.length ?? 0);

  Map<String, dynamic> _toMap() => {
        'name': name,
        'markdown': markdown,
        'type': Enum.asString(type)?.toUpperCase(),
        'accepted': accepted,
        'lastSyncAt': lastSyncAt.toUtc().millisecondsSinceEpoch,
        'category': category,
      };
}
