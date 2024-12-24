import 'dart:convert';

import 'package:finances/const.dart';
import 'package:finances/secondary_pages/edit_budget.dart';
import 'package:finances/secondary_pages/filter_page.dart';
import 'package:finances/utils/user_preferences.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../utils/formatters.dart';
import '../utils/provider.dart';

class Budget extends StatefulWidget {
  const Budget({super.key});

  @override
  State<Budget> createState() => _BudgetState();
}

class _BudgetState extends State<Budget> {
  String period = UserPreferences.getFilters()["budget"] != null
      ? UserPreferences.getFilters()["budget"]["period"]
      : "Monthly";
  String type = UserPreferences.getFilters()["budget"] != null
      ? UserPreferences.getFilters()["budget"]["type"]
      : "Revenue excluded";
  int firstTime = UserPreferences.getFilters()["budget"] != null
      ? UserPreferences.getFilters()["budget"]["first time"]
      : 1;

  Map budgetMap = UserPreferences.getBudget();

  int selectedPeriod = 0;

  List<String> daysOfTheWeekComplete = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  DateTime getMaxPeriod() {
    if (period == "Daily") {
      if (!dayOfDate(DateTime.now())
          .subtract(Duration(days: selectedPeriod))
          .add(Duration(hours: firstTime))
          .isAfter(DateTime.now().subtract(Duration(days: selectedPeriod)))) {
        return dayOfDate(
                DateTime.now().subtract(Duration(days: selectedPeriod)))
            .add(Duration(hours: firstTime))
            .add(Duration(days: 1));
      } else {
        return dayOfDate(
                DateTime.now().subtract(Duration(days: selectedPeriod)))
            .add(Duration(days: -1, hours: firstTime))
            .add(Duration(days: 1));
      }
    } else if (period == "Weekly") {
      if (!weekOfDate(DateTime.now())
          .subtract(Duration(days: selectedPeriod * 7))
          .add(Duration(days: firstTime - 1))
          .isAfter(
              DateTime.now().subtract(Duration(days: selectedPeriod * 7)))) {
        return weekOfDate(DateTime.now())
            .subtract(Duration(days: selectedPeriod * 7))
            .add(Duration(days: 7))
            .add(Duration(days: firstTime - 1));
      } else {
        return weekOfDate(DateTime.now())
            .subtract(Duration(days: selectedPeriod * 7))
            .add(Duration(days: 7))
            .add(Duration(days: firstTime - 1 - 7));
      }
    } else if (period == "Monthly") {
      if (!DateTime(DateTime.now().year, DateTime.now().month - selectedPeriod,
              firstTime)
          .isAfter(DateTime(DateTime.now().year,
              DateTime.now().month - selectedPeriod, DateTime.now().day))) {
        return DateTime(DateTime.now().year,
            DateTime.now().month - selectedPeriod + 1, firstTime);
      } else {
        return DateTime(DateTime.now().year,
            DateTime.now().month - selectedPeriod, firstTime);
      }
    } else {
      if (!DateTime(DateTime.now().year - selectedPeriod, firstTime).isAfter(
          (DateTime(
              DateTime.now().year - selectedPeriod, DateTime.now().month)))) {
        return DateTime(DateTime.now().year - selectedPeriod + 1, firstTime);
      } else {
        return DateTime(DateTime.now().year - selectedPeriod, firstTime);
      }
    }
  }

