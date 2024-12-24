import 'package:finances/utils/app_data.dart';
import 'package:finances/utils/important_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../utils/formatters.dart';
import '../utils/objects.dart';
import '../utils/provider.dart';
import 'choose_account_type.dart';
import 'choose_color.dart';

class EditMoneySources extends StatefulWidget {
  const EditMoneySources({super.key});

  @override
  State<EditMoneySources> createState() => _EditMoneySourcesState();
}

class _EditMoneySourcesState extends State<EditMoneySources> {
  saveModifications(
      AccountsProvider accountsProvider,
      ExpensesProvider expensesProvider,
      Account account,
      String newName,
      String newType,
      String newColor,
      double newAmount) {
    accountsProvider.modifyAccount(
      account,
      Account(
        id: account.id,
        name: newName,
        type: newType,
        currency: account.currency,
        initialAmount: account.initialAmount,
        createdDate: account.createdDate,
        color: newColor,
        currentAmount: account.currentAmount,
      ),
    );
    if ((account.currentAmount - newAmount).abs() >= 0.01) {
      expensesProvider.createExpense(
        Expense(
          id: Uuid().v1(),
          type: (newAmount - account.currentAmount).sign == 1.0
              ? "Income"
              : "Expense",
          category: "Missing",
          account: account,
          date: DateTime.now(),
          amount: (newAmount - account.currentAmount).abs(),
        ),
      );
    } else {
      print("nope");
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountsProvider>(context);
    final selectedAccountProv = Provider.of<SelectedAccounts>(context);
    final expensesProvider = Provider.of<ExpensesProvider>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        shape: Border(bottom: BorderSide(width: 1)),
        title: Text("Edit sources"),
      ),
      body: ReorderableListView.builder(
        physics: BouncingScrollPhysics(),
        onReorder: (oldI, newI) {
          if (oldI < newI) {
            newI--;
          }
          List<Account> accounts = accountProvider.accounts;

          final account = accounts.removeAt(oldI);

          accounts.insert(newI, account);

          accountProvider.modifyAccount(account, account);

          List<int> selectedIndexes;

          selectedIndexes =
              List.generate(accountProvider.accounts.length, (index) => index)
                  .toList();
          selectedAccountProv.changeSelectedIndexes(selectedIndexes);
        },
        itemCount: accountProvider.accounts.length,
        itemBuilder: (context, i) {
          List props = accountProvider.accounts[i].color.split(" ").toList();
          Color color = Color.fromARGB(
            int.parse(props[0]),
            int.parse(props[1]),
            int.parse(props[2]),
            int.parse(props[3]),
          );
          return ListTile(
            key: ValueKey(accountProvider.accounts[i].id),
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: color,
            ),
            title: Text(accountProvider.accounts[i].name),
            subtitle: Text(accountProvider.accounts[i].type),
            trailing: const IconButton(
              onPressed: null,
              icon: Icon(Icons.menu),
            ),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    TextEditingController nameController =
                        TextEditingController();
                    TextEditingController typeController =
                        TextEditingController();
                    TextEditingController currentAmountInputController =
                        TextEditingController();
                    nameController.value = nameController.value
                        .copyWith(text: accountProvider.accounts[i].name);
                    typeController.value = typeController.value
                        .copyWith(text: accountProvider.accounts[i].type);
                    currentAmountInputController.value =
                        currentAmountInputController.value.copyWith(
                            text: thousandSeparator(accountProvider
                                .accounts[i].currentAmount
                                .toStringAsFixed(2)));
                    Color accountColor = color;
                    return AlertDialog(
                      title: Text("Edit source:"),
                      content: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            inputData(
                              label: "name",
                              text: true,
                              controller: nameController,
                            ),
                            Padding(padding: EdgeInsets.only(bottom: 10)),
                            inputData(
                              controller: currentAmountInputController,
                              label: "Adjust current value",
                              text: true,
                              suffix: Text(symbolWriting(
                                  accountProvider.accounts[i].currency)),
                              keyBoardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(
                                    r'(([1-9][0-9]*((,)[0-9]{3})*|0)|\.{0}^)((\.[0-9]+)|\.)?')),
                                ThousandsSeparatorInputFormatter(),
                                //FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                              ],
                            ),
                            Padding(padding: EdgeInsets.only(bottom: 10)),
                            inputData(
                              onTap: () async {
                                await Navigator.of(context, rootNavigator: true)
                                    .push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        ChooseAccountType(),
                                  ),
                                )
                                    .then((value) async {
                                  setState(() {
                                    if (value != null) {
                                      typeController.value = typeController
                                          .value
                                          .copyWith(text: value);
                                    }
                                  });
                                });
                              },
                              label: "type",
                              text: false,
                              controller: typeController,
                            ),
                            Padding(padding: EdgeInsets.only(bottom: 10)),
                            StatefulBuilder(
                              builder: (context, setState) {
                                return inputData(
                                  onTap: () async {
                                    await Navigator.of(context,
                                            rootNavigator: true)
                                        .push(
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            ChooseColor(),
                                      ),
                                    )
                                        .then((value) async {
                                      setState(() {
                                        if (value != null) {
                                          accountColor = value;
                                        }
                                      });
                                    });
                                  },
                                  backgcolor: accountColor,
                                  label: "Color",
                                  text: false,
                                );
                              },
                            )
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                            style: const ButtonStyle(
                              foregroundColor:
                                  MaterialStatePropertyAll(Colors.red),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Warning!"),
                                  content: Text(
                                      "Are you sure you want to permanently delete this source? Data can not be recovered after this!"),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Cancel")),
                                    TextButton(
                                        style: const ButtonStyle(
                                          foregroundColor:
                                              MaterialStatePropertyAll(
                                                  Colors.red),
                                        ),
                                        onPressed: () {
                                          accountProvider.deleteAccount(
                                              accountProvider.accounts[i]);
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Delete")),
                                  ],
                                ),
                              );
                            },
                            child: const Text("Delete")),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Cancel")),
                        TextButton(
                            onPressed: () {
                              saveModifications(
                                  accountProvider,
                                  expensesProvider,
                                  accountProvider.accounts[i],
                                  nameController.text,
                                  typeController.text,
                                  "${accountColor.alpha} ${accountColor.red} ${accountColor.green} ${accountColor.blue}",
                                  double.parse(currentAmountInputController.text
                                      .replaceAll(",", "")));
                              Navigator.pop(context);
                            },
                            child: const Text("Save")),
                      ],
                    );
                  });
            },
          );
        },
      ),
    );
  }
}
