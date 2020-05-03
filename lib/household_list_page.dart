import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:household_expenses/api_util.dart';
import 'household_add_page.dart';
import 'scaffold_base.dart';

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
            child: ListView.separated(
              itemBuilder: (context, index) => Dismissible(
                child: ListTile(
                  title: Text('${ApiUtil.shared.expensesList[index].name}'),
                  trailing: Text('￥ ${ApiUtil.shared.expensesList[index].yen}'),
                ),
                background: Container(
                  color: Colors.red,
                  child: ListTile(
                    leading: Icon(Icons.delete),
                  ),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  child: ListTile(
                    trailing: Icon(Icons.delete),
                  ),
                ),
                onDismissed: (direction) {
                  ApiUtil.shared
                      .removeExpenses(ApiUtil.shared.expensesList[index]);
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text('削除しました。'),
                    ),
                  );
                },
                key: UniqueKey(),
              ),
              separatorBuilder: (BuildContext context, int index) => Divider(
                color: Colors.black,
              ),
              itemCount: ApiUtil.shared.expensesList.length,
            ),
          ),
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.center,
              child: Container(),
              // child: RaisedButton(
              //   textColor: Colors.white,
              //   child: Text("削除"),
              //   color: Colors.redAccent,
              //   shape: StadiumBorder(),
              //   onPressed: () {},
              // ),
            ),
          ),
        ],
      ),
    );
  }
}
