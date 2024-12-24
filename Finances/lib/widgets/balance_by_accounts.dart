import 'package:finances/utils/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../const.dart';
import '../utils/formatters.dart';
import '../utils/objects.dart';
import '../utils/user_preferences.dart';

class BalanceByAccounts extends StatefulWidget {
  const BalanceByAccounts({super.key});

  @override
  State<BalanceByAccounts> createState() => _BalanceByAccountsState();
}

class _BalanceByAccountsState extends State<BalanceByAccounts> {
  double convertToUsd(double amount, String currency) {
    num rate =
        UserPreferences.getExchangeRates()!["conversion_rates"][currency] ?? 0;
    return amount / rate;
  }

  double getTotalBalance(
    List<Account> selectedAccounts,
  ) {
    double sumInUsd = 0;
    for (var element in selectedAccounts) {
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
              "Balance repartition:",
              style: titleStyle,
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: 15)),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: SizedBox(
              height: 30,
              child: Row(
                children: getTotalBalance(accountsToShow) > 0
                    ? List.generate(
                        accountsToShow.length,
                        (i) {
                          List props =
                              accountsToShow[i].color.split(" ").toList();
                          Color color = Color.fromARGB(
                            int.parse(props[0]),
                            int.parse(props[1]),
                            int.parse(props[2]),
                            int.parse(props[3]),
                          );
                          double accountValue = convertToUsd(
                              accountsToShow[i].currentAmount,
                              accountsToShow[i].currency);
                          double totalValue = getTotalBalance(accountsToShow);
                          if (accountValue < 0) {
                            accountValue = 0;
                          }
                          return Container(
                            key: ValueKey(accountsToShow[i].createdDate),
                            height: 30,
                            width: (MediaQuery.of(context).size.width -
                                    (20 + 30 + 2)) *
                                accountValue /
                                totalValue,
                            color: color,
                            child: Center(
                              child: Text(
                                !(accountValue / totalValue < 0.1)
                                    ? "${(accountValue / totalValue * 100).round()}%"
                                    : "",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : [
                        Container(
                          height: 30,
                          width:
                              MediaQuery.of(context).size.width - (20 + 30 + 2),
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
                      ],
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: 10)),
          ListView(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              ...List.generate(accountsToShow.length, (i) {
                List props = accountsToShow[i].color.split(" ").toList();
                Color color = Color.fromARGB(
                  int.parse(props[0]),
                  int.parse(props[1]),
                  int.parse(props[2]),
                  int.parse(props[3]),
                );
                double accountValue = convertToUsd(
                    accountsToShow[i].currentAmount,
                    accountsToShow[i].currency);
                double totalValue = getTotalBalance(accountsToShow);
                if (accountValue < 0) {
                  accountValue = 0;
                }
                String percentage = !(accountValue <= 0)
                    ? ": ${(accountValue / totalValue * 100).round()}%"
                    : "";
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        height: 15,
                        width: 15,
                        decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4)),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                          "${accountsToShow[i].name}$percentage (${symbolWriting(accountsToShow[i].currency)} ${thousandSeparator(accountsToShow[i].currentAmount.toStringAsFixed(1))})"),
                    ],
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
