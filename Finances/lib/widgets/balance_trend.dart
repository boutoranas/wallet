import 'dart:convert';

import 'package:finances/const.dart';
import 'package:finances/secondary_pages/filter_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../utils/formatters.dart';
import '../utils/objects.dart';
import '../utils/provider.dart';
import '../utils/user_preferences.dart';

class BalanceTrend extends StatefulWidget {
  const BalanceTrend({super.key});

  @override
  State<BalanceTrend> createState() => _BalanceTrendState();
}

class _BalanceTrendState extends State<BalanceTrend> {
  kFormat(String value) {
    if (num.parse(value) >= 1000000000) {
      if ((num.parse(value) / 1000000000).toStringAsFixed(1).length < 4) {
        return "${(num.parse(value) / 1000000000).toStringAsFixed(1)}B";
      } else {
        return "${(num.parse(value) / 1000000000).toStringAsFixed(0)}B";
      }
    } else if (num.parse(value) >= 1000000) {
      if ((num.parse(value) / 1000000).toStringAsFixed(1).length < 4) {
        return "${(num.parse(value) / 1000000).toStringAsFixed(1)}M";
      } else {
        return "${(num.parse(value) / 1000000).toStringAsFixed(0)}M";
      }
    } else if (num.parse(value) >= 10000) {
      //return "${(num.parse(value) / 1000).toStringAsFixed(1)}K";
      if ((num.parse(value) / 1000).toStringAsFixed(1).length < 5) {
        return "${(num.parse(value) / 1000).toStringAsFixed(1)}K";
      } else {
        return "${(num.parse(value) / 1000).toStringAsFixed(0)}K";
      }
    } else {
      /* if (num.parse(value) == num.parse(value).toInt()) {
        return num.parse(value).toStringAsFixed(0);
      } else {
        return "o";
      } */
      return num.parse(value).toStringAsFixed(0);
    }
  }

  Widget displayText(value) {
    if (value == value.toInt()) {
      return Text(kFormat(value.toString()));
    } else {
      return const Text("");
    }
  }

  DateTime getPeriodMin(String period) {
    switch (period) {
      case "Today":
        return dayOfDate(DateTime.now());
      case "This week":
        return weekOfDate(DateTime.now());
      case "This month":
        return monthOfDate(DateTime.now());
      case "This year":
        return DateTime(DateTime.now().year);
      case "Last 7 days":
        return dayOfDate(DateTime.now()).subtract(Duration(days: 6));
      case "Last 30 days":
        return dayOfDate(DateTime.now()).subtract(Duration(days: 29));
      case "Last 90 days":
        return dayOfDate(DateTime.now()).subtract(Duration(days: 89));
      case "Last 365 days":
        return dayOfDate(DateTime.now()).subtract(Duration(days: 364));
      case "Last 5 years":
        return dayOfDate(DateTime.now()).subtract(Duration(days: 1824));
      case "All time":
      //return;
      default:
        return DateTime(2000, 1, 1);
    }
  }

  SideTitles getBottomTitles() {
    return SideTitles(
      showTitles: true,
      getTitlesWidget: (value, meta) {
        if (value == meta.min) {
          return Container();
        } else {
          DateTime valueDate =
              getPeriodMin(currentPeriod).add(Duration(minutes: value.round()));
          if (currentPeriod == "Today") {
            return Text(
                "${valueDate.hour.toString().padLeft(2, '0')}:${valueDate.minute.toString().padLeft(2, '0')}");
          } else if (currentPeriod == "This week" ||
              currentPeriod == "Last 7 days") {
            return Text(DateFormat("EEE").format(valueDate));
          } else if (currentPeriod == "Last 5 years") {
            return Text(
              "${valueDate.month}/${valueDate.year}",
              style: TextStyle(
                fontSize: 12,
              ),
            );
          } else {
            return Text("${valueDate.day}/${valueDate.month}");
          }
        }
      },
      interval: maxX / 4,
    );
  }

  double minX = 0;
  double maxX = 0;
  double? minY = null;
  double? maxY = null;

  getCoordinates() {
    if (currentPeriod == "Today") {
      maxX = double.parse(dayOfDate(DateTime.now().add(Duration(
        hours: 23,
        minutes: 59,
      ))).difference(getPeriodMin(currentPeriod)).inMinutes.toString());
    } else if (currentPeriod == "This week") {
      maxX = double.parse(weekOfDate(DateTime.now().add(Duration(days: 7)))
          .difference(getPeriodMin(currentPeriod))
          .inMinutes
          .toString());
    } else if (currentPeriod == "This month") {
      maxX = double.parse(
          DateTime(DateTime.now().year, DateTime.now().month + 1)
              .difference(getPeriodMin(currentPeriod))
              .inMinutes
              .toString());
    } else if (currentPeriod == "This year") {
      maxX = double.parse(DateTime(
        DateTime.now().year + 1,
      ).difference(getPeriodMin(currentPeriod)).inMinutes.toString());
    } else {
      maxX = double.parse(DateTime.now()
          .difference(getPeriodMin(currentPeriod))
          .inMinutes
          .toString());
    }
    List<Coordinates> graphDataInPeriod = graphData
        .where((element) => DateTime.now()
            .add(Duration(minutes: element.x.round()))
            .isAfter(getPeriodMin(currentPeriod)))
        .toList();

    if (graphDataInPeriod.isNotEmpty) {
      double minAmount = graphDataInPeriod[0].y;
      double maxAmount = graphDataInPeriod[0].y;
      for (var coordinate in graphDataInPeriod) {
        if (coordinate.y < minAmount) {
          minAmount = coordinate.y;
        }
        if (coordinate.y > maxAmount) {
          maxAmount = coordinate.y;
        }
      }
      minY = minAmount - 0.05 * minAmount;
      maxY = maxAmount + 0.05 * minAmount + 10;
    }
  }