  DateTime getMinPeriod() {
    if (period == "Daily") {
      print(dayOfDate(DateTime.now()).subtract(Duration(days: selectedPeriod)));
      if (!dayOfDate(DateTime.now())
          .subtract(Duration(days: selectedPeriod))
          .add(Duration(hours: firstTime))
          .isAfter(DateTime.now().subtract(Duration(days: selectedPeriod)))) {
        return dayOfDate(
                DateTime.now().subtract(Duration(days: selectedPeriod)))
            .add(Duration(hours: firstTime));
      } else {
        return dayOfDate(
                DateTime.now().subtract(Duration(days: selectedPeriod)))
            .add(Duration(days: -1, hours: firstTime));
      }
    } else if (period == "Weekly") {
      if (!weekOfDate(DateTime.now())
          .subtract(Duration(days: selectedPeriod * 7))
          .add(Duration(days: firstTime - 1))
          .isAfter(
              DateTime.now().subtract(Duration(days: selectedPeriod * 7)))) {
        return weekOfDate(DateTime.now())
            .subtract(Duration(days: selectedPeriod * 7))
            .add(Duration(days: firstTime - 1));
      } else {
        return weekOfDate(DateTime.now())
            .subtract(Duration(days: selectedPeriod * 7))
            .add(Duration(days: firstTime - 1 - 7));
      }
    } else if (period == "Monthly") {
      if (!DateTime(DateTime.now().year, DateTime.now().month - selectedPeriod,
              firstTime)
          .isAfter(DateTime(DateTime.now().year,
              DateTime.now().month - selectedPeriod, DateTime.now().day))) {
        return DateTime(DateTime.now().year,
            DateTime.now().month - selectedPeriod, firstTime);
      } else {
        return DateTime(DateTime.now().year,
            DateTime.now().month - 1 - selectedPeriod, firstTime);
      }
    } else {
      print(DateTime(DateTime.now().year - selectedPeriod + 1, firstTime));
      if (!DateTime(DateTime.now().year - selectedPeriod, firstTime).isAfter(
          (DateTime(
              DateTime.now().year - selectedPeriod, DateTime.now().month)))) {
        return DateTime(DateTime.now().year - selectedPeriod, firstTime);
      } else {
        return DateTime(DateTime.now().year - selectedPeriod - 1, firstTime);
      }
    }
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

  double getExpenses(
      ExpensesProvider expensesProvider, MainCurrency mainCurrProv) {
    double total = 0;
    for (var expense in expensesProvider.expenses) {
      if (!expense.date.isBefore(getMinPeriod()) &&
          !expense.date.isAfter(getMaxPeriod())) {
        if (expense.type == "Expense") {
          total += convertBackToMain(
              convertToUsd(expense.amount, expense.account.currency),
              mainCurrProv.mainCurrency);
        } else if (expense.type == "Income" && type != "Revenue excluded") {
          total -= convertBackToMain(
              convertToUsd(expense.amount, expense.account.currency),
              mainCurrProv.mainCurrency);
        } else if (expense.type == "Transfer" &&
            expense.fees != null &&
            expense.fees != 0) {
          total += convertBackToMain(
              convertToUsd(expense.amount * (expense.fees! / 100),
                  expense.account.currency),
              mainCurrProv.mainCurrency);
        }
      }
    }
    if (total < 0) {
      return 0;
    }
    if (total > budgetMap[period.toLowerCase()]) {
      return budgetMap[period.toLowerCase()];
    }
    return total;
  }

  double getExpensesOnly(
      ExpensesProvider expensesProvider, MainCurrency mainCurrProv) {
    double total = 0;
    for (var expense in expensesProvider.expenses) {
      if (!expense.date.isBefore(getMinPeriod()) &&
          !expense.date.isAfter(getMaxPeriod())) {
        if (expense.type == "Expense") {
          total += convertBackToMain(
              convertToUsd(expense.amount, expense.account.currency),
              mainCurrProv.mainCurrency);
        } else if (expense.type == "Transfer" &&
            expense.fees != null &&
            expense.fees! > 0) {
          total += convertBackToMain(
              convertToUsd(expense.amount * (expense.fees! / 100),
                  expense.account.currency),
              mainCurrProv.mainCurrency);
        }
      }
    }
    return total;
  }

  double getIncomeOnly(
      ExpensesProvider expensesProvider, MainCurrency mainCurrProv) {
    double total = 0;
    for (var expense in expensesProvider.expenses) {
      if (!expense.date.isBefore(getMinPeriod()) &&
          !expense.date.isAfter(getMaxPeriod())) {
        if (expense.type == "Income" && type != "Revenue excluded") {
          total += convertBackToMain(
              convertToUsd(expense.amount, expense.account.currency),
              mainCurrProv.mainCurrency);
        } else if (expense.type == "Transfer" &&
            expense.fees != null &&
            expense.fees! < 0) {
          total += convertBackToMain(
                  convertToUsd(expense.amount * (expense.fees! / 100),
                      expense.account.currency),
                  mainCurrProv.mainCurrency)
              .abs();
        }
      }
    }
    return total;
  }

  editBudgets(context) async {
    await showDialog(
      context: context,
      builder: (context) => EditBudget(),
    ).then((value) {
      if (value != null) {
        setState(() {
          budgetMap = value;
        });
      }
    });
  }

  checkForCurrencyChange(MainCurrency mainCurrencyProv) {
    if (budgetMap["currency"] != null &&
        budgetMap["currency"] != mainCurrencyProv.mainCurrency) {
      if (budgetMap["daily"] != null) {
        budgetMap["daily"] = convertBackToMain(
          convertToUsd(budgetMap["daily"], budgetMap["currency"]),
          mainCurrencyProv.mainCurrency,
        );
      }
      if (budgetMap["weekly"] != null) {
        budgetMap["weekly"] = convertBackToMain(
          convertToUsd(budgetMap["weekly"], budgetMap["currency"]),
          mainCurrencyProv.mainCurrency,
        );
      }
      if (budgetMap["monthly"] != null) {
        budgetMap["monthly"] = convertBackToMain(
          convertToUsd(budgetMap["monthly"], budgetMap["currency"]),
          mainCurrencyProv.mainCurrency,
        );
        print("yup");
      }
      if (budgetMap["yearly"] != null) {
        budgetMap["yearly"] = convertBackToMain(
          convertToUsd(budgetMap["yearly"], budgetMap["currency"]),
          mainCurrencyProv.mainCurrency,
        );
      }
      print(budgetMap["monthly"] != null);
      budgetMap["currency"] = mainCurrencyProv.mainCurrency;
      UserPreferences.saveBudget(json.encode(budgetMap));
    }
  }

  previousPeriod() {
    setState(() {
      selectedPeriod++;
    });
  }

  nextPeriod() {
    if (selectedPeriod >= 1) {
      setState(() {
        selectedPeriod--;
      });
    }
  }

  String displayPeriodDates() {
    if (period == "Daily") {
      return "${dateFormatter(getMinPeriod())} - ${dateFormatter(getMaxPeriod())} (${"${firstTime.toString().padLeft(2, '0')}:00"})";
    } else if (period == "Weekly") {
      return "${dateFormatter(getMinPeriod())} - ${dateFormatter(getMaxPeriod())} (${daysOfTheWeekComplete[firstTime - 1]})";
    } else if (period == "Monthly") {
      return "${dateFormatter(getMinPeriod())} - ${dateFormatter(getMaxPeriod())}";
    } else {
      return "${getMinPeriod().year} - ${getMaxPeriod().year} (${displayMonth(firstTime)})";
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainCurrProv = Provider.of<MainCurrency>(context);
    final expensesProvider = Provider.of<ExpensesProvider>(context);
    checkForCurrencyChange(mainCurrProv);
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
                "Budget:",
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
                        "period (budget)",
                        "type (budget)",
                        "first time"
                      ],
                      currentPeriod: period,
                      currentType: type,
                      firstTime: firstTime,
                    ),
                  ).then((value) => {
                        if (value != null)
                          {
                            setState(() {
                              period = value["period"];
                              type = value["type"];
                              firstTime = value["first time"];

                              Map map = UserPreferences.getFilters();
                              if (map["budget"] != null &&
                                  map["budget"].containsKey("period")) {
                                map["budget"].remove("period");
                              }
                              if (map["budget"] != null &&
                                  map["budget"].containsKey("type")) {
                                map["budget"].remove("type");
                              }
                              if (map["budget"] != null &&
                                  map["budget"].containsKey("first time")) {
                                map["budget"].remove("first time");
                              }
                              map.addAll({
                                "budget": {
                                  "period": period,
                                  "type": type,
                                  "first time": firstTime,
                                }
                              } as Map<String, dynamic>);
                              UserPreferences.saveFilters(json.encode(map));
                            })
                          }
                      });
                },
                icon: Icon(Icons.sort),
              ),
            ],
          ),
          Padding(padding: EdgeInsets.only(bottom: 8)),
          Align(
            child: Text("$period, ${type.toLowerCase()}"),
            alignment: Alignment.centerLeft,
          ),
          Padding(padding: EdgeInsets.only(bottom: 20)),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                    onTap: () {
                      previousPeriod();
                      print(selectedPeriod);
                    },
                    child: Icon(Icons.arrow_back_ios)),
                Text(
                  displayPeriodDates(),
                  style: TextStyle(fontSize: 12),
                ),
                GestureDetector(
                    onTap: () {
                      nextPeriod();
                      print(selectedPeriod);
                    },
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: selectedPeriod == 0 ? Colors.grey : null,
                    )),
              ],
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: 8)),
          budgetMap[period.toLowerCase()] != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$period goal: ",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      "${symbolWriting(mainCurrProv.mainCurrency)} ${thousandSeparator(budgetMap[period.toLowerCase()].toStringAsFixed(1))}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        editBudgets(context);
                      },
                      icon: Icon(Icons.edit),
                    ),
                  ],
                )
              : Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("No ${period.toLowerCase()} budget set"),
                      IconButton(
                        onPressed: () {
                          editBudgets(context);
                        },
                        icon: Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
          Padding(padding: EdgeInsets.only(bottom: 10)),
          budgetMap[period.toLowerCase()] != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: SizedBox(
                    height: 30,
                    child: Row(
                      children: [
                        Container(
                          height: 30,
                          width: (MediaQuery.of(context).size.width -
                                  (20 + 30 + 2)) *
                              (getExpenses(expensesProvider, mainCurrProv) /
                                  budgetMap[period.toLowerCase()]),
                          color: getExpenses(expensesProvider, mainCurrProv) >=
                                  budgetMap[period.toLowerCase()] * 0.9
                              ? Colors.red
                              : Colors.green,
                          child: Center(
                            child: getExpenses(expensesProvider, mainCurrProv) /
                                        budgetMap[period.toLowerCase()] >
                                    0.09
                                ? Text(
                                    "${(getExpenses(expensesProvider, mainCurrProv) / budgetMap[period.toLowerCase()] * 100).toStringAsFixed(1)}%",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  )
                                : Container(),
                          ),
                        ),
                        Container(
                          height: 30,
                          width: (MediaQuery.of(context).size.width -
                                  (20 + 30 + 2)) *
                              (1 -
                                  getExpenses(expensesProvider, mainCurrProv) /
                                      budgetMap[period.toLowerCase()]),
                          color: Colors.blueGrey,
                          child: Center(
                            child: getExpenses(expensesProvider, mainCurrProv) /
                                        budgetMap[period.toLowerCase()] <=
                                    0.09
                                ? Text(
                                    "${((1 - getExpenses(expensesProvider, mainCurrProv) / budgetMap[period.toLowerCase()]) * 100).toStringAsFixed(1)}% left",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  )
                                : Container(),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: SizedBox(
                    height: 30,
                    child: Container(
                      height: 30,
                      width:
                          (MediaQuery.of(context).size.width - (20 + 30 + 2)) *
                              1,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
          Padding(padding: EdgeInsets.only(bottom: 15)),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Amount spent: ${symbolWriting(mainCurrProv.mainCurrency)} ${thousandSeparator(getExpensesOnly(expensesProvider, mainCurrProv).toStringAsFixed(1))}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: 5)),
          type == "Revenue included"
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Revenue: ${symbolWriting(mainCurrProv.mainCurrency)} ${thousandSeparator(getIncomeOnly(expensesProvider, mainCurrProv).toStringAsFixed(1))}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
