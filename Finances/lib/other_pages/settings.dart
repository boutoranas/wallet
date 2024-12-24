import 'package:finances/secondary_pages/choose_currency.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/provider.dart';
import '../utils/user_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    final mainCurrProvider = Provider.of<MainCurrency>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        elevation: 0,
        shape: Border(bottom: BorderSide(width: 1)),
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          Padding(padding: EdgeInsets.only(bottom: 10)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "General settings",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: 5)),
          ListTile(
            title: Text("Main currency"),
            trailing: Text(
              mainCurrProvider.defaultCurrency,
              style: TextStyle(fontWeight: FontWeight.w300),
            ),
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChooseCurrency(),
                  )).then((value) => mainCurrProvider.updateMain(value));
            },
          ),
          ListTile(
            title: const Text('Theme'),
            trailing: PopupMenuButton(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    UserPreferences.getTheme(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                    child: Icon(
                      Icons.arrow_drop_down,
                    ),
                  ),
                ],
              ),
              itemBuilder: (context) {
                return const [
                  PopupMenuItem(
                    value: 'Default',
                    child: Text('Default (system)'),
                  ),
                  PopupMenuItem(
                    value: 'Light',
                    child: Text('Light theme'),
                  ),
                  PopupMenuItem(
                    value: 'Dark',
                    child: Text('Dark theme'),
                  ),
                ];
              },
              onSelected: (value) {
                UserPreferences.saveTheme(value);
                themeProvider.changeTheme(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
