class TimeZoneData {
  TimeZoneData(this.id, this.name, this.offset, this.longitude, this.latitude);
  int id;
  String name;
  int offset;
  double latitude;
  double longitude;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'offset': offset,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

   static TimeZoneData fromMap(Map<String, dynamic> map) {
    return TimeZoneData(
      map['id'],
      map['name'],
      map['offset'],
      map['latitude'],
      map['longitude'],
    );
  }
}