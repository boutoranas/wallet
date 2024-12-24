import 'package:flutter/material.dart';

class ChooseAccountType extends StatelessWidget {
  const ChooseAccountType({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> types = [
      "General",
      "Cash",
      "Current account",
      "Checking account",
      "Credit card",
      "Savings account",
      "Online banking account",
      "Prepaid card",
      "Stored value card",
      "Business account",
      "Investment account",
      "Retirement account",
      "Line of credit",
      "Personal loan",
      "Auto loan",
      "Mortgage",
      "Student loan",
      "Cryptocurrency account",
    ];
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        shape: Border(bottom: BorderSide(width: 1)),
        title: Text("Choose source type"),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            ...List.generate(
              types.length,
              (i) => ListTile(
                title: Text(types[i]),
                onTap: () {
                  Navigator.pop(context, types[i]);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
