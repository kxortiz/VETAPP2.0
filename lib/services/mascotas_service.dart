

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:vetapp/models/mascota_model.dart';

class MascotasService with ChangeNotifier {

  List<QueryDocumentSnapshot<Mascota?>> _mascotasList = [];
  List<QueryDocumentSnapshot<Mascota?>> get mascotasList => _mascotasList;
  set mascotasList ( List<QueryDocumentSnapshot<Mascota?>> value ) {
    _mascotasList = value;
    notifyListeners();
  }
}