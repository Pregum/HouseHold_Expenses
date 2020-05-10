import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

import 'use_type.dart';

class Expenses {
  String key;
  String name;
  DateTime dateTime;
  UseType useType;
  int yen;

  Expenses(this.name, this.dateTime, this.useType, this.yen);

  Expenses.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        name = snapshot.value['name'],
        dateTime = DateTime.parse(snapshot.value['datetime']),
        useType = UseType(
            id: UseType.templates.firstWhere((UseType useType) {
              return useType.useType == snapshot.value['use-type'];
            }, orElse: () => UseType.templates[0]).id,
            useType: snapshot.value['use-type']),
        yen = int.tryParse(snapshot.value['yen']) ?? -100;

  Map<String, Object> toJson() {
    var formatter = DateFormat('yyyyMMdd');
    return {
      'name': name,
      'use-type': useType.useType,
      'yen': yen.toString(),
      'datetime': formatter.format(dateTime),
    };
  }
}
