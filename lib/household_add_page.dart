import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'use_type.dart';
import 'api_util.dart';
import 'expenses.dart';

class HouseholdAddPage extends StatefulWidget {
  @override
  _HouseholdAddPageState createState() => _HouseholdAddPageState();
}

class _HouseholdAddPageState extends State<HouseholdAddPage> {
  String _name = "スライスチーズ";
  DateTime _date = DateTime.now();
  String get _formatedDate {
    initializeDateFormatting('ja_JP');
    var formatter = DateFormat('yyyy年MM月dd日', 'ja_JP');
    return formatter.format(_date);
  }

  /// 3桁ごとにカンマで区切った金額
  String get _yenSplitedComma {
    // ref: https://qiita.com/koizumiim/items/5cc0f68d224b2cc949ba
    final formatter = NumberFormat('#,###');
    return formatter.format(_yen);
  }

  UseType _useType = UseType.templates.first;
  int _yen = 0;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('追加'),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            flex: 6,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      initialValue: _name,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '項目名を入力してください。',
                        labelText: '項目名',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return '必須です。';
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          _name = val;
                        });
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text("日付"),
                      // Text("$_formatedDate"),
                      RaisedButton(
                        child: Text('$_formatedDate'),
                        onPressed: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: _date ?? DateTime.now(),
                            firstDate: DateTime(DateTime.now().year),
                            lastDate: DateTime(DateTime.now().year + 1),
                          );

                          if (selectedDate != null) {
                            setState(() => _date = selectedDate);
                          }
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text("使用用途"),
                      Text("${_useType.useType}"),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text("金額"),
                      Text("￥$_yenSplitedComma"),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: <Widget>[
              // 金額設定ボタン

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                    child: Text("+1"),
                    color: Colors.blue,
                    shape: StadiumBorder(),
                    onPressed: () => setState(() => _yen++),
                  ),
                  RaisedButton(
                    child: Text("+10"),
                    color: Colors.blue,
                    shape: StadiumBorder(),
                    onPressed: () => setState(() => _yen += 10),
                  ),
                  RaisedButton(
                    child: Text("+100"),
                    color: Colors.blue,
                    shape: StadiumBorder(),
                    onPressed: () => setState(() => _yen += 100),
                  ),
                  RaisedButton(
                    child: Text("+1000"),
                    color: Colors.blue,
                    shape: StadiumBorder(),
                    onPressed: () => setState(() => _yen += 1000),
                  ),
                ],
              ),
              Align(
                  alignment: Alignment.center,
                  child: RaisedButton(
                    child: Text('AC'),
                    color: Colors.grey,
                    onPressed: () => setState(() => _yen = 0),
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                    child: Text("-1"),
                    color: Colors.red,
                    shape: StadiumBorder(),
                    onPressed: () => setState(() => _yen = max(_yen - 1, 0)),
                  ),
                  RaisedButton(
                    child: Text("-10"),
                    color: Colors.red,
                    shape: StadiumBorder(),
                    onPressed: () => setState(() => _yen = max(_yen - 10, 0)),
                  ),
                  RaisedButton(
                    child: Text("-100"),
                    color: Colors.red,
                    shape: StadiumBorder(),
                    onPressed: () => setState(() => _yen = max(_yen - 100, 0)),
                  ),
                  RaisedButton(
                    child: Text("-1000"),
                    color: Colors.red,
                    shape: StadiumBorder(),
                    onPressed: () => setState(() => _yen = max(_yen - 1000, 0)),
                  ),
                ],
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              height: 50,
              margin: EdgeInsets.all(10.0),
              child: RaisedButton(
                child: Text('追加'),
                color: Colors.blue,
                shape: StadiumBorder(),
                onPressed: () {
                  ApiUtil.shared
                      .pushExpenses(Expenses(_name, _date, _useType, _yen));
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
