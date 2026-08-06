import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  final db = FirebaseFirestore.instance;
  final cSnap = await db.collection('courses').get();
  
  for (var doc in cSnap.docs) {
    print('Course: ${doc.data()['title']}');
    print('CreatedAt: ${doc.data()['createdAt']}');
  }
}
