import 'package:finances/utils/provider.dart';
import 'package:flutter/material.dart';

TextStyle titleStyle = TextStyle(
  fontWeight: FontWeight.w800,
  fontSize: 18,
);

TextStyle bigMoneyStyle = TextStyle(
  fontSize: 22,
  color: Color.fromARGB(255, 6, 83, 145),
  fontWeight: FontWeight.w600,
);

TextStyle getBigMoneyStyle(ThemeProvider themeProvider, BuildContext context) {
  if (Theme.of(context).brightness ==
      Brightness.dark /* themeProvider.selectedTheme == ThemeMode.dark */) {
    return TextStyle(
      fontSize: 22,
      color: Color.fromARGB(255, 190, 227, 253),
      fontWeight: FontWeight.w600,
    );
  } else {
    return TextStyle(
      fontSize: 22,
      color: Color.fromARGB(255, 6, 83, 145),
      fontWeight: FontWeight.w600,
    );
  }
}
