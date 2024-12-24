import 'package:finances/utils/app_data.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static const separator = ','; // Change this to '.' for other locales

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Short-circuit if the new value is empty
    if (newValue.text.length == 0) {
      return newValue.copyWith(text: '');
    }

    // Handle "deletion" of separator character
    String oldValueText = oldValue.text.replaceAll(separator, '');
    String newValueText = newValue.text.replaceAll(separator, '');

    if (oldValue.text.endsWith(separator) &&
        oldValue.text.length == newValue.text.length + 1) {
      newValueText = newValueText.substring(0, newValueText.length - 1);
    }

    // Split the string into its integer and decimal parts
    List<String> parts = newValueText.split('.');

    int selectionIndex = newValue.text.length -
        newValue.selection
            .extentOffset; // + (parts.length > 1 ? parts[1].length : 0);
    final chars = parts[0].split('');

    String newString = '';
    for (int i = chars.length - 1; i >= 0; i--) {
      if ((chars.length - 1 - i) % 3 == 0 && i != chars.length - 1)
        newString = separator + newString;
      newString = chars[i] + newString;
    }

    return TextEditingValue(
      text: newString.toString() + (parts.length > 1 ? '.' + parts[1] : ''),
      selection: TextSelection.collapsed(
        offset: newString.length -
            selectionIndex +
            (parts.length > 1 ? parts[1].length + 1 : 0),
      ),
    );
  }
}

String thousandSeparator(String number) {
  const separator = ',';

  // Split the string into its integer and decimal parts
  List<String> parts = number.split('.');

  final chars = parts[0].split('');

  String newString = '';
  for (int i = chars.length - 1; i >= 0; i--) {
    if ((chars.length - 1 - i) % 3 == 0 && i != chars.length - 1) {
      if (chars[i] != '-') {
        newString = separator + newString;
      }
    }

    newString = chars[i] + newString;
  }

  return newString.toString() + (parts.length > 1 ? '.' + parts[1] : '');
}

String symbolWriting(String currency) {
  String symbol = currency;
  if (currencySymbols[currency] != null) {
    symbol = currencySymbols[currency];
  }
  return symbol;
}

String dateFormatter(DateTime dateTime) {
  DateTime todayDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime dayOfdateTime =
      DateTime(dateTime.year, dateTime.month, dateTime.day);
  if (dayOfdateTime == todayDate) {
    return "Today";
  } else if (dayOfdateTime.add(Duration(days: 1)) == todayDate) {
    return "Yesterday";
  } else if (dayOfdateTime.add(Duration(days: -1)) == todayDate) {
    return "Tomorrow";
  } else if (dayOfdateTime.year == todayDate.year) {
    return "${dayOfdateTime.day} ${DateFormat("MMMM").format(dayOfdateTime)}";
  } else {
    return "${dayOfdateTime.day} ${DateFormat("MMMM").format(dayOfdateTime)}, ${dayOfdateTime.year}";
  }
}

String daysOfMonth(int day) {
  if (day == 32) {
    return "On last day";
  } else if (day == 1) {
    return "1st";
  } else if (day == 2) {
    return "2nd";
  } else if (day == 3) {
    return "3rd";
  } else {
    return "${day}th";
  }
}

String displayMonth(int i) {
  List<String> months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];
  return months[i - 1];
}

DateTime dayOfDate(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}

DateTime weekOfDate(DateTime dateTime) {
  DateTime result =
      dayOfDate(dateTime.subtract(Duration(days: dateTime.weekday - 1)));
  return result;
}

DateTime monthOfDate(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month);
}

Color getColorFromString(String strColor) {
  List props = strColor.split(" ").toList();
  Color color = Color.fromARGB(
    int.parse(props[0]),
    int.parse(props[1]),
    int.parse(props[2]),
    int.parse(props[3]),
  );
  return color;
}
