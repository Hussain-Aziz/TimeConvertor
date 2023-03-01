class TimeZoneData {
  TimeZoneData(this.id, this.name, this.offset, this.zoneName);
  int id;
  String name;
  int offset;
  String zoneName;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'offset': offset,
      'zoneName': zoneName,
    };
  }

  static TimeZoneData empty() {
    return TimeZoneData(0, "", 0, "");
  }

  static TimeZoneData fromMap(Map<String, dynamic> map) {
    return TimeZoneData(
      map['id'],
      map['name'],
      map['offset'],
      map['zoneName'],
    );
  }
}
