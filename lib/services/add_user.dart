import 'package:cloud_firestore/cloud_firestore.dart';

Future addUser(name, email, userId) async {
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
