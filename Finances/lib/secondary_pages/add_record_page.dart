import 'package:finances/secondary_pages/choose_account.dart';
import 'package:finances/secondary_pages/choose_account_type.dart';
import 'package:finances/secondary_pages/choose_color.dart';
import 'package:finances/utils/important_widgets.dart';
import 'package:finances/utils/objects.dart';
import 'package:finances/utils/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spinner_date_time_picker/spinner_date_time_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:math' as math;
import '../utils/formatters.dart';
import '../utils/user_preferences.dart';
import 'choose_categories.dart';

class AddRecord extends StatefulWidget {
  final Account accountToSelect;
  final Account? secondaryAccount;
  const AddRecord(
      {super.key,
      required this.accountToSelect,
      required this.secondaryAccount});

  @override
  State<AddRecord> createState() => _AddRecordState();
}

class _AddRecordState extends State<AddRecord> {
  TextEditingController amountController = TextEditingController();
  TextEditingController feesController = TextEditingController();
  TextEditingController targetAmountController = TextEditingController();
  TextEditingController labelController = TextEditingController();
  TextEditingController dateTimeController = TextEditingController();

  DateTime dateTime = DateTime.now();

  TextEditingController dayIntervalController = TextEditingController();
  List<TimeOfDay> timesOfDay = [
    TimeOfDay(hour: 0, minute: 0),
  ];

  TextEditingController weekIntervalController = TextEditingController();
  List<int> selectedDatesOfWeek = [0];
  List<String> daysOfTheWeek = [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun",
  ];

  TextEditingController monthIntervalController = TextEditingController();

  List<int> selctedDays = [1];

  TextEditingController yearIntervalController = TextEditingController();

  List<int> selctedMonths = [1];

  @override
  void initState() {
    dateTimeController.value = dateTimeController.value.copyWith(
        text:
            "${dateFormatter(DateTime.now())} at ${DateFormat("HH:mm").format(DateTime.now())}");
    dayIntervalController.value =
        dayIntervalController.value.copyWith(text: "1");
    weekIntervalController.value =
        weekIntervalController.value.copyWith(text: "1");
    monthIntervalController.value =
        monthIntervalController.value.copyWith(text: "1");
    yearIntervalController.value =
        yearIntervalController.value.copyWith(text: "1");
    super.initState();
  }

  late List tabs = widget.secondaryAccount != null
      ? ["Expense", "Income", "Transfer"]
      : ["Expense", "Income"];
  int currentTab = 0;

  String repeatEvery = "";
  String category = "";

  late Account source = widget.accountToSelect;
  late Account? secondaryAccount = widget.secondaryAccount;

  Widget getPrefixAmount() {
    if (currentTab == 1) {
      return Icon(Icons.add);
    } else if (currentTab == 0) {
      return Icon(Icons.remove);
    } else {
      return Icon(Icons.currency_exchange);
    }
  }

  Widget customContainer(String title, String subtitles) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        border: Border.all(width: 1),
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      width: 140,
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitles,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  double getMinutesAmount(TimeOfDay timeOfDay) {
    return timeOfDay.hour + timeOfDay.minute / 60;
  }

  int getFrequency() {
    switch (repeatEvery) {
      case "day":
        return int.parse(dayIntervalController.text.isNotEmpty
            ? dayIntervalController.text
            : "1");
      case "week":
        return int.parse(weekIntervalController.text.isNotEmpty
            ? weekIntervalController.text
            : "1");
      case "month":
        return int.parse(monthIntervalController.text.isNotEmpty
            ? monthIntervalController.text
            : "1");
      default:
        return int.parse(yearIntervalController.text.isNotEmpty
            ? yearIntervalController.text
            : "1");
    }
  }

  List getTimes() {
    switch (repeatEvery) {
      case "day":
        return timesOfDay;
      case "week":
        return selectedDatesOfWeek;
      case "month":
        return selctedDays;
      default:
        return selctedMonths;
    }
  }

  double convertToUsd(double amount, String currency) {
    num rate =
        UserPreferences.getExchangeRates()!["conversion_rates"][currency] ?? 0;
    return amount / rate;
  }

