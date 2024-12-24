import 'dart:convert';

import 'package:finances/utils/user_preferences.dart';
import 'package:flutter/material.dart';

import 'objects.dart';

class AccountsProvider extends ChangeNotifier {
  List<Account> accounts = getAccounts();

  static List<Account> getAccounts() {
    List<Account> a = [];
    UserPreferences.getAccounts().forEach((key, value) {
      a.add(Account.fromJson(value));
    });
    return a;
  }

  List<Account> get accountsList => accounts;

  createAccount(Account newAccount) {
    accounts.add(newAccount);
    notifyListeners();
    saveAccounts();
  }

  deleteAccount(Account accountToRemove) {
    accounts.remove(accountToRemove);
    notifyListeners();
    saveAccounts();
  }

  modifyAccount(Account oldAccount, Account modifiedAccount) {
    int index = accounts.indexOf(oldAccount);
    accounts[index] = modifiedAccount;
    notifyListeners();
    saveAccounts();
  }

  saveAccounts() {
    Map mapToSave = {};
    for (var element in accounts) {
      int index = accounts.indexOf(element);
      mapToSave.addAll({index.toString(): Account.toJson(element)});
    }
    UserPreferences.saveAccounts(json.encode(mapToSave));
  }
}

class ExpensesProvider extends ChangeNotifier {
  List<Expense> expenses = getExpenses();

  static List<Expense> getExpenses() {
    List<Expense> e = [];
    UserPreferences.getExpenses().forEach((key, value) {
      e.add(Expense.fromJson(value));
    });
    return e;
  }

  List<Expense> get expensesList => expenses;

  createExpense(Expense newExpense) {
    expenses.add(newExpense);
    expenses.sort((a, b) => a.date.compareTo(b.date));
    notifyListeners();
    saveExpenses();
  }

  deleteExpense(Expense expenseToRemove) {
    expenses.removeWhere((element) => element.id == expenseToRemove.id);
    notifyListeners();
    saveExpenses();
  }

  modifyExpense(Expense oldExpense, Expense modifiedExpense) {
    int index = expenses.indexOf(oldExpense);
    expenses[index] = modifiedExpense;
    expenses.sort((a, b) => a.date.compareTo(b.date));
    notifyListeners();
    saveExpenses();
  }

  saveExpenses() {
    Map mapToSave = {};
    for (var element in expenses) {
      int index = expenses.indexOf(element);
      mapToSave.addAll({index.toString(): Expense.toJson(element)});
    }
    UserPreferences.saveExpenses(json.encode(mapToSave));
  }
}

class SelectedAccounts extends ChangeNotifier {
  List<int> selectedIndexes =
      List.generate(AccountsProvider.getAccounts().length, (index) => index);

  List<int> get indexes => selectedIndexes;

  changeSelectedIndexes(List<int> indexes) {
    selectedIndexes = indexes;
    notifyListeners();
  }
}

class MainCurrency extends ChangeNotifier {
  String defaultCurrency = UserPreferences.getMainCurrency();
  String get mainCurrency => defaultCurrency;

  updateMain(String newCurrency) {
    defaultCurrency = newCurrency;
    saveChange();
    notifyListeners();
  }

  saveChange() {
    UserPreferences.saveMainCurrency(defaultCurrency);
  }
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode selectedTheme = UserPreferences.getTheme() == 'Default'
      ? ThemeMode.system
      : (UserPreferences.getTheme() == 'Light'
          ? ThemeMode.light
          : ThemeMode.dark);
  ThemeMode get theme => selectedTheme;

  changeTheme(String value) {
    if (value == 'Default') {
      selectedTheme = ThemeMode.system;
    } else if (value == 'Light') {
      selectedTheme = ThemeMode.light;
    } else if (value == 'Dark') {
      selectedTheme = ThemeMode.dark;
    }
    notifyListeners();
  }
}
