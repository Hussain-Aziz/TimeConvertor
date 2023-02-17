import 'package:flutter/material.dart';
import 'package:TimeConvertor/pages/alarms_page.dart';
import 'package:TimeConvertor/pages/time_zones_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  int localUtcOffset = 0;

  @override
  Widget build(BuildContext context) {

    var args = ModalRoute.of(context)?.settings.arguments as Map<String,int>;
    localUtcOffset = args['offset']!;

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
}
