import 'package:TimeConvertor/main.dart';
import 'package:TimeConvertor/utils/consts.dart';
import 'package:TimeConvertor/utils/streams.dart';
import 'package:flutter/material.dart';
import 'package:TimeConvertor/pages/alarms_page.dart';
import 'package:TimeConvertor/pages/time_zones_page.dart';
import 'package:toggle_switch/toggle_switch.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int? localOffset;

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      title: const Text("Time Convertor"),
      centerTitle: true,
    );

    final width = MediaQuery.of(context).size.width * 2 / 3;

    if (localOffset == null) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, int>;
      localOffset = args['offset'];
    }

    return Scaffold(
      appBar: appBar,
      body: selectedBottomBarIndex == 0
          ? TimeZonesScreen(localOffset: localOffset!)
          : const AlarmsScreen(),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.access_time_filled_rounded),
              label: "Time Zones"),
          BottomNavigationBarItem(
              icon: Icon(Icons.access_alarm), label: "Alarms"),
        ],
        currentIndex: selectedBottomBarIndex,
        onTap: onBottomNavigationBarTapped,
      ),
      drawer: Drawer(
          width: width,
          child: ListView(
            children: [
              SizedBox(
                height: appBar.preferredSize.height + 10,
                child: const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Text(
                    "Settings",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text("Format: ",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  StreamBuilder(
                      stream: getIt.get<FormatStream>().stream,
                      builder: (context, snap) {
                        return ToggleSwitch(
                          cornerRadius: 20.0,
                          activeBgColors: [
                            [Colors.blue[600]!],
                            [Colors.blue[600]!]
                          ],
                          activeFgColor: Colors.white,
                          inactiveBgColor: Colors.white,
                          inactiveFgColor: Colors.white,
                          customTextStyles: const [
                            TextStyle(color: Colors.black, fontSize: 18.0),
                            TextStyle(color: Colors.black, fontSize: 18.0),
                          ],
                          initialLabelIndex:
                              getIt.get<FormatStream>().get == Format.f12h
                                  ? 0
                                  : 1,
                          totalSwitches: 2,
                          labels: const ['12h', '24h'],
                          radiusStyle: true,
                          onToggle: (index) {
                            setState(() {
                              getIt
                                  .get<FormatStream>()
                                  .set(index == 0 ? Format.f12h : Format.f24h);
                            });
                          },
                        );
                      }),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(
                color: Colors.black,
                thickness: 1,
              ),
              const SizedBox(height: 10),
              InkWell(
                  onTap: () {
                    getIt.get<UpdateTimeStream>().update();
                  },
                  child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Text(
                        "Update to current time",
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ))),
              const SizedBox(height: 10),
              const Divider(
                color: Colors.black,
                thickness: 1,
              ),
              const SizedBox(height: 10),
            ],
          )),
      drawerEnableOpenDragGesture: true,
    );
  }

  int selectedBottomBarIndex = 0;

  void onBottomNavigationBarTapped(int index) {
    setState(() => selectedBottomBarIndex = index);
  }
}
