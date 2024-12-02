import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:medical_care/utils/const.dart';

Future addUser(name, email) async {
  final docUser = FirebaseFirestore.instance.collection('Users').doc(userId);

  final json = {
    'name': name,
    'email': email,
    'id': docUser.id,
    'isVerified': false,
    'favs': [],
    'profile': '',
    'userType': 'User',
  };

  await docUser.set(json);
}
