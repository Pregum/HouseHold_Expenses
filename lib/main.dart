import 'package:collection/collection.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:household_expenses/expenses.dart';
import 'package:household_expenses/indicator.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
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

  /// 選択中の月
  int _selectedMonth = DateTime.now().month;
  Map<String, double> eachSpending;
  bool needDisplayDaySpending = false;
  double get divide {
    var now = DateTime.now();
    var firstDayInCurrentMonth = DateTime(now.year, now.month, 1);
    var nextMonth = DateTime(now.year, now.month + 1, 1);
    var diffDays = nextMonth.difference(firstDayInCurrentMonth);
    return this.needDisplayDaySpending ? diffDays.inDays.toDouble() : 1.0;
  }

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
          .where((element) => element.dateTime.month == _selectedMonth)
          .map((e) => e.yen)
          .fold(0, (value, element) => value + element);
    });
  }

  void _onRemoved(Event event) {
    if (ApiUtil.shared.expensesList.isEmpty) return;
    setState(() {
      spending = ApiUtil.shared.expensesList
          .where((element) => element.dateTime.month == _selectedMonth)
          .map((e) => e.yen)
          .fold(0, (value, element) => value + element);
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
    if (ApiUtil.shared.expensesList
        .where((element) => element.dateTime.month == _selectedMonth)
        .isEmpty) {
      this.eachSpending = new Map<String, double>();
      this.spending = 0;
      return this.eachSpending;
    }
    this.eachSpending = groupBy(
            ApiUtil.shared.expensesList, (Expenses obj) => obj.useType.useType)
        .map((key, value) => MapEntry(
            key,
            value
                .where((element) => element.dateTime.month == _selectedMonth)
                .map((e) => e.yen.toDouble())
                .fold(0, (exp, element) => exp + element)));
    this.spending = this
        .eachSpending
        .values
        .fold(0, (previousValue, element) => previousValue + element.round());
    return this.eachSpending;
  }

  /// 月を選択する為のドロップダウンボタンを作成
  Widget _buildDropdownButton() {
    return DropdownButton<int>(
      dropdownColor: Colors.blue,
      value: this._selectedMonth,
      hint: Text(
        '月選択',
        style:
            Theme.of(context).textTheme.headline6.copyWith(color: Colors.white),
      ),
      onChanged: (int newValue) {
        setState(() {
          this._selectedMonth = newValue;
        });
      },
      iconEnabledColor: Colors.white,
      items: [
        for (int i = 1; i <= 12; i++)
          DropdownMenuItem(
            child: Text(
              '$i 月度',
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .copyWith(color: Colors.white),
            ),
            value: i,
          ),
      ],
    );
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
                    Text(
                      '$_selectedMonth月の支出',
                      style: Theme.of(context)
                          .textTheme
                          .headline4
                          .copyWith(color: Colors.black),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    Text(
                      '￥${_toCommaSpending((this.spending / this.divide).roundToDouble()) ?? 0}',
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            Divider(color: Colors.grey),
            Flexible(
              flex: 1,
              fit: FlexFit.loose,
              child: Align(
                alignment: Alignment.centerRight,
                child: LiteRollingSwitch(
                  textSize: 16,
                  animationDuration: Duration(milliseconds: 200),
                  value: this.needDisplayDaySpending,
                  colorOff: Colors.grey,
                  colorOn: Colors.blueAccent,
                  iconOff: FontAwesomeIcons.calendarAlt,
                  iconOn: FontAwesomeIcons.calendarDay,
                  onTap: () => setState(() => this.needDisplayDaySpending =
                      !this.needDisplayDaySpending),
                  onChanged: (bool state) {
                    print('changed state -- $state');
                    print('divide -- $divide');
                  },
                  // onChanged: (bool state) =>
                  //     setState(() => this.needDisplayDaySpending = state),
                  textOn: '日割り',
                  textOff: '総額',
                ),
              ),
            ),
            if (ApiUtil.shared.expensesList.isNotEmpty)
              Flexible(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _groupByUseType().isEmpty
                      ? Container()
                      : PieChart(
                          dataMap: this.eachSpending,
                          showLegends: false,
                          chartType: ChartType.disc,
                          showChartValuesInPercentage: true,
                          chartValueBackgroundColor: Colors.blue,
                          colorList: [
                            Color(0xff0293ee),
                            Color(0xfff8b250),
                            Color(0xff845bef),
                            Color(0xff13d38e),
                          ],
                        ),
                ),
              ),
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                color: Theme.of(context).primaryColor,
                child: Row(
                  children: <Widget>[
                    Text(
                      '内訳',
                      style: Theme.of(context)
                          .textTheme
                          .headline4
                          .copyWith(color: Colors.white),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    // Text(
                    //   '月選択',
                    //   style: Theme.of(context)
                    //       .textTheme
                    //       .headline6
                    //       .copyWith(color: Colors.white),
                    // ),
                    _buildDropdownButton(),
                  ],
                ),
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
                        if (this.eachSpending != null)
                          Text(
                              '￥${this.eachSpending.containsKey(UseType.templates[0].useType) ? (this.eachSpending[UseType.templates[0].useType] / this.divide).round() : 0}'),
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
                              '￥${this.eachSpending.containsKey(UseType.templates[1].useType) ? (this.eachSpending[UseType.templates[1].useType] / this.divide).round() : 0}'),
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
                              '￥${this.eachSpending.containsKey(UseType.templates[2].useType) ? (this.eachSpending[UseType.templates[2].useType] / this.divide).round() : 0}'),
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
                              '￥${this.eachSpending.containsKey(UseType.templates[3].useType) ? (this.eachSpending[UseType.templates[3].useType] / this.divide).round() : 0}'),
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
