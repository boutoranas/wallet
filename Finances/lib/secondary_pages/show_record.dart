import 'dart:convert';

import 'package:finances/secondary_pages/edit_expense.dart';
import 'package:finances/utils/provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../utils/app_data.dart';
import '../utils/formatters.dart';
import '../utils/objects.dart';
import '../utils/user_preferences.dart';
import 'filter_page.dart';

class ShowExpenses extends StatefulWidget {
  final String currentType;
  final String currentPeriod;
  final List<Account> selectedAccounts;
  const ShowExpenses(
      {super.key,
      required this.currentType,
      required this.currentPeriod,
      required this.selectedAccounts});

  @override
  State<ShowExpenses> createState() => _ShowExpensesState();
}

class _ShowExpensesState extends State<ShowExpenses> {
  late String currentPeriod = widget.currentPeriod;
  late String currentType = widget.currentType;

  List<Expense> getExpenses(
      ExpensesProvider expensesProvider, AccountsProvider accountsProvider) {
    List<Expense> e = [];
    for (var element in expensesProvider.expenses) {
      if ((currentType == "All" ||
              element.type == getCurrentType(currentType)) &&
          (!element.date.isBefore(getPeriodMin(currentPeriod)) &&
              !(element.date).isAfter((DateTime.now()))) &&
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
            "period": currentPeriod,
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
                  Text("$currentPeriod, ${currentType.toLowerCase()}"),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (context) => FilterPage(
                          filters: [
                            "period",
                            'type',
                          ],
                          currentPeriod: currentPeriod,
                          currentType: currentType,
                        ),
                      ).then((value) {
                        if (value != null) {
                          setState(() {
                            currentPeriod = value["period"];
                            currentType = value["type"];
                            Map map = UserPreferences.getFilters();
                            if (map["records list"] != null &&
                                map["records list"].containsKey("period")) {
                              map["records list"].remove("period");
                            }
                            if (map["records list"] != null &&
                                map["records list"].containsKey("type")) {
                              map["records list"].remove("type");
                            }
                            map.addAll({
                              "records list": {
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
              Divider(),
              expenses.isNotEmpty
                  ? Column(
                      children: [
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
                                                expensesProvider: expensesProv,
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
                                                        expenses[i].category ||
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
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  expenses[i].type != "Transfer"
                                      ? expenses[i].account.name
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
                      ],
                    )
                  : Center(child: Text("Nothing to show here")),
            ],
          ),
        ),
      ),
    );
  }
}
