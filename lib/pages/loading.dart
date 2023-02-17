import 'package:TimeConvertor/services/get_from_timezonedb.dart';
import 'package:TimeConvertor/services/get_local_timezone.dart';
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

  @override
  void initState() {
    getLocalTimeZone();
    super.initState();
  }
  String loadingText = "Loading...";
  bool isError = false;
  bool splashRemoved = false;

  void getLocalTimeZone() async {
    try {

      final prefs = await SharedPreferences.getInstance();

      int? offset = prefs.getInt('localUTCOffset');

      if (offset != null)
      {
        return leave(offset, true);
      }

      // so error can be shown
      Future.delayed(const Duration(seconds: 3), () {
        removeSplashScreen();
      });

      String zone = await GetLocalTimeZone.get();

      changeLoadingText("Loading...\nGetting Local UTC Offset.\n\nPlease make sure you are connected to the internet");

      offset = (await GetFromTimeZoneDB.getTZDBResponseByZone(zone)).gmtOffset;

      prefs.setInt('localUTCOffset', offset);

      return leave(offset, false);

    } catch (e){
      isError = true;
      changeLoadingText("Loading...\nGetting Local UTC Offset.\n\nPlease make sure you are connected to the internet");
      removeSplashScreen();
    }
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
      splashRemoved = true;
      FlutterNativeSplash.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
          children: [
            const Center(
              child: SpinKitDoubleBounce(color: Colors.blue, size: 100),
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

  void leave(int localUtcOffset, bool reCheckTimeZone){
    Map<String,dynamic> args = {
      'offset': localUtcOffset,
      'reCheckTimeZone' : reCheckTimeZone,
    };
    Navigator.pushReplacementNamed(context, "/main", arguments: args);
    removeSplashScreen();
  }
}
