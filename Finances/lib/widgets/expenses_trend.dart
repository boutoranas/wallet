import 'dart:convert';

import 'package:finances/const.dart';
import 'package:finances/utils/formatters.dart';
import 'package:finances/widgets/balance_trend.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../secondary_pages/filter_page.dart';
import '../utils/objects.dart';
import '../utils/provider.dart';
import '../utils/user_preferences.dart';

class ExpensesTrend extends StatefulWidget {
  const ExpensesTrend({super.key});

  @override
  State<ExpensesTrend> createState() => _ExpensesTrendState();
}

class _ExpensesTrendState extends State<ExpensesTrend> {
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

  List<Expense> getExpenses(ExpensesProvider expensesProvider,
      SelectedAccounts selectedIndexesProv, AccountsProvider accountsProvider) {
    List<Account> selectedAccounts = accountsProvider.accounts
        .where((element) => selectedIndexesProv.indexes
            .contains(accountsProvider.accounts.indexOf(element)))
        .toList();
    List<Expense> e = [];
    for (var element in expensesProvider.expenses) {
      if (isAccountInList(selectedAccounts, element) &&
          (element.type == "Expense" ||
              element.type == "Transfer" &&
                  element.fees != null &&
                  element.fees! > 0)) {
        e.add(element);
      }
    }
    e.sort((a, b) => b.date.compareTo(a.date));
    return e;
  }

