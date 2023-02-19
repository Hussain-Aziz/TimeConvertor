import 'package:TimeConvertor/main.dart';
import 'package:TimeConvertor/utils/consts.dart';
import 'package:TimeConvertor/services/get_from_timezonedb.dart';
import 'package:TimeConvertor/services/get_local_timezone.dart';
import 'package:TimeConvertor/utils/format_stream.dart';
import 'package:TimeConvertor/utils/local_utc_offset_stream.dart';
import 'package:flutter/material.dart';
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
  @override
  void initState() {
    initLoading();
    super.initState();
  }
  String loadingText = "";
  bool isError = false;
  bool splashRemoved = false;

  Future<void> getLocalStorage() async{
    localStorage = await SharedPreferences.getInstance();
  }

  void initLoading() async {

    await getLocalStorage();

    addFormatToStream();

    int? offset = localStorage.getInt(Consts.localUTCOffsetLSName);
    if (offset != null)
    {
      updateOffsetIncaseOfLocationChange();
      saveLocalOffset(offset);
      return leave();
    }

    // so error can be shown
    Future.delayed(const Duration(seconds: 3), () {
      removeSplashScreen();
    });

    try {
      changeLoadingText("Loading...\nGetting Local UTC Offset.\n\nPlease make sure you are connected to the internet");

      offset = await getOffsetFromDB();

      saveLocalOffset(offset);

      return leave();

    } catch (e){
      isError = true;
      changeLoadingText("Loading...\nGetting Local UTC Offset.\n\nPlease make sure you are connected to the internet");
      removeSplashScreen();
    }
  }

  Future<int> getOffsetFromDB() async{
    String zone = await GetLocalTimeZone.get();
    return (await GetFromTimeZoneDB.getTZDBResponseByZone(zone)).gmtOffset;
  }

  void changeLoadingText(String newText)
  {
    setState(() {
      loadingText = newText;
    });
  }

  void removeSplashScreen()
  {
    if (!splashRemoved)
    {
      setState(() => splashRemoved = true);
      FlutterNativeSplash.remove();
    }
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

  void leave() async {
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

  void updateOffsetIncaseOfLocationChange() async {
    final offset = await getOffsetFromDB();
    saveLocalOffset(offset);
  }
}
