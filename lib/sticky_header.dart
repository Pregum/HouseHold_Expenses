import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'api_util.dart';
import 'expenses.dart';
import 'household_edit_page.dart';

/// ヘッダとヘッダに付属するリストをまとめたウィジェットです。
class StickyHeader extends StatefulWidget {
  const StickyHeader(
      {Key key, @required this.headerText, @required this.expenses})
      : super(key: key);

  final String headerText;
  final List<Expenses> expenses;

  @override
  _StickyHeaderState createState() => _StickyHeaderState();
}

class _StickyHeaderState extends State<StickyHeader> {
  String _toString(DateTime date) {
    initializeDateFormatting('ja_JP');
    var formatter = DateFormat('yyyy年MM月dd日', 'ja_JP');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return SliverStickyHeader(
      header: Header(title: this.widget.headerText),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int i) => Dismissible(
            child: ListTile(
              title: Text('${this.widget.expenses[i].name}'),
              subtitle: Text('${_toString(this.widget.expenses[i].dateTime)}'),
              trailing: Text('￥ ${this.widget.expenses[i].yen}'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      HouseholdEditPage(this.widget.expenses[i]),
                ),
              ),
            ),
            background: Container(
              color: Colors.red,
              child: Center(
                child: ListTile(
                  leading: Icon(Icons.delete),
                ),
              ),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              child: Center(
                child: ListTile(
                  trailing: Icon(Icons.delete),
                ),
              ),
            ),
            onDismissed: (direction) {
              ApiUtil.shared.removeExpenses(this.widget.expenses[i]);
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('削除しました。'),
                ),
              );
            },
            key: UniqueKey(),
          ),
          childCount: this.widget.expenses.length,
        ),
      ),
    );
  }
}

/// ヘッダとなるウィジェット
class Header extends StatelessWidget {
  const Header({
    Key key,
    this.title,
    this.color = Colors.lightBlue,
  }) : super(key: key);

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: color,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      alignment: Alignment.centerLeft,
      child: Text(
        title ?? 'Header placeholder...',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
