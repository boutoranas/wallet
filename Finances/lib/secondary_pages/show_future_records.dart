import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../utils/app_data.dart';
import '../utils/formatters.dart';
import '../utils/objects.dart';
import '../utils/provider.dart';
import '../utils/user_preferences.dart';
import 'edit_expense.dart';
import 'filter_page.dart';

class ShowFutureExpenses extends StatefulWidget {
  final String currentType;
  final List<Account> selectedAccounts;
  const ShowFutureExpenses(
      {super.key, required this.currentType, required this.selectedAccounts});

  @override
  State<ShowFutureExpenses> createState() => _ShowFutureExpensesState();
}

class _ShowFutureExpensesState extends State<ShowFutureExpenses> {
  late String currentType = widget.currentType;

  List<Expense> getExpenses(
      ExpensesProvider expensesProvider, AccountsProvider accountsProvider) {
    List<Expense> e = [];
    for (var element in expensesProvider.expenses) {
      if ((currentType == "All" ||
              element.type == getCurrentType(currentType)) &&
          (!(element.date).isBefore((DateTime.now()))) &&
          isAccountInList(widget.selectedAccounts, element)) {
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

  @override
  Widget build(BuildContext context) {
    final expensesProv = Provider.of<ExpensesProvider>(context);
    final accountProv = Provider.of<AccountsProvider>(context);
    List<Expense> expenses = getExpenses(expensesProv, accountProv);
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(
          context,
          {
            "type": currentType,
          },
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          shape: Border(bottom: BorderSide(width: 1)),
          title: Text("View record"),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: ListView(
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              children: [
                Padding(padding: EdgeInsets.only(bottom: 10)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${currentType}"),
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
                                  map["future records list"]
                                      .containsKey("type")) {
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
                Divider(),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: expenses.isNotEmpty
                      ? [
                          ...List.generate(expenses.length, (i) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => EditExpense(
                                                  expense: expenses[i],
                                                  accountsProvider: accountProv,
                                                  expensesProvider:
                                                      expensesProv,
                                                )));
                                  },
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        expenses[i].type != "Transfer"
                                            ? subcategories
                                                .where((element) =>
                                                    element.name ==
                                                        expenses[i].category ||
                                                    element.category.name ==
                                                        expenses[i].category)
                                                .toList()[0]
                                                .color
                                            : getColorFromString(
                                                expenses[i].account.color),
                                    child: Container(
                                      child: expenses[i].type != "Transfer"
                                          ? Icon(
                                              subcategories
                                                  .where((element) =>
                                                      element.name ==
                                                          expenses[i]
                                                              .category ||
                                                      element.category.name ==
                                                          expenses[i].category)
                                                  .toList()[0]
                                                  .iconData,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                  ),
                                  title: Text(
                                    expenses[i].type != "Transfer"
                                        ? expenses[i].category
                                        : "${expenses[i].account.name} → ${accountProv.accounts.where((element) => element.id == expenses[i].category).toList().isNotEmpty ? accountProv.accounts.where((element) => element.id == expenses[i].category).toList()[0].name : "Unknown"}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    expenses[i].type != "Transfer"
                                        ? expenses[i].account.name
                                        : "",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "${expenses[i].type == "Expense" ? "- " : (expenses[i].type == "Income" ? "+ " : "")}${symbolWriting(expenses[i].account.currency)} ${thousandSeparator(expenses[i].amount.toStringAsFixed(1))}",
                                        style: TextStyle(
                                          color: expenses[i].type == "Expense"
                                              ? Colors.red
                                              : (expenses[i].type == "Income"
                                                  ? Colors.green
                                                  : Colors.blue),
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      expenses[i].fees != null &&
                                              expenses[i].fees != 0
                                          ? Text(
                                              expenses[i].fees!.sign == 1
                                                  ? "-${expenses[i].fees}% fees"
                                                  : "+${expenses[i].fees!.abs()}% bonus",
                                              style: expenses[i].fees!.sign == 1
                                                  ? TextStyle(color: Colors.red)
                                                  : TextStyle(
                                                      color: Colors.green),
                                            )
                                          : Container(
                                              height: 0,
                                              width: 0,
                                            ),
                                      Text(
                                          "${dateFormatter(expenses[i].date)} ${DateFormat("HH:mm").format(expenses[i].date)}") //${dateFormatter(expenses[i].date) == "Today" ? " ${DateFormat("HH:mm").format(expenses[i].date)}" : ""}"),
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
                          Text("Nothing to show here"),
                        ],
                )
              ]),
        ),
      ),
    );
  }
}
