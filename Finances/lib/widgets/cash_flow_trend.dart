import 'package:flutter/material.dart';

class CashFlowTrend extends StatefulWidget {
  const CashFlowTrend({super.key});

  @override
  State<CashFlowTrend> createState() => _CashFlowTrendState();
}

class _CashFlowTrendState extends State<CashFlowTrend> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 15,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(width: 1),
      ),
    );
  }
}
