import 'package:flutter/material.dart';
import 'scaffold_base.dart';

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

  @override
  Widget build(BuildContext context) {
    return ScaffoldBase(
      title: "ダッシュボード",
      child: Center(
        child: Container(
        ),
      ),
    );
  }
}