  bool isAccountInList(List<Account> accountsList, Expense expense) {
    for (var element in accountsList) {
      if (element.id == expense.account.id) {
        return true;
      }
    }
    return false;
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

  List<Coordinates> getBars(
      ExpensesProvider expensesProvider,
      SelectedAccounts selectedAccountsProv,
      AccountsProvider accountsProvider,
      MainCurrency mainCurrencyProv) {
    List<Coordinates> c = [];
    List<Expense> expenses =
        getExpenses(expensesProvider, selectedAccountsProv, accountsProvider);
    if (currentPeriod == "Last 30 days") {
      List.generate(30, (i) {
        double totalExpenses = 0;
        DateTime dateTime =
            dayOfDate(DateTime.now()).subtract(Duration(days: 29 - i));
        for (var expense in expenses) {
          if (dayOfDate(expense.date).isAtSameMomentAs(dateTime) &&
              expense.date.isBefore(DateTime.now())) {
            totalExpenses += convertBackToMain(
              convertToUsd(
                  expense.type != "Transfer"
                      ? expense.amount
                      : expense.amount * (expense.fees! / 100),
                  expense.account.currency),
              mainCurrencyProv.defaultCurrency,
            );
          }
        }
        c.add(
          Coordinates(
            x: i.toDouble(),
            y: totalExpenses,
          ),
        );
      });
      return c;
    } else if (currentPeriod == "Last 7 days") {
      List.generate(7, (i) {
        double totalExpenses = 0;
        DateTime dateTime =
            dayOfDate(DateTime.now()).subtract(Duration(days: 6 - i));
        for (var expense in expenses) {
          if (dayOfDate(expense.date).isAtSameMomentAs(dateTime) &&
              expense.date.isBefore(DateTime.now())) {
            totalExpenses += convertBackToMain(
              convertToUsd(
                  expense.type != "Transfer"
                      ? expense.amount
                      : expense.amount * (expense.fees! / 100),
                  expense.account.currency),
              mainCurrencyProv.defaultCurrency,
            );
          }
        }
        c.add(
          Coordinates(
            x: i.toDouble(),
            y: totalExpenses,
          ),
        );
      });
      return c;
    } else if (currentPeriod == "Last 365 days") {
      List.generate(12, (i) {
        double totalExpenses = 0;
        DateTime dateTime =
            DateTime(DateTime.now().year, DateTime.now().month - 11 + i);
        for (var expense in expenses) {
          if (monthOfDate(expense.date).isAtSameMomentAs(dateTime) &&
              expense.date.isBefore(DateTime.now())) {
            totalExpenses += convertBackToMain(
              convertToUsd(
                  expense.type != "Transfer"
                      ? expense.amount
                      : expense.amount * (expense.fees! / 100),
                  expense.account.currency),
              mainCurrencyProv.defaultCurrency,
            );
          }
        }
        c.add(
          Coordinates(
            x: i.toDouble(),
            y: totalExpenses,
          ),
        );
      });
      return c;
    } else {
      return [];
    }
  }

  double getWidth(BuildContext context) {
    if (currentPeriod == "Last 30 days") {
      return (MediaQuery.of(context).size.width - 20 - 30 - 1.5 - 40 - 20 - 3) /
          30;
    } else if (currentPeriod == "Last 7 days") {
      return (MediaQuery.of(context).size.width - 20 - 30 - 1.5 - 40 - 20 - 3) /
          7;
    } else if (currentPeriod == "Last 365 days") {
      return (MediaQuery.of(context).size.width - 20 - 30 - 1.5 - 40 - 20 - 3) /
          12;
    } else {
      return 0;
    }
  }

  String getText(double value) {
    if (currentPeriod == "Last 7 days") {
      return (DateFormat("EEEE")
          .format(DateTime.now().subtract(Duration(days: 6 - value.round()))));
    } else if (currentPeriod == "Last 30 days") {
      return (DateFormat("d MMMM")
          .format(DateTime.now().subtract(Duration(days: 29 - value.round()))));
    } else {
      return (DateFormat("MMM yyyy").format(DateTime(
          DateTime.now().year, DateTime.now().month - 11 + value.round())));
    }
  }

  SideTitles getBottomTitles() {
    return SideTitles(
      showTitles: true,
      getTitlesWidget: (value, meta) {
        if ((currentPeriod == "Last 7 days") ||
            (currentPeriod == "Last 30 days" && (value.round() + 1) % 5 == 0) ||
            (currentPeriod == "Last 365 days" &&
                (value.round() + 1) % 3 == 0)) {
          if (currentPeriod == "Last 7 days") {
            return Text(DateFormat("EEE").format(
                DateTime.now().subtract(Duration(days: 6 - value.round()))));
          } else if (currentPeriod == "Last 30 days") {
            return Text(DateFormat("d/M").format(
                DateTime.now().subtract(Duration(days: 29 - value.round()))));
          } else {
            return Text(DateFormat("MMM").format(DateTime(DateTime.now().year,
                DateTime.now().month - 11 + value.round())));
          }
        } else {
          return Container();
        }
      },
    );
  }

  double getMaxY(List<Coordinates> barsData) {
    double highestPoint = 0;
    for (var bar in barsData) {
      if (bar.y > highestPoint) {
        highestPoint = bar.y;
      }
    }
    return highestPoint + highestPoint * 0.25;
  }

  String currentPeriod = UserPreferences.getFilters()["expenses trend"] != null
      ? UserPreferences.getFilters()["expenses trend"]["period"]
      : "Last 30 days";

  @override
  Widget build(BuildContext context) {
    final expensesProvider = Provider.of<ExpensesProvider>(context);
    final selectedIndexesProv = Provider.of<SelectedAccounts>(context);
    final accountsProv = Provider.of<AccountsProvider>(context);
    final mainCurrProv = Provider.of<MainCurrency>(context);
    double width = getWidth(context);
    List<Coordinates> barsData = getBars(
        expensesProvider, selectedIndexesProv, accountsProv, mainCurrProv);
    bool isEmpty = true;
    for (var data in barsData) {
      if (data.y > 0) {
        isEmpty = false;
      }
    }
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
                "Expenses trend:",
                style: titleStyle,
              ),
              Spacer(),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (context) => FilterPage(
                      filters: [
                        "period (limited)",
                      ],
                      currentPeriod: currentPeriod,
                      currentType: "",
                    ),
                  ).then((value) {
                    if (value != null) {
                      setState(() {
                        currentPeriod = value["period"];
                        Map map = UserPreferences.getFilters();
                        if (map["expenses trend"] != null &&
                            map["expenses trend"].containsKey("period")) {
                          map["expenses trend"].remove("period");
                        }
                        map.addAll({
                          "expenses trend": {
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
            child: Text(currentPeriod),
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
              child: !isEmpty
                  ? BarChart(
                      BarChartData(
                        maxY: getMaxY(barsData),
                        barTouchData:
                            BarTouchData(touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (BarChartGroupData barChartGroupData,
                              int a, BarChartRodData barChartRodData, int b) {
                            return BarTooltipItem(
                              '''${symbolWriting(mainCurrProv.mainCurrency)} ${thousandSeparator(barChartGroupData.barRods[0].toY.toStringAsFixed(1))}
${getText(barChartGroupData.x.toDouble())}''',
                              TextStyle(
                                color: Colors.white,
                              ),
                            );
                          },
                        )),
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
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: getBottomTitles(),
                          ),
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
                        ),
                        alignment: BarChartAlignment.start,
                        groupsSpace: 0,
                        barGroups: [
                          ...List.generate(barsData.length, (i) {
                            return BarChartGroupData(
                              x: barsData[i].x.round(),
                              barRods: [
                                BarChartRodData(
                                  borderSide: BorderSide(
                                    width: 1,
                                    color: Colors.black,
                                  ),
                                  toY: barsData[i].y,
                                  width: width,
                                  borderRadius: BorderRadius.zero,
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    )
                  : Center(
                      child: Text("No expense at the moment"),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
