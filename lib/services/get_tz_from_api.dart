import 'package:TimeConvertor/env/env.dart';
import 'package:dio/dio.dart';

//get time zone by zone from world time api which doesnt have a restriction and
//and by location from timezonedb which has a 1 second delay between responses.

const int maxRequestRetrys = 10;

final dio = Dio();

class GetTZFromAPI {
  static Future<Map<String, dynamic>> getZoneDataFromPosition(
      double latitude, double longitude) async {
    Map<String, String> queryParams = {
      'key': Env.timeZoneDBAPI,
      'format': 'json',
      'by': 'position',
      'lat': latitude.toString(),
      'lng': longitude.toString(),
    };

    return await getDataFromTimeZoneDB(queryParams);
  }

  static Future<int> getUTCOffsetByZoneFromTimeZoneDB(String zone) async {
    if (zoneFixes.containsKey(zone)) {
      zone = zoneFixes[zone]!;
    }

    Map<String, String> queryParams = {
      'key': Env.timeZoneDBAPI,
      'format': 'json',
      'by': 'zone',
      'zone': zone
    };

    var response = await getDataFromTimeZoneDB(queryParams);
    return response['gmtOffset'];
  }

  static Future<int> getUTCOffsetByZoneFromWorldTimeAPI(String zone) async {
    if (zoneFixes.containsKey(zone)) {
      zone = zoneFixes[zone]!;
    }

    var response =
        await getDataFromAPI('http://worldtimeapi.org/api/timezone/$zone');

    return response['raw_offset'];
  }

    static Future<Map<String, dynamic>> getDataFromTimeZoneDB(
      Map<String, String> queryParams) {
    return getDataFromAPI('http://api.timezonedb.com/v2.1/get-time-zone',
        queryParams: queryParams);
  }

  static Future<Map<String, dynamic>> getDataFromAPI(String uri,
      {Map<String, String>? queryParams}) async {
    Map<String, dynamic>? responseData;

    int trys = 0;
    while (trys < maxRequestRetrys) {
      trys++;
      try {
        Response response = await dio.get(uri, queryParameters: queryParams);

        responseData = response.data as Map<String, dynamic>;

        break;
      } on DioError catch (e) {
        switch (e.type) {
          case DioErrorType.badResponse:
            throw Exception(
                "Could not get data from $uri because ${e.message}\nRequest response: ${e.response?.data['message']}${queryParams != null ? "\nQuery: $queryParams" : ""}");
          case DioErrorType.connectionTimeout:
          case DioErrorType.connectionError:
          case DioErrorType.cancel:
          case DioErrorType.receiveTimeout:
          case DioErrorType.sendTimeout:
          case DioErrorType.unknown:
            //just wait and while loop will cause it to retry
            await Future.delayed(const Duration(milliseconds: 1000));
            break;

          default:
            rethrow;
        }
      }
    }

    if (responseData != null) {
      return responseData;
    } else {
      throw Exception("Could not get data from $uri after 10 trys");
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
