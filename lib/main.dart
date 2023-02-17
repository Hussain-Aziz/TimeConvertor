import 'package:TimeConvertor/pages/loading.dart';
import 'package:flutter/material.dart';
import 'package:TimeConvertor/pages/main_page.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
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
