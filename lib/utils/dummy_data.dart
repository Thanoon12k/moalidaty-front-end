import 'package:moalidaty1/features/reciepts/models/model.dart';
import 'package:moalidaty1/features/subscripers/models/model.dart';

class DummyData {
  static Subscriper sub1 = Subscriper(
    id: 1,
    name: "احمد",
    amber: 3,
    circuit_number: "12",
    phone: "0771",
  );
  static Subscriper sub2 = Subscriper(
    id: 1,
    name: "حميد",
    amber: 5,
    circuit_number: "12",
    phone: "0771",
  );

  static Reciept rec1 = Reciept(
    date: DateTime(2025, 7),
    subscriper: sub1,
    amber_price: 5000,
    amount_paid: 40000,
  );
  static Reciept rec2 = Reciept(
    date: DateTime(2025, 8),
    subscriper: sub1,
    amber_price: 5000,
    amount_paid: 40000,
  );
  static Future<List<Reciept>> getDummyReciepts() async {
    Future.delayed(Duration(seconds: 2), () {
      return [rec1, rec2];
    });
    return [rec1, rec2];
  }

  static Future<List<Subscriper>> getDummySubs() async {
    Future.delayed(Duration(seconds: 2), () {
      return [sub1, sub2];
    });
    return [sub1, sub2];
  }
}
