import 'package:finances/const.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/app_data.dart';
import '../utils/formatters.dart';
import '../utils/objects.dart';
import '../utils/provider.dart';
import '../utils/user_preferences.dart';

class BalanceByCurrencies extends StatefulWidget {
  const BalanceByCurrencies({super.key});

  @override
  State<BalanceByCurrencies> createState() => _BalanceByCurrenciesState();
}

class _BalanceByCurrenciesState extends State<BalanceByCurrencies> {
  List<Color> colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.grey,
    Colors.indigo,
  ];

  double convertToUsd(double amount, String currency) {
    num rate =
        UserPreferences.getExchangeRates()!["conversion_rates"][currency] ?? 0;
    return amount / rate;
  }

  double getTotalBalance(
    List<Account> selectedAccounts,
    List<String> currencies,
  ) {
    double sumInUsd = 0;
    List<Account> accounts = [];
    for (var element in selectedAccounts) {
      if (currencies.contains(element.currency)) {
        accounts.add(element);
      }
    }
    for (var element in accounts) {
      if (!(convertToUsd(element.currentAmount, element.currency) < 0)) {
        sumInUsd += convertToUsd(element.currentAmount, element.currency);
      }
    }
    return sumInUsd;
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountsProvider>(context);
    final selectedAccountProv = Provider.of<SelectedAccounts>(context);
    List<Account> accountsToShow = accountProvider.accounts
        .where((element) => selectedAccountProv.indexes
            .contains(accountProvider.accounts.indexOf(element)))
        .toList();
    List<String> currencies = [];
    for (var element in accountsToShow) {
      if (!currencies.contains(element.currency)) {
        currencies.add(element.currency);
      }
    }
    List<String> currenciesToRemove = [];
    for (var element in currencies) {
      double sumOfSameCurrency = 0;
      for (var e in accountsToShow) {
        if (e.currency == element) {
          sumOfSameCurrency += e.currentAmount;
        }
      }
      if (sumOfSameCurrency <= 0) {
        currenciesToRemove.add(element);
      }
    }
    currencies.removeWhere((element) => currenciesToRemove.contains(element));
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
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Balance by currencies:",
              style: titleStyle,
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: 15)),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: SizedBox(
              height: 30,
              child: Row(
                  children: getTotalBalance(accountsToShow, currencies) > 0
                      ? List.generate(currencies.length, (i) {
                          double sumOfSameCurrency = 0;
                          for (var element in accountsToShow) {
                            if (element.currency == currencies[i]) {
                              sumOfSameCurrency += element.currentAmount;
                            }
                          }
                          double amountOfCurrencyInUS =
                              convertToUsd(sumOfSameCurrency, currencies[i]);
                          double totalValue =
                              getTotalBalance(accountsToShow, currencies);
                          if (amountOfCurrencyInUS < 0) {
                            amountOfCurrencyInUS = 0;
                          }
                          return Container(
                            height: 30,
                            width: (MediaQuery.of(context).size.width -
                                    (20 + 30 + 2)) *
                                amountOfCurrencyInUS /
                                totalValue,
                            color: colors[i % colors.length],
                            child: Center(
                              child: Text(
                                !(amountOfCurrencyInUS / totalValue < 1)
                                    ? "${(amountOfCurrencyInUS / totalValue * 100).round()}%"
                                    : "",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        })
                      : [
                          Container(
                            height: 30,
                            width: MediaQuery.of(context).size.width -
                                (20 + 30 + 2),
                            color: Colors.brown,
                            child: Center(
                              child: Text(
                                "Negative or null balance",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ]),
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: 10)),
          ListView(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              ...List.generate(currencies.length, (i) {
                double sumOfSameCurrency = 0;
                for (var element in accountsToShow) {
                  if (element.currency == currencies[i]) {
                    sumOfSameCurrency += element.currentAmount;
                  }
                }
                double amountOfCurrencyInUS =
                    convertToUsd(sumOfSameCurrency, currencies[i]);
                double totalValue = getTotalBalance(accountsToShow, currencies);
                if (amountOfCurrencyInUS < 0) {
                  amountOfCurrencyInUS = 0;
                }
                String percentage = !(amountOfCurrencyInUS <= 0)
                    ? ": ${(amountOfCurrencyInUS / totalValue * 100).round()}%"
                    : "";
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        height: 15,
                        width: 15,
                        decoration: BoxDecoration(
                            color: colors[i],
                            borderRadius: BorderRadius.circular(4)),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                          "${currencyNames[currencies[i]]}$percentage (${symbolWriting(currencies[i])} ${thousandSeparator(sumOfSameCurrency.toStringAsFixed(1))})"),
                    ],
                  ),
                );
              }),
              /* Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Container(
                      height: 15,
                      width: 15,
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4)),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text("Hong Kong Dollars (HK\$11,628.00)"),
                  ],
                ),
              ), */
            ],
          ),
        ],
      ),
    );
  }
}
