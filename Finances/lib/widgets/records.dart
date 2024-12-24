import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:finances/secondary_pages/filter_page.dart';
import 'package:finances/secondary_pages/show_record.dart';
import 'package:finances/utils/app_data.dart';
import 'package:finances/utils/formatters.dart';
import 'package:finances/utils/objects.dart';
import 'package:finances/utils/user_preferences.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../const.dart';
import '../utils/provider.dart';

class Records extends StatefulWidget {
  const Records({super.key});

  @override
  State<Records> createState() => _RecordsState();
}

class _RecordsState extends State<Records> {
  checkForRepetition(Expense expense, ExpensesProvider expensesProvider) async {
    await Future.delayed(Duration(milliseconds: 50));
    if (expense.repetition != null) {
      if (expense.repetition!.period == "day") {
        for (var el in expense.repetition!.times) {
          if (dayOfDate(expense.date)
                  .add(Duration(hours: el.hour, minutes: el.minute))
                  .isAfter(expense.date) &&
              !dayOfDate(expense.date)
                  .add(Duration(hours: el.hour, minutes: el.minute))
                  .isAfter(DateTime.now())) {
            expensesProvider.modifyExpense(
              expense,
              Expense(
                id: expense.id,
                type: expense.type,
                category: expense.category,
                account: expense.account,
                date: expense.date,
                amount: expense.amount,
                fees: expense.fees,
                label: expense.label,
                repetition: null,
              ),
            );
            Expense newExpense = expensesProvider.createExpense(
              Expense(
                id: expense.id,
                type: expense.type,
                category: expense.category,
                account: expense.account,
                date: dayOfDate(expense.date)
                    .add(Duration(hours: el.hour, minutes: el.minute)),
                amount: expense.amount,
                fees: expense.fees,
                label: expense.label,
                repetition: expense.repetition,
              ),
            );
            checkForRepetition(newExpense, expensesProvider);
          }
        }
        TimeOfDay firstTime = expense.repetition!.times[0];
        if (dayOfDate(expense.date)
            .add(Duration(
              days: expense.repetition!.frequency,
              hours: firstTime.hour,
              minutes: firstTime.minute,
            ))
            .isBefore(DateTime.now())) {
          expensesProvider.modifyExpense(
            expense,
            Expense(
              id: expense.id,
              type: expense.type,
              category: expense.category,
              account: expense.account,
              date: expense.date,
              amount: expense.amount,
              fees: expense.fees,
              label: expense.label,
              repetition: null,
            ),
          );
          Expense newExpense = expensesProvider.createExpense(
            Expense(
              id: expense.id,
              type: expense.type,
              category: expense.category,
              account: expense.account,
              date: dayOfDate(expense.date).add(Duration(
                  days: expense.repetition!.frequency,
                  hours: firstTime.hour,
                  minutes: firstTime.minute)),
              amount: expense.amount,
              fees: expense.fees,
              label: expense.label,
              repetition: expense.repetition,
            ),
          );
          checkForRepetition(newExpense, expensesProvider);
        } else {
          return;
        }
      } else if (expense.repetition!.period == "week") {
        for (var el in expense.repetition!.times) {
          if (weekOfDate(expense.date)
                  .add(Duration(days: el))
                  .isAfter(expense.date) &&
              !weekOfDate(expense.date)
                  .add(Duration(days: el))
                  .isAfter(DateTime.now())) {
            expensesProvider.modifyExpense(
              expense,
              Expense(
                id: expense.id,
                type: expense.type,
                category: expense.category,
                account: expense.account,
                date: expense.date,
                amount: expense.amount,
                fees: expense.fees,
                label: expense.label,
                repetition: null,
              ),
            );
            Expense newExpense = expensesProvider.createExpense(
              Expense(
                id: expense.id,
                type: expense.type,
                category: expense.category,
                account: expense.account,
                date: weekOfDate(expense.date).add(Duration(days: el)),
                amount: expense.amount,
                fees: expense.fees,
                label: expense.label,
                repetition: expense.repetition,
              ),
            );
            checkForRepetition(newExpense, expensesProvider);
          }
        }
        int firstDay = expense.repetition!.times[0];
        if (weekOfDate(expense.date)
            .add(Duration(days: 7 * expense.repetition!.frequency + firstDay))
            .isBefore(DateTime.now())) {
          expensesProvider.modifyExpense(
            expense,
            Expense(
              id: expense.id,
              type: expense.type,
              category: expense.category,
              account: expense.account,
              date: expense.date,
              amount: expense.amount,
              fees: expense.fees,
              label: expense.label,
              repetition: null,
            ),
          );
          Expense newExpense = expensesProvider.createExpense(
            Expense(
              id: expense.id,
              type: expense.type,
              category: expense.category,
              account: expense.account,
              date: weekOfDate(expense.date).add(Duration(
                days: 7 * expense.repetition!.frequency + firstDay,
              )),
              amount: expense.amount,
              fees: expense.fees,
              label: expense.label,
              repetition: expense.repetition,
            ),
          );
          checkForRepetition(newExpense, expensesProvider);
        } else {
          return;
        }
      } else if (expense.repetition!.period == "month") {
        for (var el in expense.repetition!.times) {
          //last day
          if (el == 32) {
            if (DateTime(expense.date.year, expense.date.month + 1, 0)
                    .isAfter(expense.date) &&
                !DateTime(expense.date.year, expense.date.month + 1, 0)
                    .isAfter(DateTime.now())) {
              expensesProvider.modifyExpense(
                expense,
                Expense(
                  id: expense.id,
                  type: expense.type,
                  category: expense.category,
                  account: expense.account,
                  date: expense.date,
                  amount: expense.amount,
                  fees: expense.fees,
                  label: expense.label,
                  repetition: null,
                ),
              );
              Expense newExpense = expensesProvider.createExpense(
                Expense(
                  id: expense.id,
                  type: expense.type,
                  category: expense.category,
                  account: expense.account,
                  date: DateTime(expense.date.year, expense.date.month + 1, 0),
                  amount: expense.amount,
                  fees: expense.fees,
                  label: expense.label,
                  repetition: expense.repetition,
                ),
              );
              checkForRepetition(newExpense, expensesProvider);
            }
          }
          //other days
          else {
            if (monthOfDate(expense.date).add(Duration(days: el - 1)).day ==
                el) {
              if (monthOfDate(expense.date)
                      .add(Duration(days: el - 1))
                      .isAfter(expense.date) &&
                  !monthOfDate(expense.date)
                      .add(Duration(days: el - 1))
                      .isAfter(DateTime.now())) {
                expensesProvider.modifyExpense(
                  expense,
                  Expense(
                    id: expense.id,
                    type: expense.type,
                    category: expense.category,
                    account: expense.account,
                    date: expense.date,
                    amount: expense.amount,
                    fees: expense.fees,
                    label: expense.label,
                    repetition: null,
                  ),
                );
                Expense newExpense = expensesProvider.createExpense(
                  Expense(
                    id: expense.id,
                    type: expense.type,
                    category: expense.category,
                    account: expense.account,
                    date: monthOfDate(expense.date).add(Duration(days: el - 1)),
                    amount: expense.amount,
                    fees: expense.fees,
                    label: expense.label,
                    repetition: expense.repetition,
                  ),
                );
                checkForRepetition(newExpense, expensesProvider);
              }
            } else {}
          }
        }
        //DateTime(expense.date.year, expense.date.month + 1, 0)
        int firstDay = expense.repetition!.times[0];
        if (DateTime(
                        expense.date.year,
                        expense.date.month + expense.repetition!.frequency,
                        firstDay)
                    .day ==
                firstDay ||
            firstDay == 32) {
          if (DateTime(expense.date.year,
                  expense.date.month + expense.repetition!.frequency, firstDay)
              .isBefore(DateTime.now())) {
            expensesProvider.modifyExpense(
              expense,
              Expense(
                id: expense.id,
                type: expense.type,
                category: expense.category,
                account: expense.account,
                date: expense.date,
                amount: expense.amount,
                fees: expense.fees,
                label: expense.label,
                repetition: null,
              ),
            );
            Expense newExpense = expensesProvider.createExpense(
              Expense(
                id: expense.id,
                type: expense.type,
                category: expense.category,
                account: expense.account,
                date: firstDay != 32
                    ? DateTime(expense.date.year,
                            expense.date.month + expense.repetition!.frequency)
                        .add(Duration(days: firstDay - 1))
                    : DateTime(
                        expense.date.year,
                        expense.date.month + expense.repetition!.frequency + 1,
                        0),
                amount: expense.amount,
                fees: expense.fees,
                label: expense.label,
                repetition: expense.repetition,
              ),
            );
            checkForRepetition(newExpense, expensesProvider);
          } else {
            return;
          }
        } else {
          if (DateTime(
            expense.date.year,
            expense.date.month + expense.repetition!.frequency * 2,
            firstDay,
          ).isBefore(DateTime.now())) {
            expensesProvider.modifyExpense(
              expense,
              Expense(
                id: expense.id,
                type: expense.type,
                category: expense.category,
                account: expense.account,
                date: expense.date,
                amount: expense.amount,
                fees: expense.fees,
                label: expense.label,
                repetition: null,
              ),
            );
            Expense newExpense = expensesProvider.createExpense(
              Expense(
                id: expense.id,
                type: expense.type,
                category: expense.category,
                account: expense.account,
                date: DateTime(
                    expense.date.year,
                    expense.date.month + expense.repetition!.frequency * 2,
                    firstDay),
                amount: expense.amount,
                fees: expense.fees,
                label: expense.label,
                repetition: expense.repetition,
              ),
            );
            checkForRepetition(newExpense, expensesProvider);
          } else {
            return;
          }
        }
      } else if (expense.repetition!.period == "year") {
        for (var el in expense.repetition!.times) {
          if (DateTime(expense.date.year, el).isAfter(expense.date) &&
              !DateTime(expense.date.year, el).isAfter(DateTime.now())) {
            expensesProvider.modifyExpense(
              expense,
              Expense(
                id: expense.id,
                type: expense.type,
                category: expense.category,
                account: expense.account,
                date: expense.date,
                amount: expense.amount,
                fees: expense.fees,
                label: expense.label,
                repetition: null,
              ),
            );
            Expense newExpense = expensesProvider.createExpense(
              Expense(
                id: expense.id,
                type: expense.type,
                category: expense.category,
                account: expense.account,
                date: DateTime(expense.date.year, el),
                amount: expense.amount,
                fees: expense.fees,
                label: expense.label,
                repetition: expense.repetition,
              ),
            );
            checkForRepetition(newExpense, expensesProvider);
          }
        }
        int firstMonth = expense.repetition!.times[0];
        if (DateTime(
                expense.date.year + expense.repetition!.frequency, firstMonth)
            .isBefore(DateTime.now())) {
          expensesProvider.modifyExpense(
            expense,
            Expense(
              id: expense.id,
              type: expense.type,
              category: expense.category,
              account: expense.account,
              date: expense.date,
              amount: expense.amount,
              fees: expense.fees,
              label: expense.label,
              repetition: null,
            ),
          );
          Expense newExpense = expensesProvider.createExpense(
            Expense(
              id: expense.id,
              type: expense.type,
              category: expense.category,
              account: expense.account,
              date: DateTime(expense.date.year + expense.repetition!.frequency,
                  firstMonth),
              amount: expense.amount,
              fees: expense.fees,
              label: expense.label,
              repetition: expense.repetition,
            ),
          );
          checkForRepetition(newExpense, expensesProvider);
        } else {
          return;
        }
      }
    } else {
      return;
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
      checkForRepetition(element, expensesProvider);
    }
    for (var element in expensesProvider.expenses) {
      if ((currentType == "All" ||
              element.type == getCurrentType(currentType)) &&
          (!element.date.isBefore(getPeriodMin(currentPeriod)) &&
              !(element.date).isAfter((DateTime.now()))) &&
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

  updateAccounts(AccountsProvider accountsProvider,
      ExpensesProvider expensesProvider) async {
    await Future.delayed(Duration(milliseconds: 50));
    List<double> amountAtFirst = [];
    for (var account in accountsProvider.accounts) {
      amountAtFirst.add(account.currentAmount);
      account.currentAmount = account.initialAmount;
    }
    for (var account in accountsProvider.accounts) {
      for (var expense in expensesProvider.expenses) {
        if (expense.account.id == account.id &&
            expense.date.isBefore(DateTime.now())) {
          if (expense.type == "Expense") {
            account.currentAmount -= expense.amount;
          } else if (expense.type == "Income") {
            account.currentAmount += expense.amount;
          } else if (expense.type == "Transfer") {
            account.currentAmount -= expense.amount;
            if (accountsProvider.accounts
                .where((element) => element.id == expense.category)
                .toList()
                .isNotEmpty) {
              accountsProvider.accounts.where((element) => element.id == expense.category).toList()[0].currentAmount +=
                  convertedAmount(
                        expense.amount,
                        expense.account.currency,
                        accountsProvider.accounts
                            .where((element) => element.id == expense.category)
                            .toList()[0]
                            .currency,
                      ) *
                      (expense.fees != null ? 1 - expense.fees! / 100 : 1);
            }
          }
        }
      }
    }
    for (var account in accountsProvider.accounts) {
      //double amountAtFirst = account.currentAmount;
      if (amountAtFirst[accountsProvider.accounts.indexOf(account)] !=
          account.currentAmount) {
        accountsProvider.modifyAccount(account, account);
      }
    }
  }

  checkForAccountDeletion(AccountsProvider accountsProvider,
      ExpensesProvider expensesProvider) async {
    await Future.delayed(Duration(milliseconds: 50));
    for (var expense in expensesProvider.expenses) {
      bool accountExisting = false;
      for (var account in accountsProvider.accounts) {
        if (expense.account.id == account.id) {
          accountExisting = true;
        }
      }
      if (accountExisting == false) {
        expensesProvider.deleteExpense(expense);
      }
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

  late Timer timer;

  String currentPeriod = UserPreferences.getFilters()["records list"] != null
      ? UserPreferences.getFilters()["records list"]["period"]
      : "This month";
  String currentType = UserPreferences.getFilters()["records list"] != null
      ? UserPreferences.getFilters()["records list"]["type"]
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
    checkForAccountDeletion(accountsProv, expensesProvider);
    updateAccounts(accountsProv, expensesProvider);
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
                "Records list:",
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
          Padding(padding: EdgeInsets.only(bottom: 8)),
          Align(
            child: Text("$currentPeriod, ${currentType.toLowerCase()}"),
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
                    builder: (context) => ShowExpenses(
                      currentType: currentType,
                      currentPeriod: currentPeriod,
                      selectedAccounts: accountsProv.accounts
                          .where((element) => selectedIndexesProv.indexes
                              .contains(accountsProv.accounts.indexOf(element)))
                          .toList(),
                    ),
                  )).then((value) {
                if (value != null) {
                  setState(() {
                    currentPeriod = value["period"];
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
