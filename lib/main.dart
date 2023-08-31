import 'package:comif_app/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

ThemeData appTheme = ThemeData(
  //useMaterial3: true,
  primaryColor: const Color.fromARGB(255, 92, 1, 31),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
        fontSize: 70,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 92, 1, 31),
        fontFamily: 'bonbon'),
    bodyLarge: TextStyle(
        fontSize: 18,
        color: Color.fromARGB(255, 92, 1, 31),
        fontFamily: 'bonbon'),
    titleMedium: TextStyle(
        fontSize: 32,
        color: Color.fromARGB(255, 92, 1, 31),
        fontFamily: 'bonbon'),
    headlineSmall: TextStyle(
      fontSize: 30,
      color: Color.fromARGB(255, 92, 1, 31),
      fontFamily: 'HouseScript',
    ),
    bodyMedium: TextStyle(
      fontSize: 18,
      color: Color.fromARGB(255, 92, 1, 31),
    ),
  ),

  appBarTheme: const AppBarTheme(
    iconTheme: IconThemeData(color: Colors.black),
    color: Color.fromARGB(255, 246, 221, 166),
    shadowColor: Colors.black,
    titleTextStyle: TextStyle(
        color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
  ),
  colorScheme: ColorScheme.fromSeed(
      primary: const Color.fromARGB(255, 92, 1, 31),
      secondary: const Color.fromARGB(255, 246, 221, 166),
      seedColor: const Color.fromARGB(255, 254, 249, 235),
      brightness: Brightness.light,
      background: const Color.fromARGB(255, 254, 249, 235)),
  primarySwatch: const MaterialColor(0xFF5C011F, {
    50: Color(0xFF5C011F),
    100: Color(0xFF5C011F),
    200: Color(0xFF5C011F),
    300: Color(0xFF5C011F),
    400: Color(0xFF5C011F),
    500: Color(0xFF5C011F),
    600: Color(0xFF5C011F),
    700: Color(0xFF5C011F),
    800: Color(0xFF5C011F),
    900: Color(0xFF5C011F),
  }),
  scaffoldBackgroundColor: const Color.fromARGB(255, 254, 249, 235),
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'COMIF Mobile App',
      theme: appTheme,
      home: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: const Scaffold(
          body: HomeScreen(),
        ),
      ),
    );
  }
}
