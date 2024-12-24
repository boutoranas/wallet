import 'dart:convert';
import 'dart:math';

import 'package:finances/dashboard.dart';
import 'package:finances/theme.dart';
import 'package:finances/utils/app_data.dart';
import 'package:finances/utils/check_connectivity.dart';
import 'package:finances/utils/objects.dart';
import 'package:finances/utils/provider.dart';
import 'package:finances/utils/user_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

updateExchangeRates() async {
  try {
    var response = await http
        .get(Uri.parse('https://v6.exchangerate-api.com/v6/$apiKey/latest/USD'))
        .timeout(Duration(seconds: 7));
    UserPreferences.saveExchangeRates(response.body);
  } on Exception catch (e) {}
  ;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserPreferences.init();
  //UserPreferences.saveExpenses('{}');
  bool connectivity = await CheckConnectivity.checkConnectivity();

  if (connectivity == true &&
      (UserPreferences.getDataFetchingDate() == null ||
          DateTime.now().isAfter(
              UserPreferences.getDataFetchingDate()!.add(Duration(days: 1))))) {
    await updateExchangeRates();
    await UserPreferences.setDataFetchingDate(
        DateTime.now().millisecondsSinceEpoch);
    print('updated rates');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<Map> getExchangeRates() async {
    var response = await http
        .get(Uri.parse('https://v6.exchangerate-api.com/v6/$apiKey/latest/USD'))
        .timeout(Duration(seconds: 7));
    return json.decode(response.body);
  }

  createCurrenciesObjects() {
    //log(json.encode(UserPreferences.getExchangeRates()));
    UserPreferences.getExchangeRates()!["conversion_rates"]
        .forEach((key, value) {
      Data.currenciesList.add(Currency(name: key, rate: value));
    });
  }

  late Future<Map> ratesMap;

  @override
  void initState() {
    ratesMap = getExchangeRates();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AccountsProvider>(
          create: (_) => AccountsProvider(),
        ),
        ChangeNotifierProvider<SelectedAccounts>(
          create: (_) => SelectedAccounts(),
        ),
        ChangeNotifierProvider<MainCurrency>(
          create: (_) => MainCurrency(),
        ),
        ChangeNotifierProvider<ExpensesProvider>(
          create: (_) => ExpensesProvider(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
      ],
      builder: (context, child) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        return MaterialApp(
          themeMode: themeProvider.theme,
          theme: lightTheme(),
          darkTheme: darkTheme(),
          debugShowCheckedModeBanner: false,
          home: UserPreferences.getExchangeRates() != null
              ? Dashboard()
              : FutureBuilder(
                  future: ratesMap,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError || !snapshot.hasData) {
                      return Text('An error has occured');
                    } else {
                      UserPreferences.saveExchangeRates(
                          json.encode(snapshot.data));
                      UserPreferences.setDataFetchingDate(
                          DateTime.now().millisecondsSinceEpoch);
                      return Dashboard();
                    }
                  },
                ),
        );
      },
    );
  }
}
