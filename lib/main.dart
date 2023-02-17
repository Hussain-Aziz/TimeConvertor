import 'dart:ui';

import 'package:TimeConvertor/pages/loading.dart';
import 'package:flutter/material.dart';
import 'package:TimeConvertor/pages/main_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Time Convertor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: "/loading",
      routes: {
        "/loading" : (_) => LoadingPage(),
        "/main" : (_) => MainPage(),
      },
    );
  }
}
