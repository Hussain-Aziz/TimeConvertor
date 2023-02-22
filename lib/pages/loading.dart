import 'package:TimeConvertor/main.dart';
import 'package:TimeConvertor/services/sql_database.dart';
import 'package:TimeConvertor/utils/consts.dart';
import 'package:TimeConvertor/services/get_from_timezonedb.dart';
import 'package:TimeConvertor/utils/streams.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {

  late SharedPreferences localStorage;
  String loadingText = "";
  bool isError = false;
  bool splashRemoved = false;

  late Future<void> localDataLoad;

  @override
  void initState() {
    initLoading();
    super.initState();
  }

  void initLoading() async {

    await getLocalStorage();

    localDataLoad = loadLocalData();

    addFormatToStream();

    if (tryGetOffsetFromLS()){
      return leave();
    }

    // so errors can be shown
    Future.delayed(const Duration(seconds: 3), () {
      removeSplashScreen();
    });

    try {
      changeLoadingText("Loading...\nGetting Local UTC Offset.\n\nPlease make sure you are connected to the internet");

      int offset = await getOffsetFromDB();

      saveLocalOffset(offset);

      return leave();

    } catch (e) {
      isError = true;
      changeLoadingText("Loading...\nGetting Local UTC Offset.\n\nPlease make sure you are connected to the internet");
      removeSplashScreen();
    }
  }

  Future<void> getLocalStorage() async {
    localStorage = await SharedPreferences.getInstance();
  }

  Future<int> getOffsetFromDB() async {
    String zone = await FlutterNativeTimezone.getLocalTimezone();
    return (await GetFromTimeZoneDB.getTZDBResponseByZone(zone)).gmtOffset;
  }

  bool tryGetOffsetFromLS() {
    int? offset = localStorage.getInt(Consts.localUTCOffsetLSName);
    if (offset != null)
    {
      updateOffsetInCaseOfLocationChange();
      saveLocalOffset(offset);
      return true;
    }
    return false;
  }

  void changeLoadingText(String newText) {
    setState(() {
      loadingText = newText;
    });
  }

  void removeSplashScreen() {
    if (!splashRemoved) {
      setState(() => splashRemoved = true);
      FlutterNativeSplash.remove();
    }
  }

  void leave() async {
    
    await Future.wait([localDataLoad]);
    
    Navigator.pushReplacementNamed(context, "/main");
    removeSplashScreen();
  }

  void addFormatToStream() {
    var formatStr = localStorage.getString(Consts.formatLSName);

    formatStr ??= Format.f12h.toString(); //default

    final format = Format.values.firstWhere((e) => e.toString() == formatStr);

    localStorage.setString(Consts.formatLSName, format.toString());
    getIt.get<FormatStream>().set(format);
  }

  void saveLocalOffset(int offset){
    localStorage.setInt(Consts.localUTCOffsetLSName, offset);
    getIt.get<LocalUTCOffsetStream>().set(offset);
  }

  void updateOffsetInCaseOfLocationChange() async {
    final offset = await getOffsetFromDB();
    saveLocalOffset(offset);
  }

  Future<void> loadLocalData() async {
    database = await SQLDatabase.loadDatabase();
    final data = await SQLDatabase.getAll(database);
    getIt.get<TimeZoneDataStream>().set(data);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
          children: [
            Center(
              child: SpinKitDoubleBounce(color: splashRemoved ? Colors.blue : Colors.white, size: 100),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
                child: Text(loadingText,
                    overflow: TextOverflow.visible,
                    maxLines: 10,
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        overflow: TextOverflow.visible,
                        color: isError ? Colors.red[600] : Colors.blue[700],
                        fontSize: 18,
                        decoration: TextDecoration.none
                    )),
              ),
            )
          ]
      ),
    );
  }
}
