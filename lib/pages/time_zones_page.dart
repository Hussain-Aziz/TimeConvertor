import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimeZonesScreen extends StatefulWidget {
  const TimeZonesScreen({Key? key}) : super(key: key);

  @override
  State<TimeZonesScreen> createState() => _TimeZonesScreenState();
}

class _TimeZonesScreenState extends State<TimeZonesScreen> {
  PageController pageController = PageController(viewportFraction: 1);
  double currentPage = 0.0;
  double scaleFactor = 0.8;
  int numPages() => 3;

  @override
  void initState() {
    super.initState();
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
              return buildTimeZonePages(position, MediaQuery.of(context).size.height);
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

  Widget buildTimeZonePages(int index, double? height) {

    return Stack(
        children: [
          Text("HI")
        ],
    );
  }
}
