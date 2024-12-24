import 'dart:async';
import 'dart:convert';

import 'package:finances/secondary_pages/show_future_records.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../const.dart';
import '../secondary_pages/filter_page.dart';
import '../secondary_pages/show_record.dart';
import '../utils/app_data.dart';
import '../utils/formatters.dart';
import '../utils/objects.dart';
import '../utils/provider.dart';
import '../utils/user_preferences.dart';

class FutureExpenses extends StatefulWidget {
  const FutureExpenses({super.key});

  @override
  State<FutureExpenses> createState() => _FutureExpensesState();
}

class _FutureExpensesState extends State<FutureExpenses> {
  List<Expense> getExpenses(ExpensesProvider expensesProvider,
      SelectedAccounts selectedIndexesProv, AccountsProvider accountsProvider) {
    List<Account> selectedAccounts = accountsProvider.accounts
        .where((element) => selectedIndexesProv.indexes
            .contains(accountsProvider.accounts.indexOf(element)))
        .toList();
    List<Expense> e = [];
    for (var element in expensesProvider.expenses) {
      if ((currentType == "All" ||
              element.type == getCurrentType(currentType)) &&
          (!(element.date).isBefore((DateTime.now()))) &&
          isAccountInList(selectedAccounts, element)) {
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
    for (var element in accountsList) {
      if (element.id == expense.category) {
        return true;
      }
    }
    return false;
  }

  List<Expense> getLimitedList(List<Expense> expenses) {
    return expenses.sublist(0, expenses.length > 5 ? 5 : expenses.length);
  }

  String getCurrentType(String type) {
    switch (type) {
      case "Expenses only":
        return "Expense";
      case "Income only":
        return "Income";
      case "Transfer only":
        return "Transfer";
      default:
        return "All";
    }
  }

  double convertedAmount(
    double amount,
    String firstCurrency,
    String secondCurrency,
  ) {
    num firstRate =
        UserPreferences.getExchangeRates()!["conversion_rates"][firstCurrency];
    num secondRate =
        UserPreferences.getExchangeRates()!["conversion_rates"][secondCurrency];
    return amount / firstRate * secondRate;
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

  late Timer timer;

  String currentType =
      UserPreferences.getFilters()["future records list"] != null
          ? UserPreferences.getFilters()["future records list"]["type"]
          : "All";

  @override
  void initState() {
    timer = Timer.periodic(Duration(seconds: 30), (timer) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expensesProvider = Provider.of<ExpensesProvider>(context);
    final selectedIndexesProv = Provider.of<SelectedAccounts>(context);
    final accountsProv = Provider.of<AccountsProvider>(context);
    List<Expense> expenses =
        getExpenses(expensesProvider, selectedIndexesProv, accountsProv);
    List<Expense> limitedExpenses = getLimitedList(expenses);
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
        children: [
          Row(
            children: [
              Text(
                "Upcoming records list:",
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
                        'type',
                      ],
                      currentPeriod: "",
                      currentType: currentType,
                    ),
                  ).then((value) {
                    if (value != null) {
                      setState(() {
                        currentType = value["type"];
                        Map map = UserPreferences.getFilters();
                        if (map["future records list"] != null &&
                            map["future records list"].containsKey("type")) {
                          map["future records list"].remove("type");
                        }
                        map.addAll({
                          "future records list": {
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
            child: Text("${currentType}"),
            alignment: Alignment.centerLeft,
          ),
          Padding(padding: EdgeInsets.only(bottom: 10)),
          ListView(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: expenses.isNotEmpty
                ? [
                    ...List.generate(limitedExpenses.length, (i) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: limitedExpenses[i].type !=
                                      "Transfer"
                                  ? subcategories
                                      .where((element) =>
                                          element.name ==
                                              limitedExpenses[i].category ||
                                          element.category.name ==
                                              limitedExpenses[i].category)
                                      .toList()[0]
                                      .color
                                  : getColorFromString(
                                      limitedExpenses[i].account.color),
                              child: Container(
                                child: limitedExpenses[i].type != "Transfer"
                                    ? Icon(
                                        subcategories
                                            .where((element) =>
                                                element.name ==
                                                    limitedExpenses[i]
                                                        .category ||
                                                element.category.name ==
                                                    limitedExpenses[i].category)
                                            .toList()[0]
                                            .iconData,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                            title: Text(
                              limitedExpenses[i].type != "Transfer"
                                  ? limitedExpenses[i].category
                                  : "${limitedExpenses[i].account.name} → ${accountsProv.accounts.where((element) => element.id == limitedExpenses[i].category).toList().isNotEmpty ? accountsProv.accounts.where((element) => element.id == limitedExpenses[i].category).toList()[0].name : "Unknown"}",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              limitedExpenses[i].type != "Transfer"
                                  ? limitedExpenses[i].account.name
                                  : "",
                              style: TextStyle(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${limitedExpenses[i].type == "Expense" ? "- " : (limitedExpenses[i].type == "Income" ? "+ " : "")}${symbolWriting(limitedExpenses[i].account.currency)} ${thousandSeparator(limitedExpenses[i].amount.toStringAsFixed(1))}",
                                  style: TextStyle(
                                    color: limitedExpenses[i].type == "Expense"
                                        ? Colors.red
                                        : (limitedExpenses[i].type == "Income"
                                            ? Colors.green
                                            : Colors.blue),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                limitedExpenses[i].fees != null &&
                                        limitedExpenses[i].fees != 0
                                    ? Text(
                                        limitedExpenses[i].fees!.sign == 1
                                            ? "-${limitedExpenses[i].fees}% fees"
                                            : "+${limitedExpenses[i].fees!.abs()}% bonus",
                                        style: limitedExpenses[i].fees!.sign ==
                                                1
                                            ? TextStyle(color: Colors.red)
                                            : TextStyle(color: Colors.green),
                                      )
                                    : Container(
                                        height: 0,
                                        width: 0,
                                      ),
                                Text(
                                    "${dateFormatter(limitedExpenses[i].date)}${dateFormatter(limitedExpenses[i].date) == "Today" ? " ${DateFormat("HH:mm").format(limitedExpenses[i].date)}" : ""}"),
                              ],
                            ),
                          ),
                          Divider(
                            height: 5,
                            thickness: 0.7,
                          ),
                        ],
                      );
                    })
                  ]
                : [
                    Center(child: Text("Nothing to show here")),
                  ],
          ),
          TextButton(
            style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            )),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShowFutureExpenses(
                      currentType: currentType,
                      selectedAccounts: accountsProv.accounts
                          .where((element) => selectedIndexesProv.indexes
                              .contains(accountsProv.accounts.indexOf(element)))
                          .toList(),
                    ),
                  )).then((value) {
                if (value != null) {
                  setState(() {
                    currentType = value["type"];
                  });
                }
              });
            },
            child: Text("Show more"),
          ),
        ],
      ),
    );
  }
}
