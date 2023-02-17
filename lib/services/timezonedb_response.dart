import 'package:json_annotation/json_annotation.dart';
part 'timezonedb_response.g.dart';

//flutter pub run build_runner watch --delete-conflicting-outputs
@JsonSerializable()
class GetTimeZoneResponse {
  GetTimeZoneResponse(this.status, this.message, this.countryCode, this.countryName, this.regionName, this.cityName, this.zoneName, this.abbreviation, this.gmtOffset, this.dst, this.zoneStart, this.zoneEnd, this.nextAbbreviation, this.timestamp, this.formatted);

  String status;
  String message;
  String countryCode;
  String countryName;
  String regionName;
  String cityName;
  String zoneName;
  String abbreviation;
  int gmtOffset;
  String dst;
  int zoneStart;
  int zoneEnd;
  String nextAbbreviation;
  int timestamp;
  String formatted;

  factory GetTimeZoneResponse.fromJson(Map<String, dynamic> json) => _$GetTimeZoneResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GetTimeZoneResponseToJson(this);
}