  List<Expense> getExpenses(ExpensesProvider expensesProvider) {
    List<Expense> e = [];
    for (var element in expensesProvider.expenses) {
      e.add(element);
    }
    e.sort((a, b) => b.date.compareTo(a.date));

    return e;
  }

  double convertToUsd(double amount, String currency) {
    num rate =
        UserPreferences.getExchangeRates()!["conversion_rates"][currency] ?? 0;
    return amount / rate;
  }

  double convertBackToMain(double amount, String mainCurrency) {
    return amount *
        UserPreferences.getExchangeRates()!["conversion_rates"][mainCurrency];
  }

  List<Coordinates> getGraphData(
      AccountsProvider accountsProvider,
      ExpensesProvider expensesProvider,
      SelectedAccounts selectedIndexes,
      MainCurrency maniCurrProv) {
    List<Coordinates> c = [];
    List<Account> selctedAccounts = accountsProvider.accounts
        .where((element) => selectedIndexes.indexes
            .contains(accountsProvider.accounts.indexOf(element)))
        .toList();
    DateTime? latestDate = null;
    double totalAmount = 0;
    for (var account in selctedAccounts) {
      if (latestDate == null || account.createdDate.isAfter(latestDate)) {
        latestDate = account.createdDate;
      }
      totalAmount += convertBackToMain(
          convertToUsd(account.initialAmount, account.currency),
          maniCurrProv.mainCurrency);
    }
    List<Expense> initialExpenses = [];
    for (var expense in expensesProvider.expenses) {
      if (!expense.date.isAfter(latestDate!) &&
          isAccountInList(selctedAccounts, expense)) {
        initialExpenses.add(expense);
      }
    }
    //if expenses are before display dates
    for (var expense in initialExpenses) {
      if (!expense.date.isAfter(latestDate!) &&
          isAccountInList(selctedAccounts, expense)) {
        double value = expense.type == "Income"
            ? convertBackToMain(
                convertToUsd(expense.amount, expense.account.currency),
                maniCurrProv.mainCurrency)
            : -convertBackToMain(
                convertToUsd(expense.amount, expense.account.currency),
                maniCurrProv.mainCurrency);
        totalAmount += value;
      }
      if (!expense.date.isAfter(latestDate) &&
          expense.type == "Transfer" &&
          selctedAccounts
              .where((account) => account.id == expense.category)
              .toList()
              .isNotEmpty) {
        totalAmount += convertBackToMain(
            convertToUsd(
                expense.amount *
                    (expense.fees != null ? (1 - expense.fees! / 100) : 1),
                expense.account.currency),
            maniCurrProv.mainCurrency);
      }
    }
    //if expenses are shown
    c.add(
      Coordinates(
        x: latestDate!
            .difference(getPeriodMin(currentPeriod))
            .inMinutes
            .toDouble(),
        y: totalAmount,
      ),
    );
    for (var expense in expensesProvider.expenses) {
      if (expense.date.isAfter(latestDate) &&
          expense.date.isBefore(DateTime.now()) &&
          isAccountInList(selctedAccounts, expense)) {
        double value = expense.type == "Income"
            ? convertBackToMain(
                convertToUsd(expense.amount, expense.account.currency),
                maniCurrProv.mainCurrency)
            : -convertBackToMain(
                convertToUsd(expense.amount, expense.account.currency),
                maniCurrProv.mainCurrency);
        c.add(
          Coordinates(
            x: expense.date
                .difference(getPeriodMin(currentPeriod))
                .inMinutes
                .toDouble(),
            y: c.last.y + value,
          ),
        );
      }
      if (expense.date.isAfter(latestDate) &&
          expense.date.isBefore(DateTime.now()) &&
          expense.type == "Transfer" &&
          selctedAccounts
              .where((account) => account.id == expense.category)
              .toList()
              .isNotEmpty) {
        double lastAmount = c.last.y;
        if (expense.date
                .difference(getPeriodMin(currentPeriod))
                .inMinutes
                .toDouble() ==
            c.last.x) {
          c.remove(c.last);
        }
        c.add(
          Coordinates(
            x: expense.date
                .difference(getPeriodMin(currentPeriod))
                .inMinutes
                .toDouble(),
            y: lastAmount +
                convertBackToMain(
                    convertToUsd(
                        expense.amount *
                            (expense.fees != null
                                ? (1 - expense.fees! / 100)
                                : 1),
                        expense.account.currency),
                    maniCurrProv.mainCurrency),
          ),
        );
      }
    }
    c.add(
      Coordinates(
        x: DateTime.now()
            .difference(getPeriodMin(currentPeriod))
            .inMinutes
            .toDouble(),
        y: c.last.y,
      ),
    );
    c.sort((a, b) => a.x.compareTo(b.x));
    return c;
  }

