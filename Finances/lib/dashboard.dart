import 'package:circular_clip_route/circular_clip_route.dart';
import 'package:finances/secondary_pages/add_record_page.dart';
import 'package:finances/utils/app_data.dart';
import 'package:finances/utils/objects.dart';
import 'package:finances/utils/provider.dart';
import 'package:finances/widgets/balance_by_accounts.dart';
import 'package:finances/widgets/balance_by_currencies.dart';
import 'package:finances/widgets/balance_trend.dart';
import 'package:finances/widgets/cash_flow_trend.dart';
import 'package:finances/widgets/expenses_structure.dart';
import 'package:finances/widgets/expenses_trend.dart';
import 'package:finances/widgets/future_expenses.dart';
import 'package:finances/widgets/money_sources.dart';
import 'package:finances/widgets/budget.dart';
import 'package:finances/widgets/records.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'other_pages/settings.dart';
import 'utils/user_preferences.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    UserPreferences.getExchangeRates()!["conversion_rates"]
        .forEach((key, value) {
      Data.currenciesList.add(
        Currency(name: key, rate: value, fullName: currencyNames[key]),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountsProvider>(context);
    final expenseProv = Provider.of<ExpensesProvider>(context);
    print(expenseProv.expenses.length);
    return Scaffold(
      floatingActionButton:
          accountProvider.accounts.isNotEmpty ? FloatingAccButton() : null,
      appBar: AppBar(
        title: Text("Dashboard"),
        actions: [
          IconButton(
              tooltip: 'Settings',
              padding: const EdgeInsets.all(5),
              constraints: const BoxConstraints(),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Settings(),
                    ));
              },
              icon: const Icon(Icons.settings)),
          SizedBox(
            width: 5,
          )
        ],
        elevation: 0,
        shape: Border(bottom: BorderSide(width: 1)),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Padding(padding: EdgeInsets.only(bottom: 15)),
              MoneySources(
                accounts: accountProvider.accounts,
              ),
              accountProvider.accounts.isNotEmpty
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(padding: EdgeInsets.only(bottom: 15)),
                        BalanceByAccounts(),
                        Padding(padding: EdgeInsets.only(bottom: 15)),
                        Records(),
                        Padding(padding: EdgeInsets.only(bottom: 15)),
                        FutureExpenses(),
                        Padding(padding: EdgeInsets.only(bottom: 15)),
                        Budget(),
                        Padding(padding: EdgeInsets.only(bottom: 15)),
                        ExpensesStructure(),
                        Padding(padding: EdgeInsets.only(bottom: 15)),
                        BalanceTrend(),
                        Padding(padding: EdgeInsets.only(bottom: 15)),
                        ExpensesTrend(),
                        Padding(padding: EdgeInsets.only(bottom: 15)),
                        BalanceByCurrencies(),
                        Padding(padding: EdgeInsets.only(bottom: 15)),
                      ],
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}

class FloatingAccButton extends StatelessWidget {
  const FloatingAccButton({super.key});

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountsProvider>(context);
    final selectedAccountsProv = Provider.of<SelectedAccounts>(context);
    Account? accountToSelect;
    if (selectedAccountsProv.selectedIndexes.length == 1) {
      accountToSelect = accountProvider.accounts
          .elementAt(selectedAccountsProv.selectedIndexes[0]);
    }
    Account? secondaryAccount;
    if (accountProvider.accounts.length != 1) {
      secondaryAccount = accountProvider.accounts
          .where((element) {
            if (accountToSelect != null) {
              return element != accountToSelect;
            } else {
              return element != accountProvider.accounts[0];
            }
          })
          .toList()
          .first;
    } else {
      secondaryAccount = null;
    }
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddRecord(
                accountToSelect: accountToSelect ?? accountProvider.accounts[0],
                secondaryAccount: secondaryAccount,
              ),
            ));
      },
      child: Icon(Icons.add),
    );
  }
}
