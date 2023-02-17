import 'dart:io';
import 'package:TimeConvertor/services/get_from_timezonedb.dart';
import 'package:TimeConvertor/services/get_local_timezone.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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

  void getLocalTimeZone() async {
    try {
      setState(() {
        loadingText = "Loading...\nGetting Local Timezone";
      });
      String zone = await GetLocalTimeZone.get();

      setState(() {
        loadingText = "Loading...\nGetting Local UTC Offset";
      });

      int offset = await GetFromTimeZoneDB.getUTCOffset(zone);

      leave(offset);

    } catch (e){
      setState(() {
        isError = true;
        loadingText = "Loading Error: \n${e.toString()}";
      });
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

  void leave(int localUtcOffset){
    Map<String,int> args = {
      'offset': localUtcOffset
    };
    Navigator.pushReplacementNamed(context, "/main", arguments: args);
  }
}
