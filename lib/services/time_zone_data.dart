import 'package:json_annotation/json_annotation.dart';

class TimeZoneData {
  TimeZoneData(this.index, this.name, this.offset, this.longitude, this.latitude);
  int index;
  String name;
  int offset;
  double latitude;
  double longitude;

  Map<String, dynamic> toMap() {
    return {
      'index': index,
      'name': name,
      'offset': offset,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

   static TimeZoneData fromMap(Map<String, dynamic> map) {
    return TimeZoneData(
      map['index'],
      map['name'],
      map['offset'],
      map['latitude'],
      map['longitude'],
    );
  }
}