  bool isAccountInList(List<Account> accountsList, Expense expense) {
    for (var element in accountsList) {
      if (element.id == expense.account.id) {
        return true;
      }
    }
    return false;
  }

  String currentPeriod = UserPreferences.getFilters()["balance trend"] != null
      ? UserPreferences.getFilters()["balance trend"]["period"]
      : "Last 7 days";

  List<Coordinates> graphData = [];

  @override
  Widget build(BuildContext context) {
    final expensesProvider = Provider.of<ExpensesProvider>(context);
    final accountsProv = Provider.of<AccountsProvider>(context);
    final selectedAccountProv = Provider.of<SelectedAccounts>(context);
    final mainCurrProv = Provider.of<MainCurrency>(context);
    graphData = getGraphData(
        accountsProv, expensesProvider, selectedAccountProv, mainCurrProv);
    getCoordinates();
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 15,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                "Balance trend:",
                style: titleStyle,
              ),
              Spacer(),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => FilterPage(
                      filters: [
                        "period",
                      ],
                      currentPeriod: currentPeriod,
                      currentType: "",
                    ),
                  ).then((value) {
                    if (value != null) {
                      setState(() {
                        currentPeriod = value["period"];

                        Map map = UserPreferences.getFilters();
                        if (map["balance trend"] != null &&
                            map["balance trend"].containsKey("period")) {
                          map["balance trend"].remove("period");
                        }
                        map.addAll({
                          "balance trend": {
                            "period": currentPeriod,
                          }
                        } as Map<String, dynamic>);
                        UserPreferences.saveFilters(json.encode(map));
                      });
                    }
                  });
                },
                icon: Icon(Icons.sort),
              ),
            ],
          ),
          Padding(padding: EdgeInsets.only(bottom: 8)),
          Align(
            child: Text(
                "$currentPeriod, in ${symbolWriting(mainCurrProv.mainCurrency)}"),
            alignment: Alignment.centerLeft,
          ),
          Padding(padding: EdgeInsets.only(bottom: 5)),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(
              right: 20,
              top: 15,
            ),
            child: Container(
              //color: Colors.red,
              height: 250,
              child: LineChart(
                LineChartData(
                  clipData: FlClipData.all(),
                  lineTouchData: LineTouchData(
                      getTouchedSpotIndicator: (barData, spotIndexes) {
                    return List.generate(
                        spotIndexes.length,
                        (index) => TouchedSpotIndicatorData(
                            FlLine(color: Colors.red),
                            FlDotData(
                              show: true,
                              getDotPainter: (p0, p1, p2, p3) {
                                return FlDotCirclePainter(
                                  radius: 3,
                                  strokeWidth: 0.5,
                                  color: Colors.red,
                                );
                              },
                            )));
                  }, touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                    return touchedBarSpots.map((barSpot) {
                      DateTime date = getPeriodMin(currentPeriod)
                          .add(Duration(minutes: barSpot.x.round()));
                      return LineTooltipItem(
                        '''${symbolWriting(mainCurrProv.mainCurrency)} ${thousandSeparator(barSpot.y.toStringAsFixed(1))}
${dateFormatter(date)} at ${DateFormat("HH:mm").format(date)}''',
                        const TextStyle(
                          color: Colors.white,
                        ),
                      );
                    }).toList();
                  })),
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    drawHorizontalLine: true,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        strokeWidth: 1.5,
                        color: Color.fromARGB(111, 158, 158, 158),
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value == meta.max || value == meta.min) {
                            return Container();
                          } else {
                            return Row(
                              children: [
                                const Spacer(),
                                //Text("${kFormat(value)}"),
                                displayText(value),
                                //Padding(padding: EdgeInsets.only(left: 2)),
                                const Spacer(),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: getBottomTitles(),
                    ),
                  ),
                  borderData: FlBorderData(
                    border: Border(
                      left: BorderSide(
                        width: 1.5,
                      ),
                      bottom: BorderSide(
                        width: 1.5,
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                        isStrokeCapRound: true,
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(131, 0, 221, 255),
                              Color.fromARGB(0, 0, 221, 255),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        barWidth: 3.5,
                        spots: List.generate(
                          graphData.length,
                          (i) => FlSpot(
                            graphData[i].x,
                            graphData[i].y,
                          ),
                        ),
                        preventCurveOverShooting: true,
                        isCurved: true,
                        curveSmoothness: 0.1,
                        dotData: FlDotData(
                          show: false,
                        )),
                  ],
                  minX: minX,
                  maxX: maxX,
                  minY: minY,
                  maxY: maxY,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Coordinates {
  final double x;
  final double y;
  Coordinates({required this.x, required this.y});
}
