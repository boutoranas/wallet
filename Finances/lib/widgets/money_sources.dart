import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:finances/const.dart';
import 'package:finances/secondary_pages/create_account_page.dart';
import 'package:finances/utils/formatters.dart';
import 'package:finances/utils/objects.dart';
import 'package:finances/utils/user_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../secondary_pages/edit_money_sources.dart';
import '../utils/provider.dart';

class MoneySources extends StatefulWidget {
  final List<Account> accounts;
  const MoneySources({
    super.key,
    required this.accounts,
  });

  @override
  State<MoneySources> createState() => _MoneySourcesState();
}

class _MoneySourcesState extends State<MoneySources> {
  late List<int> selectedIndexes =
      List.generate(widget.accounts.length, (index) => index).toList();

  bool isHoldSelect = false;

  double convertToUsd(double amount, String currency) {
    num rate =
        UserPreferences.getExchangeRates()!["conversion_rates"][currency] ?? 0;
    return amount / rate;
  }

  String getTotalBalance(AccountsProvider accountsProvider,
      SelectedAccounts selectedAccountsProv, String defaultCurrency) {
    List<Account> selectedAccounts = [];
    for (var element in accountsProvider.accounts) {
      if (selectedAccountsProv.indexes
          .contains(accountsProvider.accounts.indexOf(element))) {
        selectedAccounts.add(element);
      }
    }
    double sum = 0;
    double sumInUsd = 0;
    for (var element in selectedAccounts) {
      sumInUsd += convertToUsd(element.currentAmount, element.currency);
    }
    num rate = UserPreferences.getExchangeRates()!["conversion_rates"]
        [defaultCurrency];
    sum = sumInUsd * rate;
    return thousandSeparator(sum.toStringAsFixed(2));
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountsProvider>(context);
    final selectedAccountProv = Provider.of<SelectedAccounts>(context);
    final mainCurrProv = Provider.of<MainCurrency>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    String defaultCurrency = mainCurrProv.defaultCurrency;
    print(selectedIndexes);
    accountProvider.addListener(() {
      selectedIndexes =
          List.generate(accountProvider.accounts.length, (index) => index)
              .toList();
      selectedAccountProv.changeSelectedIndexes(selectedIndexes);
      setState(() {
        isHoldSelect = false;
      });
    });

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndexes =
              List.generate(accountProvider.accounts.length, (index) => index)
                  .toList();
          selectedAccountProv.changeSelectedIndexes(selectedIndexes);
          isHoldSelect = false;
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
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Total balance:",
                style: titleStyle,
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 10)),
            Text(
              "${symbolWriting(defaultCurrency)} ${getTotalBalance(accountProvider, selectedAccountProv, defaultCurrency)}",
              style: getBigMoneyStyle(themeProvider, context),
            ),
            Padding(padding: EdgeInsets.only(bottom: 10)),
            Row(
              children: [
                Text(
                  "Sources:",
                  style: titleStyle,
                ),
                Spacer(),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditMoneySources(),
                        ));
                  },
                  icon: Icon(Icons.edit),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.only(bottom: 10)),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: accountProvider.accounts.length,
              itemBuilder: (context, i) {
                List props =
                    accountProvider.accounts[i].color.split(" ").toList();
                Color color = Color.fromARGB(
                  int.parse(props[0]),
                  int.parse(props[1]),
                  int.parse(props[2]),
                  int.parse(props[3]),
                );
                return Stack(
                  key: ValueKey(accountProvider.accounts[i].id),
                  alignment: Alignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: Material(
                        borderRadius: BorderRadius.circular(15),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {
                            setState(() {
                              isHoldSelect = false;
                              selectedIndexes = [i];
                              selectedAccountProv
                                  .changeSelectedIndexes(selectedIndexes);
                            });
                          },
                          onLongPress: () {
                            setState(() {
                              if (selectedIndexes.length <
                                  accountProvider.accounts.length) {
                                if (!selectedIndexes.contains(i)) {
                                  selectedIndexes.add(i);
                                }
                              } else {
                                selectedIndexes = [i];
                              }
                              selectedAccountProv
                                  .changeSelectedIndexes(selectedIndexes);
                              isHoldSelect = true;
                              if (selectedIndexes.length ==
                                  accountProvider.accounts.length) {
                                isHoldSelect = false;
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.symmetric(
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: selectedIndexes.contains(i)
                                  ? color
                                  : Colors.grey[400],
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(width: 1),
                            ),
                            child: InkWell(
                              child: Column(
                                children: [
                                  Text(
                                    accountProvider.accounts[i].name,
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                  Text(
                                    "${symbolWriting(accountProvider.accounts[i].currency)} ${thousandSeparator(accountProvider.accounts[i].currentAmount.toStringAsFixed(2))}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    isHoldSelect
                        ? Align(
                            alignment: Alignment(-1, 0),
                            child: SizedBox(
                              child: Checkbox(
                                value: selectedIndexes.contains(i),
                                onChanged: (value) {
                                  if (!selectedIndexes.contains(i)) {
                                    setState(() {
                                      selectedIndexes.add(i);
                                      selectedAccountProv.changeSelectedIndexes(
                                          selectedIndexes);
                                      if (selectedIndexes.length ==
                                          accountProvider.accounts.length) {
                                        isHoldSelect = false;
                                      }
                                    });
                                  } else {
                                    setState(() {
                                      selectedIndexes.remove(i);
                                      selectedAccountProv.changeSelectedIndexes(
                                          selectedIndexes);
                                      if (selectedIndexes.length == 1) {
                                        isHoldSelect = false;
                                      }
                                      if (selectedIndexes.isEmpty) {
                                        isHoldSelect = false;
                                        selectedIndexes = List.generate(
                                            accountProvider.accounts.length,
                                            (index) => index).toList();
                                        selectedAccountProv
                                            .changeSelectedIndexes(
                                                selectedIndexes);
                                      }
                                    });
                                  }
                                },
                              ),
                            ),
                          )
                        : Container(),
                  ],
                );
              },
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
                        builder: (context) => CreateAccountPage(
                          defaultCurrency: defaultCurrency,
                        ),
                      ));
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 6,
                    ),
                    Text('Add source'),
                    SizedBox(
                      width: 3,
                    ),
                    Icon(Icons.add),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
