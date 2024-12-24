import 'dart:convert';
import 'dart:developer';

import 'package:finances/utils/app_data.dart';
import 'package:flutter/material.dart';

class Account {
  String name, id, type, color;
  final String currency;
  double initialAmount, currentAmount;
  final DateTime createdDate;

  Account({
    required this.name,
    required this.id,
    required this.type,
    required this.currency,
    required this.initialAmount,
    required this.createdDate,
    required this.color,
    required this.currentAmount,
  });

  factory Account.fromJson(Map jsonMap) {
    return Account(
      name: jsonMap["name"],
      id: jsonMap["id"],
      type: jsonMap["type"],
      color: jsonMap["color"],
      currency: jsonMap["currency"],
      initialAmount: jsonMap["initialAmount"],
      currentAmount: jsonMap["currentAmount"],
      createdDate: DateTime.fromMillisecondsSinceEpoch(jsonMap["createdDate"]),
    );
  }

  static Map toJson(Account account) {
    return {
      "id": account.id,
      "color": account.color,
      "name": account.name,
      "type": account.type,
      "currency": account.currency,
      "initialAmount": account.initialAmount,
      "currentAmount": account.currentAmount,
      "createdDate": account.createdDate.millisecondsSinceEpoch,
    };
  }
}

class Expense {
  String id, type, category;
  Account account;
  String? label;
  Repetition? repetition;
  DateTime date;
  double amount;
  double? fees;

  Expense({
    required this.id,
    required this.type,
    required this.category,
    required this.account,
    required this.date,
    required this.amount,
    this.fees,
    this.label,
    this.repetition,
  });

  factory Expense.fromJson(Map jsonMap) {
    List getTimes() {
      List newL = [];
      List l = jsonMap["repetition"]["times"].values.toList();
      if (l[0].contains(":")) {
        for (var element in l) {
          newL.add(TimeOfDay(
              hour: int.parse(element.split(":").first),
              minute: int.parse(element.split(":").last)));
        }
        return newL;
      } else {
        for (var element in l) {
          newL.add(int.parse(element));
        }
        return newL;
      }
    }

    Repetition? rep = jsonMap["repetition"].isNotEmpty
        ? Repetition(
            period: jsonMap["repetition"]["period"],
            frequency: jsonMap["repetition"]["frequency"],
            times: getTimes(),
          )
        : null;

    return Expense(
      id: jsonMap["id"],
      type: jsonMap["type"],
      category: jsonMap["category"],
      account: Account.fromJson(jsonMap["account"]),
      label: jsonMap["label"],
      date: DateTime.fromMillisecondsSinceEpoch(jsonMap["date"]),
      amount: jsonMap["amount"],
      fees: jsonMap["fees"],
      repetition: rep,
    );
  }

  static Map toJson(Expense expense) {
    Map acc = Account.toJson(expense.account);
    Map makeRepetitionMap() {
      if (expense.repetition != null) {
        Map times = {};
        for (var element in expense.repetition!.times) {
          times.addAll({
            expense.repetition!.times.indexOf(element).toString(): element
                        .runtimeType ==
                    TimeOfDay
                ? "${element.hour.toString().padLeft(2, "0")}:${element.minute.toString().padLeft(2, "0")}"
                : element
          });
        }
        return {
          "period": expense.repetition!.period,
          "frequency": expense.repetition!.frequency,
          "times": times,
        };
      } else {
        return {};
      }
    }

    return {
      "id": expense.id,
      "type": expense.type,
      "category": expense.category,
      "account": acc,
      "label": expense.label,
      "amount": expense.amount,
      "fees": expense.fees,
      "date": expense.date.millisecondsSinceEpoch,
      "repetition": makeRepetitionMap(),
    };
  }
}

class Currency {
  final String name;
  final String? fullName;
  final num rate;
  Currency({
    required this.name,
    required this.rate,
    this.fullName,
  });

  factory Currency.fromJson(Map map) {
    return Currency(
        name: map["name"],
        rate: map["rate"],
        fullName: currencyNames[map["name"]]);
  }
}

class Repetition {
  String period;
  int frequency;
  List times;
  Repetition(
      {required this.period, required this.frequency, required this.times});
}
