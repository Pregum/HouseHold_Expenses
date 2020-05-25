import 'package:collection/collection.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:household_expenses/expenses.dart';
import 'package:household_expenses/indicator.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pie_chart/pie_chart.dart';

import 'api_util.dart';
import 'scaffold_base.dart';
import 'use_type.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '家計簿アプリ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TopPage(title: '家計簿アプリ'),
    );
  }
}

class TopPage extends StatefulWidget {
  TopPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _TopPageState createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  /// 支出の総額
  int spending = 0;
  Map<String, double> eachSpending;

  @override
  void initState() {
    super.initState();

    ApiUtil.shared.mainReference.onChildAdded.listen(_onAdded);
    ApiUtil.shared.mainReference.onChildRemoved.listen(_onRemoved);
  }

  void _onAdded(Event event) {
    if (ApiUtil.shared.expensesList.isEmpty) return;
    setState(() {
      spending = ApiUtil.shared.expensesList
          .map((e) => e.yen)
          .reduce((value, element) => value + element);
    });
  }

  void _onRemoved(Event event) {
    if (ApiUtil.shared.expensesList.isEmpty) return;
    setState(() {
      spending = ApiUtil.shared.expensesList
          .map((e) => e.yen)
          .reduce((value, element) => value + element);
    });
  }

  /// カンマで区切った金額表記
  String get _spendingSplitedComma {
    final formatter = NumberFormat('#,###');
    return formatter.format(spending);
  }

  String _toCommaSpending(double spending) {
    final formatter = NumberFormat('#,###');
    return formatter.format(spending);
  }

  Map<String, double> _groupByUseType() {
    if (ApiUtil.shared.expensesList.isEmpty) return Map<String, double>();
    this.eachSpending = groupBy(
            ApiUtil.shared.expensesList, (Expenses obj) => obj.useType.useType)
        .map((key, value) => MapEntry(
            key,
            value
                .map((e) => e.yen.toDouble())
                .reduce((exp, element) => exp + element)));
    return this.eachSpending;
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldBase(
      title: "ダッシュボード",
      child: Card(
        margin: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: <Widget>[
                    Text('支出'),
                    Expanded(
                      child: Container(),
                    ),
                    Text('￥${_spendingSplitedComma ?? 0}'),
                  ],
                ),
              ),
            ),
            Divider(color: Colors.grey),
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Container(
                color: Colors.lightBlue,
              ),
            ),
            if (ApiUtil.shared.expensesList.isNotEmpty)
              Flexible(
                flex: 4,
                child: PieChart(
                  dataMap: _groupByUseType(),
                  showLegends: false,
                  chartType: ChartType.disc,
                  showChartValuesInPercentage: true,
                  chartValueBackgroundColor: Colors.blue,
                ),
              ),
            Flexible(
              flex: 4,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      children: <Widget>[
                        Indicator(
                          color: const Color(0xff0293ee),
                          text: UseType.templates[0].useType,
                          isSquare: false,
                          size: 18,
                          textColor: Colors.black,
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        if (this.eachSpending != null )
                          Text(
                              '￥${_toCommaSpending(this.eachSpending[UseType.templates[0].useType])}'),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      children: <Widget>[
                        Indicator(
                          color: const Color(0xfff8b250),
                          text: UseType.templates[1].useType,
                          isSquare: false,
                          size: 18,
                          textColor: Colors.black,
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        if (this.eachSpending != null)
                          Text(
                              '￥${_toCommaSpending(this.eachSpending[UseType.templates[1].useType])}'),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      children: <Widget>[
                        Indicator(
                          color: const Color(0xff845bef),
                          text: UseType.templates[2].useType,
                          isSquare: false,
                          size: 18,
                          textColor: Colors.black,
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        if (this.eachSpending != null)
                          Text(
                              '￥${_toCommaSpending(this.eachSpending[UseType.templates[2].useType])}'),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      children: <Widget>[
                        Indicator(
                          color: const Color(0xff13d38e),
                          text: UseType.templates[3].useType,
                          isSquare: false,
                          size: 18,
                          textColor: Colors.black,
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        if (this.eachSpending != null)
                          Text(
                              '￥${_toCommaSpending(this.eachSpending[UseType.templates[3].useType])}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
