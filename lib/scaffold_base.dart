import 'package:flutter/material.dart';
import 'package:household_expenses/main.dart';
import 'household_list_page.dart';

/// ベースとなる土台
class ScaffoldBase extends StatelessWidget {
  /// タイトル
  final String title;

  /// 表示されるWidget
  final Widget child;

  /// FloatingActionButton(右下に表示されるあれ)
  final Widget fab;

  /// ctor
  ScaffoldBase({Key key, this.title, this.child, this.fab})
      : assert(child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.title),
      ),
      floatingActionButton: fab,
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: Text(
                'メニュー',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text("ダッシュボード"),
              onTap: () {
                // print("ダッシュボード");
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => TopPage()));
              },
            ),
            ListTile(
              title: Text("記入一覧"),
              onTap: () {
                print("on tap 記入一覧");
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => HouseholdListPage()));
              },
            ),
          ],
        ),
      ),
      body: child,
    );
  }
}
