import 'package:TimeConvertor/main.dart';
import 'package:TimeConvertor/pages/input_new_location.dart';
import 'package:TimeConvertor/utils/consts.dart';
import 'package:TimeConvertor/utils/extensions.dart';
import 'package:TimeConvertor/utils/streams.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:TimeConvertor/widgets/other_page_indicator.dart';


class TimeZonesScreen extends StatefulWidget {

  const TimeZonesScreen({Key? key, required this.localOffset}) : super(key: key);

  final int localOffset;

  @override
  State<TimeZonesScreen> createState() => _TimeZonesScreenState();
}

class _TimeZonesScreenState extends State<TimeZonesScreen> {

  PageController pageController = PageController();
  double currentPage = 0.0;

  late DateTime _referenceTime;

  int get numPages => getIt.get<TimeZoneDataStream>().get.length;
  DateTime getTimeDisplay(int offset) => _referenceTime.add(Duration(hours: getHoursFromOffset(offset), minutes: getMinutesFromOffset(offset)));
  DateTime getCurrentTimeDisplay() => getTimeDisplay(getOffset(currentPage.round()));

  int getOffset(int index) {
    if (index == 0) {
      return widget.localOffset;
    }
    return getIt.get<TimeZoneDataStream>().get[index].offset;
  }

  @override
  void initState() {
    super.initState();
    _referenceTime = DateTime.now().subtract(Duration(hours: getHoursFromOffset(widget.localOffset), minutes: getMinutesFromOffset(widget.localOffset)));

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
      child: StreamBuilder(
          stream: getIt.get<TimeZoneDataStream>().stream,
          builder: (context, snapshot) {
            return Stack(children: [
              PageView.builder(
                  itemCount: numPages + 1,
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
                    dotsCount: numPages + 1,
                    position: currentPage,
                  ),
                ),
              ),
            ]);
          }
      ),
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

    if (index == numPages){
      return promptAddNewTimeZonePage(matrix);
    }
    return Transform(
      transform: matrix,
      child: Container(
        height: height,
        width: width,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Flexible(
              flex: 1,
              child: SizedBox(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:[
                    if (index == 0) 
                    ...[Container()], //so the indicator only appears on the right
                    if (index != 0)
                      ...[OtherPageIndicator(text: getNameByIndex(index - 1), flipped: false)],
                    if (index != numPages - 1)
                      ...[OtherPageIndicator(text: getNameByIndex(index + 1), flipped: true)],
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StreamBuilder(
                    stream: getIt.get<FormatStream>().stream,
                    builder: (context, snap) {
                      return OutlinedButton(
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
                  Text(getIt.get<FormatStream>().get == Format.f24h ? ""
                      : getTimeDisplay(getOffset(index)).hour < 12 ? "AM" : "PM",
                    style: const TextStyle(
                        fontSize: 30,
                        color: Colors.black,
                        fontFamily: 'Fokus',
                        letterSpacing: 1
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, size:50),
                  Flexible(
                    child: Text(getNameByIndex(index),
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 30,
                        color: Colors.black,
                      ),
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

  Widget promptAddNewTimeZonePage(Matrix4 matrix){
    return Transform(
      transform: matrix,
      child: Stack(
          children:[
            ElevatedButton(
                onPressed: () {
                  goToInputNewLocationPage();
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateColor.resolveWith((states) => Colors.white) ,
                ),
                child: Container(
                  color: Colors.white,
                )
            ),
            Center(
              child: SizedBox(
                height: 250,
                child: Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_circle_outlined),
                      iconSize: 150,
                      color: Colors.blue,
                      onPressed: (){
                        goToInputNewLocationPage();
                      },
                    ),
                    TextButton(onPressed: (){
                      goToInputNewLocationPage();
                    },
                        child: const Text("Add new location",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 30,
                            color: Colors.black,
                          ),
                        )
                    )
                  ],
                ),
              ),
            ),
          ]
      ),
    );
  }

  void goToInputNewLocationPage(){
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return InputNewLocationPage();
    }));
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