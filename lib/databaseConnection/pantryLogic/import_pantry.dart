import 'package:cloud_firestore/cloud_firestore.dart';

class Pantry {
  List<DateTime> expireDates;
  List<String> ingredientIds;
  String userId;
  List<int> weights;
  List<DateTime> notificationDates;

  Pantry(this.expireDates, this.ingredientIds, this.userId, this.weights, this.notificationDates);

  static toMap(Pantry pantry) {
    List<Timestamp> timestampList = pantry.expireDates.map((date) => Timestamp.fromDate(date)).toList();
    List<Timestamp> notificationList = pantry.notificationDates.map((date) => Timestamp.fromDate(date)).toList();
    return {
      "expireDates": timestampList,
      "ingredientIds": pantry.ingredientIds,
      "userId": pantry.userId,
      "weights": pantry.weights,
      "notificationDates": notificationList,
    };
  }
  
  factory Pantry.fromMap(Map<String, dynamic> map) {
    List<DateTime> expireDates = List<DateTime>.from(map['expireDates']?.map((x) => (x as Timestamp).toDate()) ?? []);
    List<String> ingredientIds = List<String>.from(map['ingredientIds'] ?? []);
    List<int> weights = (map['weights'] as List<dynamic>?)
        ?.map((e) => (e as num).toInt())
        .toList() ?? [];
    List<DateTime> notificationDates = List<DateTime>.from(map['notificationDates']?.map((x) => (x as Timestamp).toDate()) ?? []);

    return Pantry(
      expireDates,
      ingredientIds,
      map['userId'] as String,
      weights,
      notificationDates,
    );
  }
  
  void addItem(DateTime expireDate, String ingredientId, int weight, DateTime notificationDate) {
    expireDates.add(expireDate);
    ingredientIds.add(ingredientId);
    weights.add(weight);
    notificationDates.add(notificationDate);
  }
  
  void removeItemAt(int index) {
    if (index >= 0 && index < ingredientIds.length) {
      expireDates.removeAt(index);
      ingredientIds.removeAt(index);
      weights.removeAt(index);
      notificationDates.removeAt(index);
    }
  }

  void insertItemAt(int index, DateTime date, String id, int weight, DateTime notificationDate) {
    if (index >= 0 && index <= ingredientIds.length) {
      ingredientIds.insert(index, id);
      weights.insert(index, weight);
      expireDates.insert(index, date);
      notificationDates.insert(index, notificationDate);
      }
  }

  void updateItemAt(int index, DateTime expireDate, String ingredientId, int weight, DateTime notificationDate) {
    if (index >= expireDates.length || index >= ingredientIds.length || index >= weights.length) return;

    expireDates[index] = expireDate;
    ingredientIds[index] = ingredientId;
    weights[index] = weight;
    notificationDates[index] = notificationDate;
  }

  
  int get itemCount => ingredientIds.length;
}