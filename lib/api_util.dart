import 'package:firebase_database/firebase_database.dart';
import 'expenses.dart';

class ApiUtil {
  static ApiUtil shared = ApiUtil();
  final mainReference = FirebaseDatabase.instance.reference().child('db-top');
  List<Expenses> expensesList = <Expenses>[];

  ApiUtil() {
    mainReference.onChildAdded.listen(_onExpensesAdded);
    mainReference.onChildRemoved.listen(_onExpensesDelete);
  }

  void pushExpenses(Expenses expenses) {
    mainReference.push().set(expenses.toJson());
  }

  void removeExpenses(Expenses expenses) {
    mainReference.child(expenses.key).remove();
  }

  void _onExpensesAdded(Event event) {
    expensesList.add(Expenses.fromSnapshot(event.snapshot));
  }

  void _onExpensesDelete(Event event) {
    expensesList.removeWhere((data) => data.key == event.snapshot.key);
  }
}
