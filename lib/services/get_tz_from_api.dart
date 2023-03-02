import 'package:TimeConvertor/data/time_zone_data.dart';
import 'package:TimeConvertor/utils/api_keys.dart';
import 'package:dio/dio.dart';

//get time zone by zone from world time api which doesnt have a restriction and
//and by location from timezonedb which has a 1 second delay between responses.

const int maxRequestRetrys = 10;

final dio = Dio();

class GetTZFromAPI {
  static Future<Map<String, dynamic>> getZoneDataFromPosition(
      double latitude, double longitude) async {
    Map<String, String> queryParams = {
      'key': APIKeys.timeZoneDBAPI,
      'format': 'json',
      'by': 'position',
      'lat': latitude.toString(),
      'lng': longitude.toString(),
    };

    Map<String, dynamic>? responseData;

    int trys = 0;

    while (trys < maxRequestRetrys) {
      trys++;
      try {
        Response response = await dio.get(
            'http://api.timezonedb.com/v2.1/get-time-zone',
            queryParameters: queryParams);

        responseData = response.data as Map<String, dynamic>;

        break;
      } on DioError catch (e) {
        switch (e.type) {
          case DioErrorType.badResponse:
            throw Exception(
                "Could not get data of timezone because ${e.message}\nRequest response: ${e.response?.data['message']}\nQuery: $queryParams");
          case DioErrorType.connectionTimeout:
          case DioErrorType.connectionError:
          case DioErrorType.cancel:
          case DioErrorType.receiveTimeout:
          case DioErrorType.sendTimeout:
          case DioErrorType.unknown:
            //just wait and while loop will cause it to retry
            await Future.delayed(const Duration(milliseconds: 500));
            break;

          default:
            rethrow;
        }
      }
    }

    if (responseData != null) {
      return responseData;
    } else {
      throw Exception("Could not get zone data after 10 trys");
    }
  }

  static Future<int> getUTCOffsetByZone(String zone) async {
    if (zoneFixes.containsKey(zone)) {
      zone = zoneFixes[zone]!;
    }

    int? offset;
    int trys = 0;
    while (trys < maxRequestRetrys) {
      trys++;
      try {
        Response response =
            await dio.get('http://worldtimeapi.org/api/timezone/$zone');

        var responseMap = response.data as Map<String, dynamic>;

        offset = responseMap['raw_offset'];

        break;
      } on DioError catch (e) {
        switch (e.type) {
          case DioErrorType.badResponse:
            throw Exception(
                "Could not get offset of timezone because ${e.message}\nzone was: $zone");
          case DioErrorType.connectionTimeout:
          case DioErrorType.connectionError:
          case DioErrorType.cancel:
          case DioErrorType.receiveTimeout:
          case DioErrorType.sendTimeout:
          case DioErrorType.unknown:
            //just wait and the while loop will retry
            await Future.delayed(const Duration(seconds: 1, milliseconds: 100));
            break;

          default:
            rethrow;
        }
      }
    }

    if (offset != null) {
      return offset;
    } else {
      throw Exception("Could not get offset after 10 trys");
    }
  }

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
