import 'package:finances/utils/objects.dart';
import 'package:finances/utils/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../utils/formatters.dart';
import '../utils/important_widgets.dart';
import '../utils/user_preferences.dart';
import 'choose_account.dart';
import 'dart:math' as math;

import 'choose_categories.dart';

class EditExpense extends StatefulWidget {
  final Expense expense;
  final AccountsProvider accountsProvider;
  final ExpensesProvider expensesProvider;
  const EditExpense(
      {super.key,
      required this.expense,
      required this.accountsProvider,
      required this.expensesProvider});

  @override
  State<EditExpense> createState() => _EditExpenseState();
}

class _EditExpenseState extends State<EditExpense> {
  TextEditingController amountController = TextEditingController();
  TextEditingController feesController = TextEditingController();
  TextEditingController targetAmountController = TextEditingController();
  TextEditingController labelController = TextEditingController();
  TextEditingController dateTimeController = TextEditingController();

  late Account source = widget.expense.account;
  late Account? secondaryAccount;

  late String category = widget.expense.category;

  late DateTime dateTime = widget.expense.date;

  String repeatEvery = "";

  Repetition? repetition;
  bool removeRepetition = false;

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

  List<String> daysOfTheWeekComplete = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  TextEditingController monthIntervalController = TextEditingController();

  List<int> selctedDays = [1];

  TextEditingController yearIntervalController = TextEditingController();

  List<int> selctedMonths = [1];

