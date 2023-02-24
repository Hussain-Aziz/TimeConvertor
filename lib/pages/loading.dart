// ignore_for_file: use_build_context_synchronously

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
import 'package:connectivity_plus/connectivity_plus.dart';

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

  late Future<void> persistenceDataLoad;
  late Future<void> sharedPreferencesLoad;

  late int localUTCOffset;

  @override
  void initState() {
    initLoading();
    super.initState();
  }

  void initLoading() async {

    //get these started
    sharedPreferencesLoad = loadSharedPreferences();
    persistenceDataLoad = loadPersistentStorage();

    //hook connectivity change, this will be useful when prompting to connect and when creating new locations
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      var oldConnection = getIt.get<ConnectedStream>().get;
      var stillIsConnected = [ConnectivityResult.wifi, ConnectivityResult.mobile].contains(result);

      if (oldConnection != stillIsConnected){
        getIt.get<ConnectedStream>().set(stillIsConnected);
      }
    });

    //we need to await for connectivity result to make decision
    final connectivity = await (Connectivity().checkConnectivity());

    final isConnected = [ConnectivityResult.wifi, ConnectivityResult.mobile].contains(connectivity);
    getIt.get<ConnectedStream>().set(isConnected);

    //if we are connected
    if (!isConnected) {

      await sharedPreferencesLoad;//make sure this has loaded (probably has)
      int? offset = localStorage.getInt(Consts.localUTCOffsetLSName);

      if (offset != null) { //if not connected and we have a previous offset saved, then just leave we dont need wifi
        saveLocalOffset(offset);
        return leave();
      } else { // we need initial time zone data. we probably could get it from device but nah
        await promptConnectToInternet();
      }
    }

    try {
      changeLoadingText("Loading...\nGetting Local UTC Offset.\n\nPlease make sure you are connected to the internet");

      // so errors can be shown
      Future.delayed(const Duration(seconds: 5), () {
        removeSplashScreen();
      });

      String zone = await FlutterNativeTimezone.getLocalTimezone();
      int offset = (await GetFromTimeZoneDB.getTZDBResponseByZone(zone)).gmtOffset;

      saveLocalOffset(offset);

      return leave();

    } catch (e) {
      isError = true;
      changeLoadingText("Loading...\nSome error occurred\n\n$e}");
      removeSplashScreen();
    }
  }

  Future<void> loadPersistentStorage() async {
    database = await SQLDatabase.loadDatabase();
    final data = await SQLDatabase.getAll(database);
    getIt.get<TimeZoneDataStream>().set(data);
  }

  Future<void> loadSharedPreferences() async {
    localStorage = await SharedPreferences.getInstance();

    var formatStr = localStorage.getString(Consts.formatLSName);
    formatStr ??= Format.f12h.toString(); //default

    final format = Format.values.firstWhere((e) => e.toString() == formatStr);
    final formatStream = getIt.get<FormatStream>();
    formatStream.set(format);

    await localStorage.setString(Consts.formatLSName, format.toString());
  }

  void saveLocalOffset(int offset){
    localStorage.setInt(Consts.localUTCOffsetLSName, offset);
    localUTCOffset = offset;
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

    await Future.wait([persistenceDataLoad]);

    Map<String, int> args = {
      "offset" : localUTCOffset
    };
    Navigator.pushReplacementNamed(context, "/main", arguments: args);
    removeSplashScreen();
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

  Future<void> promptConnectToInternet() async {
    removeSplashScreen();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Internet Connection'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('This app needs connection to internet to work.'),
                Text('Please connect to the internet to continue'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                if (getIt.get<ConnectedStream>().get) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
