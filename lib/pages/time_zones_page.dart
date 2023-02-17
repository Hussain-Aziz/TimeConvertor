import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

class TimeZonesScreen extends StatefulWidget {
  int localUtcOffset;

  TimeZonesScreen({Key? key,  required this.localUtcOffset}) : super(key: key);

  @override
  State<TimeZonesScreen> createState() => _TimeZonesScreenState();
}

class _TimeZonesScreenState extends State<TimeZonesScreen> {
  PageController pageController = PageController();
  double currentPage = 0.0;
  DateTime localTime = DateTime.now();

  int localUtcOffset = 0;

  int numPages() => 3; //TODO: Get from sql database

  @override
  void initState() {
    super.initState();
    localUtcOffset = widget.localUtcOffset;
    pageController.addListener(() {
      setState(() {
        currentPage = pageController.page!;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Stack(children: [
        PageView.builder(
            itemCount: numPages(),
            controller: pageController,
            itemBuilder: (context, position) {
              return buildTimeZonePages(
                  position, MediaQuery.of(context).size.height);
            }),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.only(bottom: 20),
            child: DotsIndicator(
              dotsCount: numPages(),
              position: currentPage,
            ),
          ),
        ),
      ]),
    );
  }

  void selectTime() async {
    TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (newTime != null) {
      setState(() {
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day,
            newTime.hour, newTime.minute);
        //_time = newTime;
      });
    }
  }

  Widget buildTimeZonePages(int index, double? height) {
    return Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
          ),
        ]
    );
  }
}