  Widget getPrefixAmount() {
    if (widget.expense.type == "Income") {
      return Icon(Icons.add);
    } else if (widget.expense.type == "Expense") {
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

  String getListOfTimes(Repetition repetition) {
    List<String> texts = [];
    if (repetition.period == "day") {
      for (var time in repetition.times) {
        texts.add(
            "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}");
      }
      return "at ${texts.join(", ")}";
    } else if (repetition.period == "week") {
      for (var time in repetition.times) {
        texts.add("${daysOfTheWeekComplete[time]}s");
      }
      return "on ${texts.join(", ")}";
    } else if (repetition.period == "month") {
      for (var time in repetition.times) {
        texts.add("${daysOfMonth(time)}s");
      }
      return "on ${texts.join(", ")}";
    } else {
      for (var time in repetition.times) {
        texts.add("${displayMonth(time)}s");
      }
      return "on ${texts.join(", ")}";
    }
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

  modifyExpense(ExpensesProvider expensesProvider) {
    if (amountController.text.isNotEmpty) {
      if ((widget.expense.type != "Transfer" && category != "") ||
          widget.expense.type == "Transfer") {
        if (repetition == null) {
          double amount =
              double.parse(amountController.text.replaceAll(",", ""));
          double? fees = feesController.text.isNotEmpty &&
                  widget.expense.type == "Transfer"
              ? double.parse(feesController.text.replaceAll(",", ""))
              : null;
          expensesProvider.modifyExpense(
            widget.expense,
            Expense(
              id: widget.expense.id,
              type: widget.expense.type,
              category: widget.expense.type != "Transfer"
                  ? category
                  : secondaryAccount!.id,
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
        } else {
          double amount =
              double.parse(amountController.text.replaceAll(",", ""));
          double? fees = feesController.text.isNotEmpty &&
                  widget.expense.type == "Transfer"
              ? double.parse(feesController.text.replaceAll(",", ""))
              : null;
          expensesProvider.modifyExpense(
            widget.expense,
            Expense(
              id: widget.expense.id,
              type: widget.expense.type,
              category: widget.expense.type != "Transfer"
                  ? category
                  : secondaryAccount!.id,
              account: source,
              date: dateTime,
              amount: amount,
              fees: fees,
              label:
                  labelController.text.isNotEmpty ? labelController.text : null,
              repetition:
                  removeRepetition == false ? widget.expense.repetition : null,
            ),
          );
          if (removeRepetition == true) {
            for (var expense in expensesProvider.expenses) {
              if (expense.id == widget.expense.id) {
                expense.id = Uuid().v1();
                expense.repetition = null;
              }
            }
          }
        }
        Navigator.pop(context);
      } else {
        showSnackBar(context, "Please choose a category");
      }
    } else {
      showSnackBar(context, "Please enter an amount");
    }
  }

  double convertToCurreny(double amount, String firstCurr, String secondCurr) {
    double firstRate =
        UserPreferences.getExchangeRates()!["conversion_rates"][firstCurr];
    double secondRate =
        UserPreferences.getExchangeRates()!["conversion_rates"][secondCurr];
    return amount / firstRate * secondRate;
  }

  copyExpense(context, ExpensesProvider expensesProvider) {
    showDialog(
        context: context,
        builder: (context) {
          DateTime copyDateTime = DateTime.now();
          TextEditingController copyDateTimeController =
              TextEditingController();

          copyDateTimeController.value = copyDateTimeController.value.copyWith(
              text:
                  "${dateFormatter(copyDateTime)} at ${DateFormat("HH:mm").format(copyDateTime)}");
          return AlertDialog(
            title: Text("Copy expense"),
            content: StatefulBuilder(
              builder: (context, setState) => inputData(
                onTap: () async {
                  DateTime? newDate = await showDatePicker(
                      context: context,
                      initialDate: copyDateTime,
                      firstDate: DateTime(2000, 1, 1),
                      lastDate: DateTime(2099, 12, 1));
                  TimeOfDay? newTime = newDate != null
                      ? await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                              hour: dateTime.hour, minute: dateTime.minute))
                      : null;
                  if (newDate != null && newTime != null) {
                    setState(() {
                      copyDateTime = newDate.add(Duration(
                          hours: newTime.hour, minutes: newTime.minute));
                      copyDateTimeController.value =
                          copyDateTimeController.value.copyWith(
                              text:
                                  "${dateFormatter(copyDateTime)} at ${DateFormat("HH:mm").format(copyDateTime)}");
                    });
                  }
                },
                prefixIcon: Icon(Icons.calendar_month),
                controller: copyDateTimeController,
                label: "Date & time",
                text: false,
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
                  expensesProvider.createExpense(
                    Expense(
                      id: Uuid().v1(),
                      type: widget.expense.type,
                      category: widget.expense.category,
                      account: widget.expense.account,
                      fees: widget.expense.fees,
                      date: copyDateTime,
                      amount: widget.expense.amount,
                      label: widget.expense.label,
                      repetition: null,
                    ),
                  );
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text("Save"),
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    if (widget.accountsProvider.accounts
        .where((element) => element.id == widget.expense.category)
        .toList()
        .isNotEmpty) {
      secondaryAccount = widget.accountsProvider.accounts
          .where((element) => element.id == widget.expense.category)
          .toList()[0];
    }
    amountController.value = amountController.value.copyWith(
        text: thousandSeparator(widget.expense.amount.toStringAsFixed(1)));
    labelController.value =
        labelController.value.copyWith(text: widget.expense.label);
    dateTimeController.value = dateTimeController.value.copyWith(
        text:
            "${dateFormatter(widget.expense.date)} at ${DateFormat("HH:mm").format(widget.expense.date)}");

    dayIntervalController.value =
        dayIntervalController.value.copyWith(text: "1");
    weekIntervalController.value =
        weekIntervalController.value.copyWith(text: "1");
    monthIntervalController.value =
        monthIntervalController.value.copyWith(text: "1");
    yearIntervalController.value =
        yearIntervalController.value.copyWith(text: "1");

    //check for repetition
    for (var expense in widget.expensesProvider.expenses) {
      if (expense.id == widget.expense.id && expense.repetition != null) {
        repetition = expense.repetition;
        repeatEvery = expense.repetition!.period;
        if (repeatEvery == "day") {
          dayIntervalController.value = dayIntervalController.value
              .copyWith(text: expense.repetition!.frequency.toString());
          for (var time in expense.repetition!.times) {
            List<TimeOfDay> times = [];
            times.add(time);
            timesOfDay = times;
          }
        } else if (repeatEvery == "week") {
          weekIntervalController.value = weekIntervalController.value
              .copyWith(text: expense.repetition!.frequency.toString());
          for (var time in expense.repetition!.times) {
            List<int> times = [];
            times.add(time);
            selectedDatesOfWeek = times;
          }
        } else if (repeatEvery == "month") {
          monthIntervalController.value = monthIntervalController.value
              .copyWith(text: expense.repetition!.frequency.toString());
          for (var time in expense.repetition!.times) {
            List<int> times = [];
            times.add(time);
            selctedDays = times;
          }
        } else if (repeatEvery == "year") {
          yearIntervalController.value = yearIntervalController.value
              .copyWith(text: expense.repetition!.frequency.toString());
          for (var time in expense.repetition!.times) {
            List<int> times = [];
            times.add(time);
            selctedMonths = times;
          }
        }
      }
    }

    if (widget.expense.fees != null) {
      feesController.value = feesController.value
          .copyWith(text: thousandSeparator(widget.expense.fees.toString()));
      if (amountController.text.isNotEmpty && feesController.text.isNotEmpty) {
        targetAmountController.value = targetAmountController.value.copyWith(
            text: thousandSeparator((convertToCurreny(
                    double.parse(amountController.text.replaceAll(",", "")) -
                        double.parse(
                                amountController.text.replaceAll(",", "")) *
                            double.parse(
                                feesController.text.replaceAll(",", "")) /
                            100,
                    source.currency,
                    secondaryAccount!.currency))
                .toStringAsFixed(1)));
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final expensesProv = Provider.of<ExpensesProvider>(context);
    final mainCurrProv = Provider.of<MainCurrency>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        shape: Border(bottom: BorderSide(width: 1)),
        title: Text("Edit ${widget.expense.type.toLowerCase()}"),
        actions: [
          SizedBox(
              width: 35,
              child: IconButton(
                onPressed: () {
                  copyExpense(context, expensesProv);
                },
                icon: Icon(Icons.copy),
              )),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Are you sure?"),
                  content: Text(
                      "Deleting this expense will be permanent and data can not be recovered after this action!"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Cancel"),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        expensesProv.deleteExpense(widget.expense);
                        Navigator.pop(context);
                      },
                      child: Text("Delete"),
                    ),
                  ],
                ),
              );
            },
            icon: Icon(Icons.delete),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Padding(padding: EdgeInsets.only(bottom: 10)),
              inputData(
                onChanged: () {
                  setState(() {});
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
              widget.expense.type == "Transfer"
                  ? Padding(padding: EdgeInsets.only(bottom: 10))
                  : Container(),
              widget.expense.type == "Transfer"
                  ? Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: inputData(
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
                                    targetAmountController.text.isNotEmpty) {
                                  feesController.value = feesController.value
                                      .copyWith(
                                          text: ((1 -
                                                      convertToCurreny(
                                                              double.parse(
                                                                  targetAmountController
                                                                      .text
                                                                      .replaceAll(
                                                                          ",",
                                                                          "")),
                                                              secondaryAccount!
                                                                  .currency,
                                                              source.currency) /
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
                            suffix:
                                Text(symbolWriting(secondaryAccount!.currency)),
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
                          builder: (BuildContext context) => ChooseAccount(),
                        ),
                      )
                          .then((value) async {
                        setState(() {
                          if (value != null) {
                            if (widget.expense.type == "Transfer" &&
                                secondaryAccount == value) {
                              secondaryAccount = source;
                            }
                            source = value;

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
                          }
                        });
                      });
                    },
                    child: customContainer("Source", source.name),
                  ),
                  Transform.rotate(
                      angle: widget.expense.type != "Income" ? 0 : math.pi,
                      child: Icon(Icons.arrow_right_alt)),
                  GestureDetector(
                    onTap: () async {
                      if (widget.expense.type != "Transfer") {
                        await Navigator.of(context, rootNavigator: true)
                            .push(
                          MaterialPageRoute(
                            builder: (BuildContext context) => ChooseCategory(),
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
                            builder: (BuildContext context) => ChooseAccount(
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
                                targetAmountController.value =
                                    targetAmountController.value.copyWith(
                                        text: thousandSeparator((convertToCurreny(
                                                double.parse(amountController
                                                        .text
                                                        .replaceAll(",", "")) -
                                                    double.parse(amountController.text.replaceAll(",", "")) *
                                                        double.parse(
                                                            feesController.text
                                                                .replaceAll(
                                                                    ",", "")) /
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
                        widget.expense.type != "Transfer"
                            ? "Category"
                            : "To source",
                        widget.expense.type != "Transfer"
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
                              hour: dateTime.hour, minute: dateTime.minute))
                      : null;
                  if (newDate != null && newTime != null) {
                    setState(() {
                      dateTime = newDate.add(Duration(
                          hours: newTime.hour, minutes: newTime.minute));
                      dateTimeController.value = dateTimeController.value.copyWith(
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
              repetition == null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                                        ...List.generate(timesOfDay.length,
                                            (i) {
                                          return GestureDetector(
                                            onTap: () async {
                                              TimeOfDay? editedTime =
                                                  await showTimePicker(
                                                      context: context,
                                                      initialTime:
                                                          timesOfDay[i]);
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
                                                        timesOfDay.sort((a,
                                                                b) =>
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
                                              setState(() {
                                                if (!selectedDatesOfWeek
                                                    .contains(daysOfTheWeek
                                                        .indexOf(daysOfTheWeek[
                                                            i]))) {
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
                                              selectedDatesOfWeek.sort(
                                                  (a, b) => a.compareTo(b));
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
                                        ...List.generate(selctedDays.length,
                                            (i) {
                                          return GestureDetector(
                                            child: Chip(
                                              onDeleted: selctedDays.length > 1
                                                  ? () {
                                                      setState(() {
                                                        selctedDays.remove(
                                                            selctedDays[i]);
                                                        selctedDays.sort(
                                                            (a, b) =>
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
                                              if (!selctedDays
                                                  .contains(value)) {
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
                                                      selctedMonths.sort(
                                                          (a, b) =>
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
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Repeat every ${repetition!.frequency != 1 ? "${repetition!.frequency} " : ""}${repetition!.period}${repetition!.frequency != 1 ? "s" : ""}, ${getListOfTimes(repetition!)}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(bottom: 8)),
                        Row(
                          children: [
                            Checkbox(
                              value: removeRepetition,
                              onChanged: (value) {
                                setState(() {
                                  removeRepetition = !removeRepetition;
                                });
                              },
                            ),
                            Expanded(
                              child: Text(
                                "Make all expenses in series indepedant, and stop repeating expense",
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
              Padding(padding: EdgeInsets.only(bottom: 10)),
              FilledButton(
                onPressed: () {
                  modifyExpense(expensesProv);
                },
                child: Text("Save"),
              ),
              Padding(padding: EdgeInsets.only(bottom: 10)),
            ],
          ),
        ),
      ),
    );
  }
}
