import 'package:TimeConvertor/main.dart';
import 'package:TimeConvertor/utils/local_utc_offset_stream.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:TimeConvertor/widgets/page_indicator.dart';
import 'package:flutter/src/material/time_picker.dart';
import 'dart:math' as math;


class TimeZonesScreen extends StatefulWidget {

  TimeZonesScreen({Key? key}) : super(key: key);

  @override
  State<TimeZonesScreen> createState() => _TimeZonesScreenState();
}

class _TimeZonesScreenState extends State<TimeZonesScreen> {
  PageController pageController = PageController();
  double currentPage = 0.0;

  int currentUTCOffset = 0;
  late DateTime _referenceTime;
  DateTime get _currentTimeDisplay => _referenceTime.add(Duration(hours: getHoursFromOffset(currentUTCOffset), minutes: getMinutesFromOffset(currentUTCOffset)));

  int numPages() => 3; //TODO: Get from sql database

  @override
  void initState() {
    super.initState();

    final localOffset = getIt.get<LocalUTCOffsetStream>().get;

    _referenceTime = DateTime.now().subtract(Duration(hours: getMinutesFromOffset(localOffset), minutes: getMinutesFromOffset(localOffset)));

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

  String getNameByIndex(int index)
  {
    //TODO: Implement
    return "Place $index";
  }

  int getMinutesFromOffset(int offset){
    return (offset - (offset/3600).floor() * 3600)~/60;
  }
  int getHoursFromOffset(int offset){
    return (currentUTCOffset/3600).floor();
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
                  position, MediaQuery.of(context).size.height, MediaQuery.of(context).size.width);
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

      int utcHour = clampHour(newTime.hour - getHoursFromOffset(currentUTCOffset));
      int utcMinute = newTime.minute - getMinutesFromOffset(currentUTCOffset);
      if (utcMinute >= 60) {
        utcHour++;
        utcMinute -= 60;
      }else if (utcMinute < 0) {
        utcHour--;
        utcMinute += 60;
      }

      setState(() {
        _referenceTime = _referenceTime.setTimeOfDay(utcHour, utcMinute);
      });
    }
  }

  int clampHour(int hour)
  {
    if (hour >= 24) {
      hour -= 24;
    } else if (hour < 0) {
      hour += 24;
    }
    return hour;
  }

  Widget buildTimeZonePages(int index, double height, double width) {
    Matrix4 matrix = Matrix4.identity();

    double currentScale = 0.9; //default for not in view

    double scaleFactor = 0.9;

    if (index == currentPage.floor()){ //current slide
      currentScale = 1 - (currentPage - index) * (1 - scaleFactor);
    }else if(index == currentPage.floor() + 1){ //next one
      currentScale = scaleFactor + (currentPage - index + 1) * (1 - scaleFactor);
    }else if(index == currentPage.floor() - 1) { //previous one
      currentScale = 1 - (currentPage - index) * (1 - scaleFactor);
    }

    //set the scale and make it go a bit down to account for the size diff
    matrix = Matrix4.diagonal3Values(1, currentScale, 1)..setTranslationRaw(0, height * (1-currentScale)/2, 0);
    return Transform(
      transform: matrix,
      child: Container(
        height: height,
        width: width,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          //color: Colors.red,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment(0,-0.95),
              child: Container(
                height: 60,
                color: Colors.red,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:[
                    index != 0 ? PageIndicator(text: getNameByIndex(index - 1), flipped: false) : Container(),
                    index != numPages() - 1 ? PageIndicator(text: getNameByIndex(index + 1), flipped: true) : Container(),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment(0,-0.3),
              child: Container(
                  //color: Colors.blue,
                    child: TextButton(
                      onPressed: () => selectTime(),
                      child: Text("${_currentTimeDisplay.hour.toString().padLeft(2, '0')}:${_currentTimeDisplay.minute.toString().padLeft(2, '0')}",
                        style: const TextStyle(
                          fontSize: 160,
                          color: Colors.black,
                          fontFamily: 'Fokus',
                          letterSpacing: 5
                        ),
                      ),
                    )
                ),
              ),
          ],
        ),
      ),
    );
  }
}

extension DateTimeExtension on DateTime {
  DateTime setTimeOfDay(int hour, int minute) {
    return DateTime(year, month, day, hour, minute);
  }
}