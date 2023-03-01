import 'package:TimeConvertor/data/time_zone_data.dart';
import 'package:TimeConvertor/utils/consts.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

abstract class Stream<T> {
  @protected
  BehaviorSubject subject = BehaviorSubject<T>();
  ValueStream<dynamic> get stream => subject.stream;

  T get get => subject.value;

  void set(T newValue) {
    subject.add(newValue);
  }
}

class FormatStream extends Stream<Format> {}

class TimeZoneDataStream extends Stream<List<TimeZoneData>> {
  ///adds the new tiemzone data to list and resets id to be the correct one
  ///returns the correct id
  int addAndSetId(TimeZoneData newValue) {
    final list = get;
    newValue.id = get.length;
    list.add(newValue);
    set(list);
    return newValue.id;
  }

  void removeAndFixId(int id) {
    final list = get;
    list.removeAt(id);
    for (int i = id; i < list.length; i++) {
      list.elementAt(i).id = i + 1;
    }
    set(list);
  }
}

class ConnectedStream extends Stream<bool> {}
