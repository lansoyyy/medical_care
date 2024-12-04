import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:medical_care/utils/const.dart';

Future addEvent(condition, medicine, duration, dosage, notes, hour, minutes,
    day, month, year) async {
  final docUser = FirebaseFirestore.instance.collection('Events').doc();

  final json = {
    'condition': condition,
    'medicine': medicine,
    'duration': duration,
    'dosage': dosage,
    'notes': notes,
    'id': docUser.id,
    'dateTime': DateTime.now(),
    'type': 'Pending',
    'hour': hour,
    'minutes': minutes,
    'day': day,
    'month': month,
    'year': year
  };

  await docUser.set(json);
}
