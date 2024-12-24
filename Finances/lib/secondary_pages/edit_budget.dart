import 'dart:convert';

import 'package:finances/utils/formatters.dart';
import 'package:finances/utils/important_widgets.dart';
import 'package:finances/utils/user_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../utils/provider.dart';

class EditBudget extends StatefulWidget {
  const EditBudget({super.key});

  @override
  State<EditBudget> createState() => _EditBudgetState();
}

class _EditBudgetState extends State<EditBudget> {
  TextEditingController dailyController = TextEditingController();
  TextEditingController weeklyController = TextEditingController();
  TextEditingController monthlyController = TextEditingController();
  TextEditingController yearlyController = TextEditingController();

  @override
  void initState() {
    if (UserPreferences.getBudget()["daily"] != null) {
      dailyController.value = dailyController.value.copyWith(
          text: thousandSeparator(
              UserPreferences.getBudget()["daily"].toStringAsFixed(2)));
    }
    if (UserPreferences.getBudget()["weekly"] != null) {
      weeklyController.value = weeklyController.value.copyWith(
          text: thousandSeparator(
              UserPreferences.getBudget()["weekly"].toStringAsFixed(2)));
    }
    if (UserPreferences.getBudget()["monthly"] != null) {
      monthlyController.value = monthlyController.value.copyWith(
          text: thousandSeparator(
              UserPreferences.getBudget()["monthly"].toStringAsFixed(2)));
    }
    if (UserPreferences.getBudget()["yearly"] != null) {
      yearlyController.value = yearlyController.value.copyWith(
          text: thousandSeparator(
              UserPreferences.getBudget()["yearly"].toStringAsFixed(2)));
    }
    super.initState();
  }

  recalculateBudgets() {
    if (referencePeriod == "Daily") {
      if (dailyController.text.isNotEmpty) {
        weeklyController.value = weeklyController.value.copyWith(
            text: thousandSeparator(
                (toDouble(dailyController.text) * 7).toStringAsFixed(1)));
        monthlyController.value = monthlyController.value.copyWith(
            text: thousandSeparator(
                (toDouble(dailyController.text) * 30).toStringAsFixed(1)));
        yearlyController.value = yearlyController.value.copyWith(
            text: thousandSeparator(
                (toDouble(dailyController.text) * 365).toStringAsFixed(1)));
      } else {
        showSnackBar(context, "Please enter your daily budget first");
      }
    } else if (referencePeriod == "Weekly") {
      if (weeklyController.text.isNotEmpty) {
        dailyController.value = dailyController.value.copyWith(
            text: thousandSeparator(
                (toDouble(weeklyController.text) / 7).toStringAsFixed(1)));
        monthlyController.value = monthlyController.value.copyWith(
            text: thousandSeparator((toDouble(weeklyController.text) * 4.34524)
                .toStringAsFixed(1)));
        yearlyController.value = yearlyController.value.copyWith(
            text: thousandSeparator(
                (toDouble(weeklyController.text) * 52).toStringAsFixed(1)));
      } else {
        showSnackBar(context, "Please enter your weekly budget first");
      }
    } else if (referencePeriod == "Monthly") {
      if (monthlyController.text.isNotEmpty) {
        dailyController.value = dailyController.value.copyWith(
            text: thousandSeparator(
                (toDouble(monthlyController.text) / 30).toStringAsFixed(1)));
        weeklyController.value = weeklyController.value.copyWith(
            text: thousandSeparator((toDouble(monthlyController.text) / 4.34524)
                .toStringAsFixed(1)));
        yearlyController.value = yearlyController.value.copyWith(
            text: thousandSeparator(
                (toDouble(monthlyController.text) * 12).toStringAsFixed(1)));
      } else {
        showSnackBar(context, "Please enter your monthly budget first");
      }
    } else if (referencePeriod == "Yearly") {
      if (yearlyController.text.isNotEmpty) {
        dailyController.value = dailyController.value.copyWith(
            text: thousandSeparator(
                (toDouble(yearlyController.text) / 365).toStringAsFixed(1)));
        weeklyController.value = weeklyController.value.copyWith(
            text: thousandSeparator(
                (toDouble(yearlyController.text) / 52).toStringAsFixed(1)));
        monthlyController.value = monthlyController.value.copyWith(
            text: thousandSeparator(
                (toDouble(yearlyController.text) / 12).toStringAsFixed(1)));
      } else {
        showSnackBar(context, "Please enter your yearly budget first");
      }
    }
  }

  double toDouble(String text) {
    return double.parse(text.replaceAll(",", ""));
  }

  String referencePeriod = "Monthly";
  List<String> periods = [
    "Daily",
    "Weekly",
    "Monthly",
    "Yearly",
  ];
  @override
  Widget build(BuildContext context) {
    final mainCurrProv = Provider.of<MainCurrency>(context);
    return AlertDialog(
      title: Text("Edit budget"),
      content: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            inputData(
              label: "Daily budget",
              text: true,
              controller: dailyController,
              suffix: Text(symbolWriting(mainCurrProv.mainCurrency)),
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
              label: "Weekly budget",
              text: true,
              controller: weeklyController,
              suffix: Text(symbolWriting(mainCurrProv.mainCurrency)),
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
              label: "Monthly budget",
              text: true,
              controller: monthlyController,
              suffix: Text(symbolWriting(mainCurrProv.mainCurrency)),
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
              label: "Yearly budget",
              text: true,
              controller: yearlyController,
              suffix: Text(symbolWriting(mainCurrProv.mainCurrency)),
              keyBoardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(
                    r'(([1-9][0-9]*((,)[0-9]{3})*|0)|\.{0}^)((\.[0-9]+)|\.)?')),
                ThousandsSeparatorInputFormatter(),
                //FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
            ),
            Padding(padding: EdgeInsets.only(bottom: 5)),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: NeverScrollableScrollPhysics(),
              child: TextButton(
                  onPressed: () {
                    setState(() {
                      recalculateBudgets();
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Calculate all based on"),
                      SizedBox(
                        width: 5,
                      ),
                      PopupMenuButton(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${referencePeriod.toLowerCase()} budget",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.blue),
                            ),
                            Icon(Icons.arrow_drop_down, color: Colors.blue),
                          ],
                        ),
                        onSelected: (value) {
                          setState(() {
                            referencePeriod = value;
                          });
                        },
                        itemBuilder: (context) {
                          return List.generate(
                              periods.length,
                              (index) => PopupMenuItem(
                                    value: periods[index],
                                    child: Text(periods[index]),
                                  ));
                        },
                      )
                    ],
                  )),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            Map budgetMap = {};
            budgetMap.addAll({"currency": mainCurrProv.mainCurrency});
            if (dailyController.text.isNotEmpty) {
              budgetMap.addAll({
                "daily": double.parse(dailyController.text.replaceAll(",", ""))
              });
            }
            if (weeklyController.text.isNotEmpty) {
              budgetMap.addAll({
                "weekly":
                    double.parse(weeklyController.text.replaceAll(",", ""))
              });
            }
            if (monthlyController.text.isNotEmpty) {
              budgetMap.addAll({
                "monthly":
                    double.parse(monthlyController.text.replaceAll(",", ""))
              });
            }
            if (yearlyController.text.isNotEmpty) {
              budgetMap.addAll({
                "yearly":
                    double.parse(yearlyController.text.replaceAll(",", ""))
              });
            }
            UserPreferences.saveBudget(json.encode(budgetMap));
            Navigator.pop(context, budgetMap);
          },
          child: Text("Save"),
        ),
      ],
    );
  }
}
