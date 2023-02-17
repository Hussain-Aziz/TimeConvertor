import 'package:TimeConvertor/api_keys.dart';
import 'package:dio/dio.dart';

final dio = Dio();

class GetFromTimeZoneDB {
  // static Future<int> getUTCOffsetByLocation(double longitude, double latitude) async {
  //
  // }


  static Future<int> getUTCOffsetByZone(String zone) async {
    if (zoneFixes.containsKey(zone)) {
      zone = zoneFixes[zone]!;
    }

    return getUTCOffsetWithAddionalParams({
      'by': 'zone',
      'zone' : zone,
    });
  }


  static Future<int> getUTCOffsetWithAddionalParams(Map<String, String> additionalParams) async {
    return getUTCOffset({
      'key': APIKeys.timeZoneDBAPI,
      'format': 'json',
      ...additionalParams
    });
  }

  static Future<int> getUTCOffset(Map<String, String> queryParams) async {

    int offset = 0;

    while(true) {
      try {
        Response response = await dio.get(
            'http://api.timezonedb.com/v2.1/get-time-zone',
            queryParameters: queryParams);

        var responseMap = response.data as Map<String, dynamic>;

        offset = responseMap['gmtOffset']; //if status is 400, it'll throw
        break;

      } on DioError catch (e) {

        switch (e.type)
        {
          case DioErrorType.badResponse:
            throw Exception("Could not get offset of timezone because ${e.message}\nRequest response: ${e.response?.data['message']}\nQuery: $queryParams");
          case DioErrorType.connectionTimeout:
          case DioErrorType.connectionError:
          case DioErrorType.cancel:
          case DioErrorType.receiveTimeout:
          case DioErrorType.sendTimeout:
          case DioErrorType.unknown:
          //just retry
            await Future.delayed(const Duration(seconds: 2));
            getUTCOffset(queryParams);
            break;

          default:
            rethrow;
        }
      }
    }
    return offset;
  }

  /*
  "status": "OK",
    "message": "",
    "countryCode": "US",
    "countryName": "United States",
    "regionName": "",
    "cityName": "",
    "zoneName": "America\/Chicago",
    "abbreviation": "CST",
    "gmtOffset": -21600,
    "dst": "0",
    "zoneStart": 1667718000,
    "zoneEnd": 1678607999,
    "nextAbbreviation": "CDT",
    "timestamp": 1676620441,
    "formatted": "2023-02-17 07:54:01"
   */

  //for some reason timezonedb has these with 3 names idk why
  static final Map<String, String> zoneFixes = {
    "America/Buenos_Aires": "America/Argentina/Buenos_Aires",
    "America/Catamarca": "America/Argentina/Catamarca",
    "America/Cordoba": "America/Argentina/Cordoba",
    "America/Jujuy": "America/Argentina/Jujuy",
    "America/La_Rioja": "America/Argentina/La_Rioja",
    "America/Mendoza": "America/Argentina/Mendoza",
    "America/Rio_Gallegos": "America/Argentina/Rio_Gallegos",
    "America/Salta": "America/Argentina/Salta",
    "America/San_Juan": "America/Argentina/San_Juan",
    "America/San_Luis": "America/Argentina/San_Luis",
    "America/Tucuman": "America/Argentina/Tucuman",
    "America/Ushuaia": "America/Argentina/Ushuaia",
    "America/Indianapolis": "America/Indiana/Indianapolis",
    "America/Knox": "America/Indiana/Knox",
    "America/Marengo": "America/Indiana/Marengo",
    "America/Petersburg": "America/Indiana/Petersburg",
    "America/Tell_City": "America/Indiana/Tell_City",
    "America/Vevay": "America/Indiana/Vevay",
    "America/Vincennes": "America/Indiana/Vincennes",
    "America/Winamac": "America/Indiana/Winamac",
    "America/Louisville": "America/Kentucky/Louisville",
    "America/Monticello": "America/Kentucky/Monticello",
    "America/Beulah": "America/North_Dakota/Beulah",
    "America/Center": "America/North_Dakota/Center",
    "America/New_Salem": "America/North_Dakota/New_Salem",
  };
}
