import 'dart:convert';

import 'package:finances/utils/app_data.dart';
import 'package:finances/utils/user_preferences.dart';
import 'package:flutter/material.dart';

import '../utils/objects.dart';

class ChooseCurrency extends StatefulWidget {
  const ChooseCurrency({super.key});

  @override
  State<ChooseCurrency> createState() => _ChooseCurrencyState();
}

class _ChooseCurrencyState extends State<ChooseCurrency> {
  TextEditingController searchController = TextEditingController();
  bool search = false;

  List<Currency> searchResults = [];

  List<Currency> currenciesList = Data.currenciesList;
  late List<Currency> recentCurrencies = getRecentlyPickedCurrencies();

  List<Currency> getRecentlyPickedCurrencies() {
    List<Currency> rC = [];
    UserPreferences.getRecentCurrencies().forEach((key, value) {
      rC.add(Data.currenciesList
          .where((element) => element.name == value)
          .toList()[0]);
    });
    return rC;
  }

  saveRecentlyPickedCurrencies(List<Currency> recentCurrencies) {
    Map currencyMap = {};
    for (var element in recentCurrencies) {
      int index = recentCurrencies.indexOf(element);
      currencyMap.addAll({index.toString(): element.name});
    }
    UserPreferences.saveRecentCurrencies(json.encode(currencyMap));
  }

  @override
  void initState() {
    searchResults = currenciesList;
    super.initState();
  }

  getSearchResults() {
    if (searchController.text.isNotEmpty) {
      List<Currency> results = [];
      for (var element in currenciesList) {
        if (element.name
                .toLowerCase()
                .contains(searchController.text.toLowerCase()) ||
            (element.fullName != null &&
                element.fullName!
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase()))) {
          results.add(element);
        }
      }
      setState(() {
        searchResults = results;
      });
    } else {
      setState(() {
        searchResults = currenciesList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: !search
            ? AppBar(
                elevation: 0,
                shape: Border(bottom: BorderSide(width: 1)),
                title: Text("Choose currency"),
                actions: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        search = true;
                      });
                    },
                    icon: Icon(Icons.search),
                  )
                ],
              )
            : AppBar(
                backgroundColor: Colors.white,
                leading: BackButton(
                  onPressed: () {
                    searchController.clear();
                    setState(() {
                      searchResults = currenciesList;
                      search = false;
                    });
                  },
                  color: Colors.black,
                ),
                title: Container(
                  color: Colors.white,
                  height: 55,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 100,
                        child: TextField(
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                          controller: searchController,
                          autofocus: true,
                          onChanged: (value) {
                            getSearchResults();
                          },
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          searchController.clear();
                          searchResults = currenciesList;
                          setState(() {});
                        },
                        icon: Icon(
                          Icons.cancel_sharp,
                          color: Colors.black,
                        ),
                      )
                    ],
                  ),
                ),
              ),
        body: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            searchResults == currenciesList && recentCurrencies.isNotEmpty
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(padding: EdgeInsets.only(bottom: 10)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Recently picked",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 5)),
                      ...List.generate(
                        recentCurrencies.length,
                        (i) => ListTile(
                          leading: CircleAvatar(
                            backgroundImage: AssetImage(
                                "assets/images/${recentCurrencies[i].name}.png"),
                          ),
                          title: Text(recentCurrencies[i].fullName ??
                              recentCurrencies[i].name),
                          trailing: Text(recentCurrencies[i].name),
                          onTap: () {
                            Currency currencyToReplace = recentCurrencies[i];
                            recentCurrencies.remove(recentCurrencies[i]);
                            recentCurrencies.insert(0, currencyToReplace);
                            saveRecentlyPickedCurrencies(recentCurrencies);
                            Navigator.pop(context, currencyToReplace.name);
                          },
                        ),
                      ),
                      Divider(),
                    ],
                  )
                : Container(),
            Padding(padding: EdgeInsets.only(bottom: 10)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "Currencies",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 5)),
            ...List.generate(
              searchResults.length,
              (i) => ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      AssetImage("assets/images/${searchResults[i].name}.png"),
                ),
                title: Text(searchResults[i].fullName ?? searchResults[i].name),
                trailing: Text(searchResults[i].name),
                onTap: () {
                  if (recentCurrencies.contains(searchResults[i])) {
                    recentCurrencies.remove(searchResults[i]);
                  }
                  recentCurrencies.insert(0, searchResults[i]);

                  if (recentCurrencies.length > 7) {
                    recentCurrencies.removeAt(7);
                  }
                  saveRecentlyPickedCurrencies(recentCurrencies);
                  Navigator.pop(context, searchResults[i].name);
                },
              ),
            ),
            searchResults.isEmpty
                ? Center(child: Text("No results"))
                : Container(),
            Padding(padding: EdgeInsets.only(bottom: 10)),
          ],
        ));
  }
}
