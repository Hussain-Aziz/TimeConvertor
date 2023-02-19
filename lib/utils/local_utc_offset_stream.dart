import 'package:TimeConvertor/utils/consts.dart';
import 'package:rxdart/rxdart.dart';

class LocalUTCOffsetStream
{
  BehaviorSubject _offset = BehaviorSubject<int>();

  ValueStream<dynamic> get stream => _offset.stream;

  int get get => _offset.value;

  set(int offset){
    if (_offset.valueOrNull == null || _offset.value != offset) {
      _offset.add(offset);
    }
  }
}