  double convertBackToMain(double amount, String mainCurrency) {
    return amount *
        UserPreferences.getExchangeRates()!["conversion_rates"][mainCurrency];
  }

  double convertToCurreny(double amount, String firstCurr, String secondCurr) {
    num firstRate =
        UserPreferences.getExchangeRates()!["conversion_rates"][firstCurr];
    num secondRate =
        UserPreferences.getExchangeRates()!["conversion_rates"][secondCurr];
    return amount / firstRate * secondRate;
  }

  createExpense(ExpensesProvider expensesProvider) {
    if (amountController.text.isNotEmpty) {
      if ((currentTab != 2 && category != "") || currentTab == 2) {
        double amount = double.parse(amountController.text.replaceAll(",", ""));
        double? fees = feesController.text.isNotEmpty && currentTab == 2
            ? double.parse(feesController.text.replaceAll(",", ""))
            : null;
        expensesProvider.createExpense(
          Expense(
            id: Uuid().v1(),
            type: tabs[currentTab],
            category: currentTab != 2 ? category : secondaryAccount!.id,
            account: source,
            date: dateTime,
            amount: amount,
            fees: fees,
            label:
                labelController.text.isNotEmpty ? labelController.text : null,
            repetition: repeatEvery != ""
                ? Repetition(
                    period: repeatEvery,
                    frequency: getFrequency(),
                    times: getTimes(),
                  )
                : null,
          ),
        );
        Navigator.pop(context);
      } else {
        showSnackBar(context, "Please choose a category");
      }
    } else {
      showSnackBar(context, "Please enter an amount");
    }
  }

