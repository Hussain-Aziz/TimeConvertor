import 'package:TimeConvertor/data/time_zone_data.dart';
import 'package:TimeConvertor/utils/consts.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

abstract class Stream<T>
{
  @protected
  BehaviorSubject subject = BehaviorSubject<T>();
  ValueStream<dynamic> get stream => subject.stream;

  T get get => subject.value;

  set(T newValue){
    subject.add(newValue);
  }
}

class FormatStream extends Stream<Format> {}
class TimeZoneDataStream extends Stream<List<TimeZoneData>> {}

class LocalUTCOffsetStream extends Stream<int>
{
  @override
  set(int newValue){
    if (subject.valueOrNull == null || subject.value != newValue) {
      super.set(newValue);
    }
  }
}

