import 'package:finances/utils/formatters.dart';
import 'package:flutter/material.dart';

class FilterPage extends StatefulWidget {
  final List<String> filters;
  final String? currentPeriod;
  final String? currentType;
  final String? currentAccount;
  final int? firstTime;
  const FilterPage(
      {super.key,
      required this.filters,
      required this.currentPeriod,
      required this.currentType,
      this.currentAccount,
      this.firstTime});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  List<String> periods = [
    "Today",
    "This week",
    "This month",
    "This year",
    "Last 7 days",
    "Last 30 days",
    "Last 90 days",
    "Last 365 days",
    "Last 5 years",
  ];
  List<String> types = [
    "All",
    "Expenses only",
    "Income only",
    "Transfer only",
  ];

  List<String> typesDual = [
    "Expenses",
    "Income",
  ];
  List<String> budgetTypes = [
    "Revenue excluded",
    "Revenue included",
  ];

  List<String> limitedPeriods = [
    "Last 7 days",
    "Last 30 days",
    "Last 365 days",
  ];

  List<String> budgetPeriods = [
    "Daily",
    "Weekly",
    "Monthly",
    "Yearly",
  ];
  late String? currentPeriod = widget.currentPeriod;
  late String? currentType = widget.currentType;
  late String? currentAccount = widget.currentAccount;
  late int? firstTime = widget.firstTime;

  String getTime() {
    if (currentPeriod == "Daily") {
      return "hour";
    } else if (currentPeriod == "Weekly") {
      return "weekday";
    } else if (currentPeriod == "Monthly") {
      return "day";
    } else {
      return "month";
    }
  }

  List<String> daysOfTheWeekComplete = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  String displayfirstTime(String time) {
    if (time == "hour") {
      return "${firstTime.toString().padLeft(2, '0')}:00";
    } else if (time == "weekday") {
      return daysOfTheWeekComplete[firstTime! - 1];
    } else if (time == "day") {
      return daysOfMonth(firstTime!);
    } else {
      return displayMonth(firstTime!);
    }
  }

  @override
  Widget build(BuildContext context) {
    String time = getTime();
    return AlertDialog(
      title: Text("Select filters"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.filters.contains("period")
              ? PopupMenuButton(
                  onSelected: (value) {
                    setState(() {
                      currentPeriod = value;
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(width: 1),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Period",
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              currentPeriod!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.arrow_drop_down),
                          ],
                        )
                      ],
                    ),
                  ),
                  itemBuilder: (context) {
                    return List.generate(
                      periods.length,
                      (i) {
                        return PopupMenuItem(
                          value: periods[i],
                          child: Text(periods[i]),
                        );
                      },
                    );
                  },
                )
              : Container(),
          widget.filters.contains("period (limited)")
              ? PopupMenuButton(
                  onSelected: (value) {
                    setState(() {
                      currentPeriod = value;
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(width: 1),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Period",
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              currentPeriod!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.arrow_drop_down),
                          ],
                        )
                      ],
                    ),
                  ),
                  itemBuilder: (context) {
                    return List.generate(
                      limitedPeriods.length,
                      (i) {
                        return PopupMenuItem(
                          value: limitedPeriods[i],
                          child: Text(limitedPeriods[i]),
                        );
                      },
                    );
                  },
                )
              : Container(),
          widget.filters.contains("period (budget)")
              ? PopupMenuButton(
                  onSelected: (value) {
                    setState(() {
                      currentPeriod = value;
                      time = getTime();
                      firstTime = time != "hour" ? 1 : 0;
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(width: 1),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Period",
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              currentPeriod!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.arrow_drop_down),
                          ],
                        )
                      ],
                    ),
                  ),
                  itemBuilder: (context) {
                    return List.generate(
                      budgetPeriods.length,
                      (i) {
                        return PopupMenuItem(
                          value: budgetPeriods[i],
                          child: Text(budgetPeriods[i]),
                        );
                      },
                    );
                  },
                )
              : Container(),
          widget.filters.length > 1
              ? Padding(padding: EdgeInsets.only(bottom: 12))
              : Container(),
          widget.filters.contains("type")
              ? PopupMenuButton(
                  onSelected: (value) {
                    setState(() {
                      currentType = value;
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(width: 1),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Type",
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              currentType!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.arrow_drop_down),
                          ],
                        )
                      ],
                    ),
                  ),
                  itemBuilder: (context) {
                    return List.generate(
                      types.length,
                      (i) {
                        return PopupMenuItem(
                          value: types[i],
                          child: Text(types[i]),
                        );
                      },
                    );
                  },
                )
              : Container(),
          widget.filters.contains("type (dual)")
              ? PopupMenuButton(
                  onSelected: (value) {
                    setState(() {
                      currentType = value;
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(width: 1),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Type",
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              currentType!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.arrow_drop_down),
                          ],
                        )
                      ],
                    ),
                  ),
                  itemBuilder: (context) {
                    return List.generate(
                      typesDual.length,
                      (i) {
                        return PopupMenuItem(
                          value: typesDual[i],
                          child: Text(typesDual[i]),
                        );
                      },
                    );
                  },
                )
              : Container(),
          widget.filters.contains("type (budget)")
              ? PopupMenuButton(
                  onSelected: (value) {
                    setState(() {
                      currentType = value;
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(width: 1),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Type",
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              currentType!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.arrow_drop_down),
                          ],
                        )
                      ],
                    ),
                  ),
                  itemBuilder: (context) {
                    return List.generate(
                      budgetTypes.length,
                      (i) {
                        return PopupMenuItem(
                          value: budgetTypes[i],
                          child: Text(budgetTypes[i]),
                        );
                      },
                    );
                  },
                )
              : Container(),
          widget.filters.length > 2
              ? Padding(padding: EdgeInsets.only(bottom: 12))
              : Container(),
          widget.filters.contains("first time")
              ? PopupMenuButton(
                  onSelected: (value) {
                    setState(() {
                      firstTime = value;
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(width: 1),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "First $time",
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              displayfirstTime(time),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.arrow_drop_down),
                          ],
                        )
                      ],
                    ),
                  ),
                  itemBuilder: (context) {
                    if (time == "hour") {
                      return List.generate(
                        24,
                        (i) {
                          return PopupMenuItem(
                            value: i,
                            child: Text("${i.toString().padLeft(2, '0')}:00"),
                          );
                        },
                      );
                    } else if (time == "weekday") {
                      return List.generate(
                        7,
                        (i) {
                          return PopupMenuItem(
                            value: i + 1,
                            child: Text(daysOfTheWeekComplete[i]),
                          );
                        },
                      );
                    } else if (time == "day") {
                      return List.generate(
                        28,
                        (i) {
                          return PopupMenuItem(
                            value: i + 1,
                            child: Text(daysOfMonth(i + 1)),
                          );
                        },
                      );
                    } else {
                      return List.generate(
                        12,
                        (i) {
                          return PopupMenuItem(
                            value: i + 1,
                            child: Text(displayMonth(i + 1)),
                          );
                        },
                      );
                    }
                  },
                )
              : Container(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(
              context,
              {
                "period": currentPeriod,
                "type": currentType,
                "first time": firstTime,
              },
            );
          },
          child: Text("Save"),
        ),
      ],
    );
  }
}