  @override
  Widget build(BuildContext context) {
    final expensesProvider = Provider.of<ExpensesProvider>(context);
    final mainCurrProv = Provider.of<MainCurrency>(context);
    return DefaultTabController(
      length: secondaryAccount != null ? 3 : 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          shape: Border(bottom: BorderSide(width: 1)),
          title: Text("Add record"),
          actions: [
            IconButton(
              onPressed: () {
                createExpense(expensesProvider);
              },
              icon: Icon(Icons.done),
            ),
          ],
        ),
        body: Column(
          children: [
            TabBar(
              onTap: (value) {
                setState(() {
                  currentTab = value;
                });
              },
              tabs: [
                ...List.generate(
                  tabs.length,
                  (index) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        tabs[index],
                        style: TextStyle(
                          color: Theme.of(context)
                              .inputDecorationTheme
                              .border!
                              .borderSide
                              .color,
                        ),
                      )),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      Padding(padding: EdgeInsets.only(bottom: 10)),
                      inputData(
                        onChanged: () {
                          setState(() {
                            if (amountController.text.isNotEmpty &&
                                feesController.text.isNotEmpty) {
                              targetAmountController.value =
                                  targetAmountController.value.copyWith(
                                      text: thousandSeparator((convertToCurreny(
                                              double.parse(amountController.text.replaceAll(",", "")) -
                                                  double.parse(amountController
                                                          .text
                                                          .replaceAll(
                                                              ",", "")) *
                                                      double.parse(feesController
                                                          .text
                                                          .replaceAll(",", "")) /
                                                      100,
                                              source.currency,
                                              secondaryAccount!.currency))
                                          .toStringAsFixed(1)));
                            }
                          });
                        },
                        style: TextStyle(fontSize: 22),
                        controller: amountController,
                        label: "Amount",
                        text: true,
                        prefixIcon: getPrefixAmount(),
                        suffix: Text(symbolWriting(source.currency)),
                        keyBoardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(
                              r'(([1-9][0-9]*((,)[0-9]{3})*|0)|\.{0}^)((\.[0-9]+)|\.)?')),
                          ThousandsSeparatorInputFormatter(),
                          //FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                      ),
                      mainCurrProv.mainCurrency != source.currency
                          ? Padding(padding: EdgeInsets.only(bottom: 12))
                          : Container(),
                      mainCurrProv.mainCurrency != source.currency
                          ? Text(
                              "In ${mainCurrProv.mainCurrency}: ${symbolWriting(mainCurrProv.mainCurrency)} ${thousandSeparator(convertBackToMain(convertToUsd(double.parse(amountController.text.isNotEmpty ? amountController.text.replaceAll(",", "") : "0"), source.currency), mainCurrProv.mainCurrency).toStringAsFixed(1))}",
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            )
                          : Container(),
                      mainCurrProv.mainCurrency != source.currency
                          ? Divider()
                          : Container(),
                      currentTab == 2
                          ? Padding(padding: EdgeInsets.only(bottom: 10))
                          : Container(),
                      currentTab == 2
                          ? Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: inputData(
                                    onChanged: () {
                                      setState(() {
                                        if (amountController.text.isNotEmpty &&
                                            feesController.text.isNotEmpty) {
                                          targetAmountController.value = targetAmountController.value.copyWith(
                                              text: thousandSeparator((convertToCurreny(
                                                      double.parse(amountController.text
                                                              .replaceAll(
                                                                  ",", "")) -
                                                          double.parse(amountController.text.replaceAll(",", "")) *
                                                              double.parse(
                                                                  feesController
                                                                      .text
                                                                      .replaceAll(",", "")) /
                                                              100,
                                                      source.currency,
                                                      secondaryAccount!.currency))
                                                  .toStringAsFixed(1)));
                                        }
                                      });
                                    },
                                    controller: feesController,
                                    label: "Fees",
                                    text: true,
                                    prefixIcon: Icon(Icons.percent),
                                    keyBoardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(
                                          r'(([1-9][0-9]*((,)[0-9]{3})*|0)|\.{0}^)((\.[0-9]+)|\.)?')),
                                      ThousandsSeparatorInputFormatter(),
                                      //FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                                      LengthLimitingTextInputFormatter(6),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  flex: 2,
                                  child: inputData(
                                    onChanged: () {
                                      setState(() {
                                        if (amountController.text.isNotEmpty &&
                                            targetAmountController
                                                .text.isNotEmpty) {
                                          feesController.value = feesController.value.copyWith(
                                              text: ((1 -
                                                          convertToCurreny(
                                                                  double.parse(targetAmountController
                                                                      .text
                                                                      .replaceAll(
                                                                          ",",
                                                                          "")),
                                                                  secondaryAccount!
                                                                      .currency,
                                                                  source
                                                                      .currency) /
                                                              double.parse(
                                                                  amountController
                                                                      .text
                                                                      .replaceAll(
                                                                          ",",
                                                                          ""))) *
                                                      100)
                                                  .toStringAsFixed(1));
                                        }
                                      });
                                    },
                                    controller: targetAmountController,
                                    label: "Target amount",
                                    text: true,
                                    prefixIcon: Icon(Icons.add),
                                    suffix: Text(symbolWriting(
                                        secondaryAccount!.currency)),
                                    keyBoardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(
                                          r'(([1-9][0-9]*((,)[0-9]{3})*|0)|\.{0}^)((\.[0-9]+)|\.)?')),
                                      ThousandsSeparatorInputFormatter(),
                                      //FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                      Padding(padding: EdgeInsets.only(bottom: 15)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await Navigator.of(context, rootNavigator: true)
                                  .push(
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      ChooseAccount(),
                                ),
                              )
                                  .then((value) async {
                                setState(() {
                                  if (value != null) {
                                    if (secondaryAccount == value) {
                                      secondaryAccount = source;
                                    }
                                    source = value;

                                    if (amountController.text.isNotEmpty &&
                                        feesController.text.isNotEmpty) {
                                      targetAmountController.value =
                                          targetAmountController.value.copyWith(
                                              text: thousandSeparator((convertToCurreny(
                                                      double.parse(amountController.text
                                                              .replaceAll(
                                                                  ",", "")) -
                                                          double.parse(amountController.text.replaceAll(",", "")) *
                                                              double.parse(
                                                                  feesController
                                                                      .text
                                                                      .replaceAll(",", "")) /
                                                              100,
                                                      source.currency,
                                                      secondaryAccount!.currency))
                                                  .toStringAsFixed(1)));
                                    }
                                  }
                                });
                              });
                            },
                            child: customContainer("Source", source.name),
                          ),
                          Transform.rotate(
                              angle: currentTab != 1 ? 0 : math.pi,
                              child: Icon(Icons.arrow_right_alt)),
                          GestureDetector(
                            onTap: () async {
                              if (currentTab != 2) {
                                await Navigator.of(context, rootNavigator: true)
                                    .push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        ChooseCategory(),
                                  ),
                                )
                                    .then((value) async {
                                  setState(() {
                                    if (value != null) {
                                      category = value;
                                    }
                                  });
                                });
                              } else {
                                await Navigator.of(context, rootNavigator: true)
                                    .push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        ChooseAccount(
                                      secondaryAccount: secondaryAccount,
                                    ),
                                  ),
                                )
                                    .then((value) async {
                                  setState(() {
                                    if (value != null) {
                                      if (source == value) {
                                        source = secondaryAccount!;
                                      }
                                      secondaryAccount = value;

                                      if (amountController.text.isNotEmpty &&
                                          feesController.text.isNotEmpty) {
                                        targetAmountController.value = targetAmountController.value.copyWith(
                                            text: thousandSeparator((convertToCurreny(
                                                    double.parse(amountController.text.replaceAll(",", "")) -
                                                        double.parse(amountController
                                                                .text
                                                                .replaceAll(
                                                                    ",", "")) *
                                                            double.parse(
                                                                feesController
                                                                    .text
                                                                    .replaceAll(",", "")) /
                                                            100,
                                                    source.currency,
                                                    secondaryAccount!.currency))
                                                .toStringAsFixed(1)));
                                      }
                                    }
                                  });
                                });
                              }
                            },
                            child: customContainer(
                                currentTab != 2 ? "Category" : "To source",
                                currentTab != 2
                                    ? category
                                    : secondaryAccount!.name),
                          ),
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 15)),
                      inputData(
                        controller: labelController,
                        label: "label",
                        text: true,
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 10)),
                      inputData(
                        onTap: () async {
                          DateTime? newDate = await showDatePicker(
                              context: context,
                              initialDate: dateTime,
                              firstDate: DateTime(2000, 1, 1),
                              lastDate: DateTime(2099, 12, 1));
                          TimeOfDay? newTime = newDate != null
                              ? await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay(
                                      hour: dateTime.hour,
                                      minute: dateTime.minute))
                              : null;
                          if (newDate != null && newTime != null) {
                            setState(() {
                              dateTime = newDate.add(Duration(
                                  hours: newTime.hour,
                                  minutes: newTime.minute));
                              dateTimeController.value =
                                  dateTimeController.value.copyWith(
                                      text:
                                          "${dateFormatter(dateTime)} at ${DateFormat("HH:mm").format(dateTime)}");
                            });
                          }
                        },
                        prefixIcon: Icon(Icons.calendar_month),
                        controller: dateTimeController,
                        label: "Date & time",
                        text: false,
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 10)),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Repeat",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      ExpansionTile(
                        leading: SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: repeatEvery == "day" ? true : false,
                            onChanged: (val) {
                              if (repeatEvery == "day") {
                                setState(() {
                                  repeatEvery = "";
                                });
                              } else {
                                setState(() {
                                  repeatEvery = "day";
                                });
                              }
                            },
                          ),
                        ),
                        title: Row(
                          children: [
                            Text("Every "),
                            Container(
                              width: 20,
                              child: TextField(
                                controller: dayIntervalController,
                                textAlign: TextAlign.center,
                                maxLength: 2,
                                decoration: InputDecoration(
                                  isDense: true,
                                  isCollapsed: true,
                                  contentPadding: EdgeInsets.zero,
                                  counterText: '',
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ),
                            Text(" day"),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 15,
                              left: 15,
                              right: 15,
                            ),
                            child: Row(
                              children: [
                                Text("Hours: "),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Wrap(
                                    spacing: 10,
                                    children: [
                                      ...List.generate(timesOfDay.length, (i) {
                                        return GestureDetector(
                                          onTap: () async {
                                            TimeOfDay? editedTime =
                                                await showTimePicker(
                                                    context: context,
                                                    initialTime: timesOfDay[i]);
                                            if (editedTime != null) {
                                              setState(() {
                                                timesOfDay[i] = editedTime;
                                                timesOfDay.sort((a, b) =>
                                                    getMinutesAmount(a)
                                                        .compareTo(
                                                            getMinutesAmount(
                                                                b)));
                                              });
                                            }
                                          },
                                          child: Chip(
                                            onDeleted: timesOfDay.length > 1
                                                ? () {
                                                    setState(() {
                                                      timesOfDay.remove(
                                                          timesOfDay[i]);
                                                      timesOfDay.sort((a, b) =>
                                                          getMinutesAmount(a)
                                                              .compareTo(
                                                                  getMinutesAmount(
                                                                      b)));
                                                    });
                                                  }
                                                : null,
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            label: Text(
                                                "${timesOfDay[i].hour.toString().padLeft(2, "0")}:${timesOfDay[i].minute.toString().padLeft(2, "0")}"),
                                          ),
                                        );
                                      }),
                                      IconButton(
                                          onPressed: () async {
                                            TimeOfDay? newTime =
                                                await showTimePicker(
                                                    context: context,
                                                    initialTime:
                                                        TimeOfDay.now());
                                            if (newTime != null) {
                                              setState(() {
                                                timesOfDay.add(newTime);
                                                timesOfDay.sort((a, b) =>
                                                    getMinutesAmount(a)
                                                        .compareTo(
                                                            getMinutesAmount(
                                                                b)));
                                              });
                                            }
                                          },
                                          icon: Icon(Icons.add)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      ExpansionTile(
                        leading: SizedBox(
                            width: 20,
                            height: 20,
                            child: Checkbox(
                              value: repeatEvery == "week" ? true : false,
                              onChanged: (val) {
                                if (repeatEvery == "week") {
                                  setState(() {
                                    repeatEvery = "";
                                  });
                                } else {
                                  setState(() {
                                    repeatEvery = "week";
                                  });
                                }
                              },
                            )),
                        title: Row(
                          children: [
                            Text("Every "),
                            Container(
                              width: 20,
                              child: TextField(
                                controller: weekIntervalController,
                                textAlign: TextAlign.center,
                                maxLength: 2,
                                decoration: InputDecoration(
                                  isDense: true,
                                  isCollapsed: true,
                                  contentPadding: EdgeInsets.zero,
                                  counterText: '',
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ),
                            Text(" week"),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 15,
                              left: 15,
                              right: 15,
                            ),
                            child: Row(
                              children: [
                                Text("Days: "),
                                SizedBox(width: 10),
                                Expanded(
                                    child: Wrap(
                                  spacing: 5,
                                  children: [
                                    ...List.generate(
                                      daysOfTheWeek.length,
                                      (i) {
                                        return ChoiceChip(
                                          label: Text(daysOfTheWeek[i]),
                                          selectedColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          selected: selectedDatesOfWeek
                                              .contains(daysOfTheWeek
                                                  .indexOf(daysOfTheWeek[i])),
                                          onSelected: (value) {
                                            print(selectedDatesOfWeek);
                                            setState(() {
                                              if (!selectedDatesOfWeek.contains(
                                                  daysOfTheWeek.indexOf(
                                                      daysOfTheWeek[i]))) {
                                                selectedDatesOfWeek.add(
                                                    daysOfTheWeek.indexOf(
                                                        daysOfTheWeek[i]));
                                              } else if (selectedDatesOfWeek
                                                      .length >
                                                  1) {
                                                selectedDatesOfWeek.remove(
                                                    daysOfTheWeek.indexOf(
                                                        daysOfTheWeek[i]));
                                              }
                                            });
                                            selectedDatesOfWeek
                                                .sort((a, b) => a.compareTo(b));
                                            print(selectedDatesOfWeek);
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ))
                              ],
                            ),
                          ),
                        ],
                      ),
                      ExpansionTile(
                        leading: SizedBox(
                            width: 20,
                            height: 20,
                            child: Checkbox(
                              value: repeatEvery == "month" ? true : false,
                              onChanged: (val) {
                                if (repeatEvery == "month") {
                                  setState(() {
                                    repeatEvery = "";
                                  });
                                } else {
                                  setState(() {
                                    repeatEvery = "month";
                                  });
                                }
                              },
                            )),
                        title: Row(
                          children: [
                            Text("Every "),
                            Container(
                              width: 20,
                              child: TextField(
                                controller: monthIntervalController,
                                textAlign: TextAlign.center,
                                maxLength: 2,
                                decoration: InputDecoration(
                                  isDense: true,
                                  isCollapsed: true,
                                  contentPadding: EdgeInsets.zero,
                                  counterText: '',
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ),
                            Text(" month"),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 15,
                              left: 15,
                              right: 15,
                            ),
                            child: Row(
                              children: [
                                Text("Days: "),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Wrap(
                                    spacing: 10,
                                    children: [
                                      ...List.generate(selctedDays.length, (i) {
                                        return GestureDetector(
                                          child: Chip(
                                            onDeleted: selctedDays.length > 1
                                                ? () {
                                                    setState(() {
                                                      selctedDays.remove(
                                                          selctedDays[i]);
                                                      selctedDays.sort((a, b) =>
                                                          a.compareTo(b));
                                                    });
                                                  }
                                                : null,
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            label: Text(
                                                daysOfMonth(selctedDays[i])),
                                          ),
                                        );
                                      }),
                                      PopupMenuButton(
                                        icon: Icon(Icons.add),
                                        onSelected: (value) {
                                          setState(() {
                                            if (!selctedDays.contains(value)) {
                                              selctedDays.add(value);
                                              selctedDays.sort(
                                                  (a, b) => a.compareTo(b));
                                            }
                                          });
                                          print(selctedDays);
                                        },
                                        itemBuilder: (context) {
                                          return List.generate(32, (i) {
                                            return PopupMenuItem(
                                                value: i + 1,
                                                child: Text(
                                                  daysOfMonth(i + 1),
                                                  style: TextStyle(
                                                    color: selctedDays
                                                            .contains(i + 1)
                                                        ? Colors.blue
                                                        : null,
                                                  ),
                                                ));
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      ExpansionTile(
                        leading: SizedBox(
                            width: 20,
                            height: 20,
                            child: Checkbox(
                                value: repeatEvery == "year" ? true : false,
                                onChanged: (val) {
                                  if (repeatEvery == "year") {
                                    setState(() {
                                      repeatEvery = "";
                                    });
                                  } else {
                                    setState(() {
                                      repeatEvery = "year";
                                    });
                                  }
                                })),
                        title: Row(
                          children: [
                            Text("Every "),
                            Container(
                              width: 20,
                              child: TextField(
                                controller: yearIntervalController,
                                textAlign: TextAlign.center,
                                maxLength: 2,
                                decoration: InputDecoration(
                                  isDense: true,
                                  isCollapsed: true,
                                  contentPadding: EdgeInsets.zero,
                                  counterText: '',
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ),
                            Text(" year"),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 15,
                              left: 15,
                              right: 15,
                            ),
                            child: Row(
                              children: [
                                Text("Months: "),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Wrap(
                                    spacing: 10,
                                    children: [
                                      ...List.generate(selctedMonths.length,
                                          (i) {
                                        return Chip(
                                          onDeleted: selctedMonths.length > 1
                                              ? () {
                                                  setState(() {
                                                    selctedMonths.remove(
                                                        selctedMonths[i]);
                                                    selctedMonths.sort((a, b) =>
                                                        a.compareTo(b));
                                                  });
                                                }
                                              : null,
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          label: Text(
                                              displayMonth(selctedMonths[i])),
                                        );
                                      }),
                                      PopupMenuButton(
                                        icon: Icon(Icons.add),
                                        onSelected: (value) {
                                          setState(() {
                                            if (!selctedMonths
                                                .contains(value)) {
                                              selctedMonths.add(value);
                                              selctedMonths.sort(
                                                  (a, b) => a.compareTo(b));
                                            }
                                          });
                                        },
                                        itemBuilder: (context) {
                                          return List.generate(12, (i) {
                                            return PopupMenuItem(
                                                value: i + 1,
                                                child: Text(
                                                  displayMonth(i + 1),
                                                  style: TextStyle(
                                                    color: selctedMonths
                                                            .contains(i + 1)
                                                        ? Colors.blue
                                                        : null,
                                                  ),
                                                ));
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
