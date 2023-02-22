import 'package:TimeConvertor/main.dart';
import 'package:TimeConvertor/utils/consts.dart';
import 'package:TimeConvertor/utils/extensions.dart';
import 'package:TimeConvertor/utils/streams.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:TimeConvertor/widgets/other_page_indicator.dart';
import 'package:align_positioned/align_positioned.dart';


class TimeZonesScreen extends StatefulWidget {

  const TimeZonesScreen({Key? key}) : super(key: key);

  @override
  State<TimeZonesScreen> createState() => _TimeZonesScreenState();
}

class _TimeZonesScreenState extends State<TimeZonesScreen> {
  PageController pageController = PageController();
  double currentPage = 0.0;

  late DateTime _referenceTime;
  late int localOffset;

  int get numPages => getIt.get<TimeZoneDataStream>().get.length;
  DateTime getTimeDisplay(int offset) => _referenceTime.add(Duration(hours: getHoursFromOffset(offset), minutes: getMinutesFromOffset(offset)));
  DateTime getCurrentTimeDisplay() => getTimeDisplay(getOffset(currentPage.round()));

  int getOffset(int index) {
    if (index == 0) {
      return localOffset;
    }
    return getIt.get<TimeZoneDataStream>().get[index].offset;
  }

  @override
  void initState() {
    super.initState();

    localOffset = getIt.get<LocalUTCOffsetStream>().get;

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

  String getNameByIndex(int index) {
    return getIt.get<TimeZoneDataStream>().get[index].name;
  }

  int getMinutesFromOffset(int offset){
    return (offset - (offset/3600).floor() * 3600)~/60;
  }
  int getHoursFromOffset(int offset){
    return (offset/3600).floor();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Stack(children: [
        PageView.builder(
            itemCount: numPages,
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
              dotsCount: numPages,
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
      initialTime: getCurrentTimeDisplay().toTimeOfDay(),
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (newTime != null) {

      int utcHour = newTime.hour - getHoursFromOffset(getOffset(currentPage.round()));
      int utcMinute = newTime.minute - getMinutesFromOffset(currentPage.round());
      if (utcMinute >= 60) {
        utcHour++;
        utcMinute -= 60;
      } else if (utcMinute < 0) {
        utcHour--;
        utcMinute += 60;
      }
      setState(() {
        _referenceTime = _referenceTime.setTimeOfDay(
            utcHour.rollOver(max: 24),
            utcMinute.rollOver(max: 60));
      });
    }
  }

  Widget buildTimeZonePages(int index, double height, double width) {
    Matrix4 matrix = Matrix4.identity();

    double currentScale = 0.9, scaleFactor = 0.9;

    if (index == currentPage.floor()) { //current slide
      currentScale = 1 - (currentPage - index) * (1 - scaleFactor);
    } else if(index == currentPage.floor() + 1) { //next one
      currentScale = scaleFactor + (currentPage - index + 1) * (1 - scaleFactor);
    } else if(index == currentPage.floor() - 1) { //previous one
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
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            Align(
              alignment: const Alignment(0,-0.95),
              child: SizedBox(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:[
                    if (index != 0)
                      ...[OtherPageIndicator(text: getNameByIndex(index - 1), flipped: false)],
                    if (index != numPages - 1)
                      ...[OtherPageIndicator(text: getNameByIndex(index + 1), flipped: true)],
                  ],
                ),
              ),
            ),
            AlignPositioned(
              alignment: Alignment.center,
              moveByChildHeight: -0.3,
              child: StreamBuilder(
                stream: getIt.get<FormatStream>().stream,
                builder: (context, snap) {
                  return TextButton(
                    onPressed: () => selectTime(),
                    child: Text(getDisplayText(index),
                      style: const TextStyle(
                          fontSize: 160,
                          color: Colors.black,
                          fontFamily: 'Fokus',
                          letterSpacing: 5
                      ),
                    ),
                  );
                },
              ),
            ),
            AlignPositioned(
              alignment: const Alignment(0.8,-0.25),
              dy: 15,
              dx: 10,
              child: StreamBuilder(
                stream: getIt.get<FormatStream>().stream,
                builder: (context, snap) {
                  return Text(getIt.get<FormatStream>().get == Format.f24h ? ""
                      : getTimeDisplay(getOffset(index)).hour < 12 ? "AM" : "PM",
                    style: const TextStyle(
                        fontSize: 30,
                        color: Colors.black,
                        fontFamily: 'Fokus',
                        letterSpacing: 1
                    ),
                  );
                },
              ),
            ),
            AlignPositioned(
              alignment: Alignment.bottomCenter,
              moveByChildHeight: -2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, size: 50),
                  Text(getNameByIndex(index),
                    style: const TextStyle(
                      fontSize: 50,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getDisplayText(int index) {
    DateTime timeToDisplay = getTimeDisplay(getOffset(index));
    Format format = getIt.get<FormatStream>().get;
    int hour = timeToDisplay.hour > 12 ?
    timeToDisplay.hour % (format == Format.f12h ? 12 : 24) :
    timeToDisplay.hour;
    int minute = timeToDisplay.minute;
    return "${hour.getFormatForTimeDisplay()}:${minute.getFormatForTimeDisplay()}";
  }
}