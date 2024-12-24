import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/formatters.dart';
import '../utils/objects.dart';
import '../utils/provider.dart';

class ChooseAccount extends StatelessWidget {
  final Account? secondaryAccount;
  const ChooseAccount({super.key, this.secondaryAccount});

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountsProvider>(context);
    List<Account> accountsToDisplay = accountProvider.accounts
        .where((element) => element != secondaryAccount)
        .toList();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        shape: Border(bottom: BorderSide(width: 1)),
        title: Text("Choose account"),
      ),
      body: ListView.builder(
        itemCount: accountsToDisplay.length,
        itemBuilder: (context, i) {
          List props = accountsToDisplay[i].color.split(" ").toList();
          Color color = Color.fromARGB(
            int.parse(props[0]),
            int.parse(props[1]),
            int.parse(props[2]),
            int.parse(props[3]),
          );
          return ListTile(
            key: ValueKey(accountsToDisplay[i].id),
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: color,
            ),
            title: Text(accountsToDisplay[i].name),
            subtitle: Text(accountsToDisplay[i].type),
            trailing: Text(
              "${symbolWriting(accountsToDisplay[i].currency)} ${thousandSeparator(accountsToDisplay[i].currentAmount.toStringAsFixed(2))}",
              style: TextStyle(fontWeight: FontWeight.w300),
            ),
            onTap: () {
              Navigator.pop(context, accountsToDisplay[i]);
            },
          );
        },
      ),
    );
  }
}
