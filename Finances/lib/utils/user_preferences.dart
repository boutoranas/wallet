import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static SharedPreferences? _preferences;

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static Future saveAccounts(String encodedMap) async =>
      _preferences!.setString('accounts', encodedMap);
  static Map getAccounts() =>
      json.decode(_preferences!.getString('accounts') ?? '{}');

  static Future saveExpenses(String encodedMap) async =>
      _preferences!.setString('expenses', encodedMap);
  static Map getExpenses() =>
      json.decode(_preferences!.getString('expenses') ?? '{}');

  //conversion rates
  static Future saveExchangeRates(String encodedMap) async =>
      _preferences!.setString('ratesMap', encodedMap);
  static Map? getExchangeRates() => _preferences!.getString('ratesMap') != null
      ? json.decode(_preferences!.getString('ratesMap')!)
      : null;

  static Future setDataFetchingDate(int unixDate) async =>
      _preferences!.setInt('fetchDate', unixDate);
  static DateTime? getDataFetchingDate() => _preferences!.getInt('fetchDate') !=
          null
      ? DateTime.fromMillisecondsSinceEpoch(_preferences!.getInt('fetchDate')!)
      : null;

  //save recently picked currencies
  static Future saveRecentCurrencies(String encodedMap) async =>
      _preferences!.setString('recentCurrencies', encodedMap);
  static Map getRecentCurrencies() =>
      json.decode(_preferences!.getString('recentCurrencies') ?? '{}');

  //Main currency
  static Future saveMainCurrency(String currency) async =>
      _preferences!.setString('mainCurrency', currency);
  static String getMainCurrency() =>
      _preferences!.getString('mainCurrency') ?? "USD";

  //save budget
  static Future saveBudget(String encodedMap) async =>
      _preferences!.setString('budget', encodedMap);
  static Map getBudget() =>
      json.decode(_preferences!.getString('budget') ?? '{}');

  //theme
  static Future saveTheme(String theme) async =>
      await _preferences!.setString('theme', theme);
  static String getTheme() => _preferences!.getString('theme') ?? "Default";

  //save filter preferences
  static Future saveFilters(String encodedMap) async =>
      _preferences!.setString('filters', encodedMap);
  static Map<String, dynamic> getFilters() =>
      json.decode(_preferences!.getString('filters') ?? '{}');
}
