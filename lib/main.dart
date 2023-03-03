import 'package:TimeConvertor/pages/loading.dart';
import 'package:TimeConvertor/utils/streams.dart';
import 'package:flutter/material.dart';
import 'package:TimeConvertor/pages/main_page.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';

GetIt getIt = GetIt.instance;
late Database database;

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  getIt.registerSingleton<FormatStream>(FormatStream());
  getIt.registerSingleton<TimeZoneDataStream>(TimeZoneDataStream());
  getIt.registerSingleton<ConnectedStream>(ConnectedStream());
  getIt.registerSingleton<UpdateTimeStream>(UpdateTimeStream()..update());

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        "/loading": (_) => const LoadingPage(),
        "/main": (_) => const MainPage(),
      },
    );
  }
}
