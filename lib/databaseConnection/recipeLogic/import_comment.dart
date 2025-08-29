import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  static const userNameKey = 'userName';
  static const textKey = 'text';
  static const timestampKey = 'timestamp';
  static const userIdKey = 'userId';

  final String userName;
  final String text;
  final DateTime timestamp;
  final String userId;

  Comment({
    required this.userName,
    required this.text,
    required this.timestamp,
    required this.userId,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      userName: map[userNameKey],
      text: map[textKey],
      timestamp: (map[timestampKey] as Timestamp).toDate(),
      userId: map[userIdKey],
    );
  }

  Map<String, dynamic> toMap() => {
        userNameKey: userName,
        textKey: text,
        timestampKey: timestamp,
        userIdKey: userId,
      };
}
