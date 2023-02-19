import 'package:TimeConvertor/utils/consts.dart';
import 'package:rxdart/rxdart.dart';

class FormatStream
{
  BehaviorSubject _format = BehaviorSubject<Format>();

  ValueStream<dynamic> get stream => _format.stream;

  Format get get => _format.value;

  set(Format newFormat){
    _format.add(newFormat);
  }
}