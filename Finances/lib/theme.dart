import 'package:flutter/material.dart';

ThemeData lightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    primarySwatch: const MaterialColor(0xFF06AF00, <int, Color>{
      50: Color(0xFFE1F5E0),
      100: Color(0xFFB4E7B3),
      200: Color(0xFF83D780),
      300: Color(0xFF51C74D),
      400: Color(0xFF2BBB26),
      500: Color(0xFF06AF00),
      600: Color(0xFF05A800),
      700: Color(0xFF049F00),
      800: Color(0xFF039600),
      900: Color(0xFF028600),
    }),
    primaryColor: const Color.fromARGB(255, 240, 255, 25),
    scaffoldBackgroundColor: const Color.fromARGB(255, 230, 229, 231),
    cardColor: Colors.white,
    bottomAppBarTheme: const BottomAppBarTheme(
      color: Color.fromARGB(255, 255, 255, 255),
    ),
    dialogTheme: DialogTheme(
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black,
          fontSize: 20,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        )),
    popupMenuTheme: PopupMenuThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          width: 1,
          color: Colors.black,
        ),
      ),
      elevation: 0,
    ),

    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
            textStyle: const TextStyle(
      fontWeight: FontWeight.w800,
    ))),
    //fontFamily: 'Roboto',
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
          borderSide: BorderSide(
        width: 2,
        color: Colors.black,
      )),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: Color.fromARGB(255, 33, 36, 39),
        fontWeight: FontWeight.w800,
        fontSize: 28,
      ),
      displayMedium: TextStyle(
        color: Color.fromARGB(255, 33, 36, 39),
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      displaySmall: TextStyle(
        color: Color.fromARGB(255, 33, 36, 39),
        fontWeight: FontWeight.w400,
        fontSize: 14,
      ),
      headlineMedium: TextStyle(
        color: Color.fromARGB(255, 33, 36, 39),
        fontWeight: FontWeight.normal,
        fontSize: 14,
      ),
      bodyLarge: TextStyle(
        color: Color.fromARGB(255, 33, 36, 39),
        fontWeight: FontWeight.normal,
        fontSize: 12,
      ),
    ),
  );
}

ThemeData darkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    primarySwatch: const MaterialColor(0xFF06AF00, <int, Color>{
      50: Color(0xFFE1F5E0),
      100: Color(0xFFB4E7B3),
      200: Color(0xFF83D780),
      300: Color(0xFF51C74D),
      400: Color(0xFF2BBB26),
      500: Color(0xFF06AF00),
      600: Color(0xFF05A800),
      700: Color(0xFF049F00),
      800: Color(0xFF039600),
      900: Color(0xFF028600),
    }),
    primaryColor: const Color.fromARGB(255, 240, 255, 25),
    cardColor: const Color.fromARGB(255, 70, 69, 69),
    bottomAppBarTheme: const BottomAppBarTheme(
      color: Color.fromARGB(255, 25, 25, 26),
    ),
    dialogTheme: DialogTheme(
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color.fromARGB(255, 255, 255, 255),
          fontSize: 20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        )),
    popupMenuTheme: PopupMenuThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          width: 1,
          color: Colors.black,
        ),
      ),
      elevation: 0,
    ),
    //scaffoldBackgroundColor: const Color(0XFFF0EFF4),
    //fontFamily: 'Roboto',
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
            textStyle: const TextStyle(
      fontWeight: FontWeight.w800,
    ))),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
          borderSide: BorderSide(
        width: 2,
        color: Colors.white,
      )),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: Color.fromARGB(255, 18, 19, 20),
        fontWeight: FontWeight.w800,
        fontSize: 28,
      ),
      displayMedium: TextStyle(
        color: Color.fromARGB(255, 33, 36, 39),
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      displaySmall: TextStyle(
        color: Color.fromARGB(255, 33, 36, 39),
        fontWeight: FontWeight.w400,
        fontSize: 14,
      ),
      headlineMedium: TextStyle(
        color: Color.fromARGB(255, 33, 36, 39),
        fontWeight: FontWeight.normal,
        fontSize: 14,
      ),
      bodyLarge: TextStyle(
        color: Color.fromARGB(255, 33, 36, 39),
        fontWeight: FontWeight.normal,
        fontSize: 12,
      ),
    ),
  );
}
