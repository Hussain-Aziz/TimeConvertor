// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../data/timezonedb_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetTimeZoneResponse _$GetTimeZoneResponseFromJson(Map<String, dynamic> json) =>
    GetTimeZoneResponse(
      json['status'] as String,
      json['message'] as String,
      json['countryCode'] as String,
      json['countryName'] as String,
      json['regionName'] as String,
      json['cityName'] as String,
      json['zoneName'] as String,
      json['abbreviation'] as String,
      json['gmtOffset'] as int,
      json['dst'] as String,
      json['zoneStart'] as int,
      json['zoneEnd'] as int,
      json['nextAbbreviation'] as String,
      json['timestamp'] as int,
      json['formatted'] as String,
    );

Map<String, dynamic> _$GetTimeZoneResponseToJson(
        GetTimeZoneResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'countryCode': instance.countryCode,
      'countryName': instance.countryName,
      'regionName': instance.regionName,
      'cityName': instance.cityName,
      'zoneName': instance.zoneName,
      'abbreviation': instance.abbreviation,
      'gmtOffset': instance.gmtOffset,
      'dst': instance.dst,
      'zoneStart': instance.zoneStart,
      'zoneEnd': instance.zoneEnd,
      'nextAbbreviation': instance.nextAbbreviation,
      'timestamp': instance.timestamp,
      'formatted': instance.formatted,
    };
