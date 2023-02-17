import 'package:TimeConvertor/services/get_from_timezonedb.dart';
import 'package:TimeConvertor/services/get_local_timezone.dart';
import 'package:flutter/material.dart';
import 'package:TimeConvertor/pages/alarms_page.dart';
import 'package:TimeConvertor/pages/time_zones_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  int localUtcOffset = 0;
  bool updatedLocalOffset = false;

  @override
  Widget build(BuildContext context) {

    var args = ModalRoute.of(context)?.settings.arguments as Map<String,dynamic>;
    localUtcOffset = args['offset']!;

    //ensure that even if we got from shared prefs, the zone is correct
    //while also not unnecessarily waiting on loading screen
    if (!updatedLocalOffset) {
      if (args['reCheckTimeZone']! == true) {
        updateLocalUTCOffset();
      }
      else{
        updatedLocalOffset = true;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Time Convertor"),
        centerTitle: true,
      ),

      body: selectedBottomBarIndex == 0 ? TimeZonesScreen(localUtcOffset: localUtcOffset) : AlarmsScreen(),

      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.access_time_filled_rounded), label: "Time Zones"),
          BottomNavigationBarItem(icon: Icon(Icons.access_alarm), label: "Alarms"),
        ],
        currentIndex: selectedBottomBarIndex,
        onTap: onBottomNavigationBarTapped,
      ),

    );
  }

  int selectedBottomBarIndex = 0;

  void onBottomNavigationBarTapped(int index)
  {
    setState(() => selectedBottomBarIndex = index);
  }

  void updateLocalUTCOffset() async{
    String zone = await GetLocalTimeZone.get();
    int offset = await GetFromTimeZoneDB.getUTCOffsetByZone(zone);

    if (offset != localUtcOffset) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt('localUTCOffset', offset);
      updatedLocalOffset = true;
      setState(() => localUtcOffset = offset);
    }
  }
}
