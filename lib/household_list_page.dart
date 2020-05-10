import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'api_util.dart';
import 'expenses.dart';
import 'household_add_page.dart';
import 'scaffold_base.dart';
import 'sticky_header.dart';

class HouseholdListPage extends StatefulWidget {
  @override
  _HouseholdListPageState createState() => _HouseholdListPageState();
}

class _HouseholdListPageState extends State<HouseholdListPage> {
  List<bool> isChecked =
      List<bool>.generate(ApiUtil.shared.expensesList.length, (i) => false);

  @override
  void initState() {
    super.initState();

    ApiUtil.shared.mainReference.onChildAdded.listen(_onAdded);
    ApiUtil.shared.mainReference.onChildRemoved.listen(_onRemoved);
  }

  void _onAdded(Event event) {
    setState(() {
      isChecked.add(false);
    });
  }

  void _onRemoved(Event event) {
    setState(() {
      isChecked.removeLast();
    });
  }

  String _toString(DateTime date) {
    initializeDateFormatting('ja_JP');
    var formatter = DateFormat('yyyy年MM月dd日', 'ja_JP');
    return formatter.format(date);
  }

  Map<DateTime, List<Expenses>> _groupByDateTime() {
    var newMap =
        groupBy(ApiUtil.shared.expensesList, (Expenses obj) => obj.dateTime)
            .map((k, v) => MapEntry(k, v.map((item) => item).toList()));
    return newMap;
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldBase(
      title: "記入一覧",
      fab: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => HouseholdAddPage())),
      ),
      child: Column(
        children: <Widget>[
          Flexible(
            flex: 1,
            child: ListTile(
              title: Text('項目名'),
              trailing: Text('金額'),
            ),
          ),
          Divider(
            color: Colors.black,
          ),
          Flexible(
            flex: 5,
            child: CustomScrollView(
              slivers: _groupByDateTime()
                  .entries
                  .map((entry) => StickyHeader(
                      expenses: entry.value, headerText: _toString(entry.key)))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
