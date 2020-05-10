import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'use_type.dart';
import 'api_util.dart';
import 'expenses.dart';

class HouseholdEditPage extends StatefulWidget {
  Expenses _expenses;

  HouseholdEditPage(this._expenses) : assert(_expenses != null);

  @override
  _HouseholdEditPageState createState() => _HouseholdEditPageState(_expenses);
}

class _HouseholdEditPageState extends State<HouseholdEditPage> {
  Expenses _expenses;
  String get _name => _expenses.name;
  set _name(String value) => _expenses.name = value;
  DateTime get _date => _expenses.dateTime;
  set _date(DateTime value) => _expenses.dateTime = value;
  String get _formatedDate {
    initializeDateFormatting('ja_JP');
    var formatter = DateFormat('yyyy年MM月dd日', 'ja_JP');
    return formatter.format(_date);
  }

  _HouseholdEditPageState(Expenses expenses) {
    _expenses = Expenses(
        expenses.name, expenses.dateTime, expenses.useType, expenses.yen);
    _expenses.key = expenses.key;
  }

  /// 3桁ごとにカンマで区切った金額
  String get _yenSplitedComma {
    // ref: https://qiita.com/koizumiim/items/5cc0f68d224b2cc949ba
    final formatter = NumberFormat('#,###');
    return formatter.format(_yen);
  }

  UseType get _useType => _expenses.useType;
  set _useType(UseType value) => _expenses.useType;
  int get _yen => _expenses.yen;
  set _yen(int value) => _expenses.yen = value;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('編集 -- ${_expenses.key}'),
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
                      // Text("${_useType.useType}"),
                      _buildDropdownButton(_useType),
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
                child: Text('変更'),
                color: Colors.blue,
                shape: StadiumBorder(),
                onPressed: () {
                  print('update... ${this._expenses}');
                  this.widget._expenses.name = this._expenses.name;
                  this.widget._expenses.dateTime = this._expenses.dateTime;
                  this.widget._expenses.useType = this._expenses.useType;
                  this.widget._expenses.yen = this._expenses.yen;
                  ApiUtil.shared.update(this._expenses);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 使用用途の選択を行います。
  Widget _buildDropdownButton(UseType useType) {
    return DropdownButton<UseType>(
      value: useType ?? UseType.templates[0],
      hint: const Text('使用用途'),
      onChanged: (UseType newValue) {
        setState(() {
          this._expenses.useType = newValue;
        });
      },
      items: UseType.templates.map<DropdownMenuItem<UseType>>((UseType value) {
        return DropdownMenuItem(
          child: Text(value.useType),
          value: value,
        );
      }).toList(),
    );
  }
}
