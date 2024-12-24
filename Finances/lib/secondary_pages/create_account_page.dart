import 'package:finances/secondary_pages/choose_account_type.dart';
import 'package:finances/secondary_pages/choose_currency.dart';
import 'package:finances/utils/app_data.dart';
import 'package:finances/utils/important_widgets.dart';
import 'package:finances/utils/objects.dart';
import 'package:finances/utils/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../utils/formatters.dart';
import 'choose_color.dart';

class CreateAccountPage extends StatefulWidget {
  final String defaultCurrency;
  const CreateAccountPage({super.key, required this.defaultCurrency});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController initValueController = TextEditingController();
  TextEditingController currencyController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  Color color = Colors.blue;

  bool negativeBalance = false;

  Widget padding = Padding(padding: EdgeInsets.only(bottom: 20));

  @override
  void initState() {
    typeController.value = typeController.value.copyWith(text: "General");
    currencyController.value = currencyController.value.copyWith(
        text:
            "${widget.defaultCurrency} - ${currencyNames[widget.defaultCurrency]}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountsProvider>(context);
    final selectedAccountsProv = Provider.of<SelectedAccounts>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        shape: Border(bottom: BorderSide(width: 1)),
        title: Text("Add new source"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Padding(padding: EdgeInsets.only(bottom: 5)),
              inputData(label: "Name", text: true, controller: nameController),
              padding,
              inputData(
                  controller: currencyController,
                  label: "Currency",
                  text: false,
                  onTap: () async {
                    await Navigator.of(context, rootNavigator: true)
                        .push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => ChooseCurrency(),
                      ),
                    )
                        .then((value) async {
                      setState(() {
                        if (value != null) {
                          currencyController.value = currencyController.value
                              .copyWith(
                                  text: "$value - ${currencyNames[value]}");
                        }
                      });
                    });
                  }),
              padding,
              inputData(
                onTap: () async {
                  await Navigator.of(context, rootNavigator: true)
                      .push(
                    MaterialPageRoute(
                      builder: (BuildContext context) => ChooseAccountType(),
                    ),
                  )
                      .then((value) async {
                    setState(() {
                      if (value != null) {
                        typeController.value =
                            typeController.value.copyWith(text: value);
                      }
                    });
                  });
                },
                controller: typeController,
                label: "Type",
                text: false,
              ),
              padding,
              inputData(
                controller: initValueController,
                label: "Initial value",
                text: true,
                prefixIcon: !negativeBalance
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            negativeBalance = true;
                          });
                        },
                        icon: Icon(Icons.add),
                      )
                    : IconButton(
                        onPressed: () {
                          setState(() {
                            negativeBalance = false;
                          });
                        },
                        icon: Icon(Icons.remove),
                      ),
                suffix: Text(
                    symbolWriting(currencyController.text.split(" - ").first)),
                keyBoardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(
                      r'(([1-9][0-9]*((,)[0-9]{3})*|0)|\.{0}^)((\.[0-9]+)|\.)?')),
                  ThousandsSeparatorInputFormatter(),
                  //FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
              ),
              padding,
              inputData(
                onTap: () async {
                  await Navigator.of(context, rootNavigator: true)
                      .push(
                    MaterialPageRoute(
                      builder: (BuildContext context) => ChooseColor(),
                    ),
                  )
                      .then((value) async {
                    setState(() {
                      if (value != null) {
                        color = value;
                      }
                    });
                  });
                },
                backgcolor: color,
                label: "Color",
                text: false,
              ),
              Padding(padding: EdgeInsets.only(bottom: 15)),
              TextButton(
                onPressed: () {
                  if (nameController.text.isEmpty) {
                    nameController.value = nameController.value
                        .copyWith(text: typeController.text);
                  }
                  if (initValueController.text.isEmpty) {
                    initValueController.value =
                        initValueController.value.copyWith(text: "0");
                  }
                  double initialAmount = double.parse(
                      initValueController.text.replaceAll(",", ""));
                  if (negativeBalance) {
                    initialAmount *= -1;
                  }
                  String id = Uuid().v1();
                  accountProvider.createAccount(
                    Account(
                      id: id,
                      name: nameController.text,
                      type: typeController.text,
                      currency: currencyController.text.split(" - ").first,
                      initialAmount: initialAmount,
                      createdDate: DateTime.now(),
                      color:
                          "${color.alpha} ${color.red} ${color.green} ${color.blue}",
                      currentAmount: initialAmount,
                    ),
                  );
                  List<int> selectedIndexes = List.generate(
                          accountProvider.accounts.length, (index) => index)
                      .toList();
                  selectedAccountsProv.changeSelectedIndexes(selectedIndexes);
                  Navigator.pop(context);
                  print(id);
                },
                child: Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
