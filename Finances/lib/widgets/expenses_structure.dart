import 'dart:convert';

import 'package:finances/secondary_pages/choose_categories.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_color_models/flutter_color_models.dart';
import 'package:provider/provider.dart';

import '../const.dart';
import '../secondary_pages/filter_page.dart';
import '../utils/app_data.dart';
import '../utils/formatters.dart';
import '../utils/objects.dart';
import '../utils/provider.dart';
import '../utils/user_preferences.dart';

class ExpensesStructure extends StatefulWidget {
  const ExpensesStructure({super.key});

  @override
  State<ExpensesStructure> createState() => _ExpensesStructureState();
}

class _ExpensesStructureState extends State<ExpensesStructure> {
  int touchedIndex = -1;
  int subTouchedIndex = -1;

  String currentPeriod =
      UserPreferences.getFilters()["expenses structure"] != null
          ? UserPreferences.getFilters()["expenses structure"]["period"]
          : "This month";
  String currentType =
      UserPreferences.getFilters()["expenses structure"] != null
          ? UserPreferences.getFilters()["expenses structure"]["type"]
          : "Expenses";

  String getCurrentType(String type) {
    switch (type) {
      case "Income":
        return "Income";
      default:
        return "Expense";
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
      default:
        return DateTime(2000, 1, 1);
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

  bool isAccountInList(List<Account> accountsList, Expense expense) {
    for (var element in accountsList) {
      if (element.id == expense.account.id) {
        return true;
      }
    }
    /* for (var element in accountsList) {
      if (element.id == expense.category) {
        return true;
      }
    } */
    return false;
  }

  List<CategoryExpense> getExpensesPerCategory(
    ExpensesProvider expensesProvider,
    SelectedAccounts selectedIndexesProv,
    AccountsProvider accountsProvider,
  ) {
    List<Account> selectedAccounts = accountsProvider.accounts
        .where((element) => selectedIndexesProv.indexes
            .contains(accountsProvider.accounts.indexOf(element)))
        .toList();
    List<Expense> e = [];
    for (var element in expensesProvider.expenses) {
      if ((currentType == "All" ||
              element.type == getCurrentType(currentType) ||
              (getCurrentType(currentType) == "Expense" &&
                  element.fees != null &&
                  element.fees! > 0) ||
              (getCurrentType(currentType) == "Income" &&
                  element.fees != null &&
                  element.fees! < 0)) &&
          (!element.date.isBefore(getPeriodMin(currentPeriod)) &&
              !(element.date).isAfter((DateTime.now()))) &&
          isAccountInList(selectedAccounts, element)) {
        e.add(element);
      }
    }
    List<CategoryExpense> categoryExpenses = [];
    for (var element in categories) {
      categoryExpenses.add(
        CategoryExpense(category: element, amount: 0),
      );
    }
    for (var expense in e) {
      Category category = expense.type != "Transfer"
          ? subcategories
              .where((element) => element.name != "General"
                  ? element.name == expense.category
                  : element.category.name == expense.category)
              .toList()[0]
              .category
          : subcategories
              .where((element) => element.name == "Charges and fees")
              .toList()[0]
              .category;
      categoryExpenses
              .where((element) => element.category == category)
              .toList()[0]
              .amount +=
          expense.type != "Transfer"
              ? convertToUsd(expense.amount, expense.account.currency)
              : convertToUsd(expense.amount * (expense.fees! / 100),
                      expense.account.currency)
                  .abs();
    }
    categoryExpenses.removeWhere((element) => element.amount == 0);
    return categoryExpenses;
  }

  List<SubCategoryExpense> getExpensesPerSubCategory(
    ExpensesProvider expensesProvider,
    SelectedAccounts selectedIndexesProv,
    AccountsProvider accountsProvider,
    Category category,
  ) {
    List<Account> selectedAccounts = accountsProvider.accounts
        .where((element) => selectedIndexesProv.indexes
            .contains(accountsProvider.accounts.indexOf(element)))
        .toList();
    List<Expense> e = [];
    for (var element in expensesProvider.expenses) {
      if ((currentType == "All" ||
              element.type == getCurrentType(currentType) ||
              (getCurrentType(currentType) == "Expense" &&
                  element.fees != null &&
                  element.fees! > 0) ||
              (getCurrentType(currentType) == "Income" &&
                  element.fees != null &&
                  element.fees! < 0)) &&
          subcategories
                  .where(
                    (subCat) => element.type != "Transfer"
                        ? subCat.name == element.category ||
                            subCat.category.name == element.category
                        : subCat.name == "Charges and fees",
                  )
                  .toList()[0]
                  .category ==
              category &&
          (!element.date.isBefore(getPeriodMin(currentPeriod)) &&
              !(element.date).isAfter((DateTime.now()))) &&
          isAccountInList(selectedAccounts, element)) {
        e.add(element);
      }
    }
    List<SubCategoryExpense> categoryExpenses = [];
    for (var element in subcategories
        .where((subCat) => subCat.category == category)
        .toList()) {
      categoryExpenses.add(
        SubCategoryExpense(subCategory: element, amount: 0),
      );
    }
    for (var expense in e) {
      categoryExpenses
              .where((subCat) => expense.type != "Transfer"
                  ? subCat.subCategory.name == expense.category ||
                      subCat.subCategory.category.name == expense.category
                  : subCat.subCategory.name == "Charges and fees")
              .toList()[0]
              .amount +=
          expense.type != "Transfer"
              ? convertToUsd(expense.amount, expense.account.currency)
              : convertToUsd(expense.amount * (expense.fees! / 100),
                      expense.account.currency)
                  .abs();
    }
    categoryExpenses.removeWhere((element) => element.amount == 0);
    return categoryExpenses;
  }

  double getSubTotal(List<SubCategoryExpense> expenses) {
    double total = 0;
    for (var element in expenses) {
      total += element.amount;
    }
    return total;
  }

  double getTotal(List<CategoryExpense> expenses) {
    double total = 0;
    for (var element in expenses) {
      total += element.amount;
      print(total);
    }
    return total;
  }

  bool showSubCategory = false;

  @override
  Widget build(BuildContext context) {
    final expensesProvider = Provider.of<ExpensesProvider>(context);
    final selectedIndexProv = Provider.of<SelectedAccounts>(context);
    final accountProv = Provider.of<AccountsProvider>(context);
    List<CategoryExpense> expenses = getExpensesPerCategory(
        expensesProvider, selectedIndexProv, accountProv);
    expensesProvider.addListener(() {
      setState(() {
        touchedIndex = -1;
        subTouchedIndex = -1;
        showSubCategory = false;
      });
    });
    selectedIndexProv.addListener(() {
      touchedIndex = -1;
      subTouchedIndex = -1;
      showSubCategory = false;
    });
    if (expenses.length - 1 < touchedIndex) {
      touchedIndex = -1;
    }
    final mainCurrProv = Provider.of<MainCurrency>(context);
    if (showSubCategory == false) {
      return GestureDetector(
        onTap: () {
          setState(() {
            touchedIndex = -1;
          });
        },
        child: Container(
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
                    "Expenses/Income structure:",
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
                            "period",
                            "type (dual)",
                          ],
                          currentPeriod: currentPeriod,
                          currentType: currentType,
                        ),
                      ).then((value) {
                        if (value != null) {
                          setState(() {
                            if (currentType != value["type"]) {
                              showSubCategory = false;
                              subTouchedIndex = -1;
                              touchedIndex = -1;
                            }
                            currentPeriod = value["period"];
                            currentType = value["type"];

                            Map map = UserPreferences.getFilters();
                            if (map["expenses structure"] != null &&
                                map["expenses structure"]
                                    .containsKey("period")) {
                              map["expenses structure"].remove("period");
                            }
                            if (map["expenses structure"] != null &&
                                map["expenses structure"].containsKey("type")) {
                              map["expenses structure"].remove("type");
                            }
                            map.addAll({
                              "expenses structure": {
                                "period": currentPeriod,
                                "type": currentType,
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
                child: Text("$currentPeriod, ${currentType.toLowerCase()}"),
                alignment: Alignment.centerLeft,
              ),
              Padding(padding: EdgeInsets.only(bottom: 10)),
              SizedBox(
                height: 250,
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.all(18),
                      child: getTotal(expenses) != 0
                          ? PieChart(
                              PieChartData(
                                  pieTouchData: PieTouchData(
                                    enabled: true,
                                    touchCallback:
                                        (FlTouchEvent event, pieTouchResponse) {
                                      setState(() {
                                        if (pieTouchResponse != null) {
                                          if (pieTouchResponse.touchedSection ==
                                              null) {
                                            touchedIndex = -1;
                                            return;
                                          }

                                          touchedIndex = pieTouchResponse
                                              .touchedSection!
                                              .touchedSectionIndex;
                                        }
                                      });
                                    },
                                  ),
                                  borderData: FlBorderData(
                                    show: false,
                                  ),
                                  sectionsSpace: 0,
                                  sections: [
                                    ...List.generate(
                                      expenses.length,
                                      (i) => PieChartSectionData(
                                        radius: touchedIndex == i ? 55 : 45,
                                        value: expenses[i].amount,
                                        title: expenses[i].amount /
                                                    getTotal(expenses) >
                                                0.1
                                            ? "${(expenses[i].amount / getTotal(expenses) * 100).round()}%"
                                            : "",
                                        color: subcategories
                                            .where((element) =>
                                                element.category ==
                                                    expenses[i].category ||
                                                element.category ==
                                                    expenses[i].category)
                                            .toList()[0]
                                            .color,
                                      ),
                                    ),
                                  ]),
                            )
                          : Center(
                              child:
                                  Text("No ${currentType.toLowerCase()} yet"),
                            ),
                    ),
                    Center(
                      child: Container(
                        width: 90,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              touchedIndex != -1
                                  ? expenses[touchedIndex].category.name
                                  : "",
                              style: TextStyle(
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              touchedIndex != -1
                                  ? "${(expenses[touchedIndex].amount / getTotal(expenses) * 100).round()}%"
                                  : "",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    touchedIndex != -1
                        ? Align(
                            alignment: Alignment(1, 0),
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    showSubCategory = true;
                                  });
                                },
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 36,
                                )),
                          )
                        : Container(),
                  ],
                ),
              ),
              ListView(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [
                  ...List.generate(
                    expenses.length,
                    (i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              height: touchedIndex == i ? 18 : 15,
                              width: touchedIndex == i ? 18 : 15,
                              decoration: BoxDecoration(
                                  color: expenses[i].category.color,
                                  borderRadius: BorderRadius.circular(4)),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "${expenses[i].category.name} (${symbolWriting(mainCurrProv.mainCurrency)} ${convertBackToMain(expenses[i].amount, mainCurrProv.mainCurrency).toStringAsFixed(1)})",
                              style: touchedIndex == i
                                  ? TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      List<SubCategoryExpense> subCatExpenses = getExpensesPerSubCategory(
          expensesProvider,
          selectedIndexProv,
          accountProv,
          getExpensesPerCategory(expensesProvider, selectedIndexProv,
                  accountProv)[touchedIndex]
              .category);
      Color color = getExpensesPerCategory(
              expensesProvider, selectedIndexProv, accountProv)[touchedIndex]
          .category
          .color;
      List<ColorModel> paletteRange = <ColorModel>[
        RgbColor(color.red, color.green, color.blue),
        const RgbColor(255, 255, 255),
      ];
      List<ColorModel> palette =
          paletteRange.augment(subCatExpenses.length + 2);
      return GestureDetector(
        onTap: () {
          setState(() {
            subTouchedIndex = -1;
          });
        },
        child: Container(
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
                    "Expenses/Income structure:",
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
                            "period",
                            "type (dual)",
                          ],
                          currentPeriod: currentPeriod,
                          currentType: currentType,
                        ),
                      ).then((value) {
                        if (value != null) {
                          setState(() {
                            if (currentType != value["type"]) {
                              showSubCategory = false;
                              subTouchedIndex = -1;
                              touchedIndex = -1;
                            }
                            currentPeriod = value["period"];
                            currentType = value["type"];
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
                    "$currentPeriod, ${currentType.toLowerCase()}, ${getExpensesPerCategory(expensesProvider, selectedIndexProv, accountProv)[touchedIndex].category.name.toLowerCase()}"),
                alignment: Alignment.centerLeft,
              ),
              Padding(padding: EdgeInsets.only(bottom: 10)),
              SizedBox(
                height: 250,
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.all(18),
                      child: getSubTotal(subCatExpenses) != 0
                          ? PieChart(
                              PieChartData(
                                  pieTouchData: PieTouchData(
                                    enabled: true,
                                    touchCallback:
                                        (FlTouchEvent event, pieTouchResponse) {
                                      setState(() {
                                        if (pieTouchResponse != null) {
                                          if (pieTouchResponse.touchedSection ==
                                              null) {
                                            subTouchedIndex = -1;
                                            return;
                                          }

                                          subTouchedIndex = pieTouchResponse
                                              .touchedSection!
                                              .touchedSectionIndex;
                                        }
                                      });
                                    },
                                  ),
                                  borderData: FlBorderData(
                                    show: false,
                                  ),
                                  sectionsSpace: 0,
                                  sections: [
                                    ...List.generate(
                                      subCatExpenses.length,
                                      (i) => PieChartSectionData(
                                          radius:
                                              subTouchedIndex == i ? 55 : 45,
                                          value: subCatExpenses[i].amount,
                                          title: subCatExpenses[i].amount /
                                                      getSubTotal(
                                                          subCatExpenses) >
                                                  0.1
                                              ? "${(subCatExpenses[i].amount / getSubTotal(subCatExpenses) * 100).round()}%"
                                              : "",
                                          color: palette[i]
                                              .toColor() /* subCatExpenses[i]
                                              .subCategory
                                              .color */
                                          ),
                                    ),
                                  ]),
                            )
                          : Center(
                              child:
                                  Text("No ${currentType.toLowerCase()} yet"),
                            ),
                    ),
                    Center(
                      child: Container(
                        width: 90,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              subTouchedIndex != -1
                                  ? subCatExpenses[subTouchedIndex]
                                      .subCategory
                                      .name
                                  : "",
                              style: TextStyle(
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              subTouchedIndex != -1
                                  ? "${(subCatExpenses[subTouchedIndex].amount / getSubTotal(subCatExpenses) * 100).round()}%"
                                  : "",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment(-1, 0),
                      child: GestureDetector(
                          onTap: () {
                            setState(() {
                              showSubCategory = false;
                              subTouchedIndex = -1;
                            });
                          },
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 36,
                          )),
                    ),
                  ],
                ),
              ),
              ListView(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [
                  ...List.generate(
                    subCatExpenses.length,
                    (i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              height: subTouchedIndex == i ? 18 : 15,
                              width: subTouchedIndex == i ? 18 : 15,
                              decoration: BoxDecoration(
                                  color: palette[i].toColor(),
                                  borderRadius: BorderRadius.circular(4)),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "${subCatExpenses[i].subCategory.name} (${symbolWriting(mainCurrProv.mainCurrency)} ${convertBackToMain(subCatExpenses[i].amount, mainCurrProv.mainCurrency).toStringAsFixed(1)})",
                              style: subTouchedIndex == i
                                  ? TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }
}

class CategoryExpense {
  final Category category;
  double amount;
  CategoryExpense({required this.category, required this.amount});
}

class SubCategoryExpense {
  final SubCategory subCategory;
  double amount;
  SubCategoryExpense({required this.subCategory, required this.amount});
}
