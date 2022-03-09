
import 'dart:io';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'package:vetapp/models/admin_model.dart';
import 'package:vetapp/models/cita_model.dart';
import 'package:vetapp/models/fecha_model.dart';
import 'package:vetapp/models/mascota_model.dart';


class FirebaseService {

  static final FirebaseService fb = FirebaseService._();
  FirebaseService._();

  static CollectionReference<Cita>? _citas;
  static CollectionReference<Admin>? _admins;
  static CollectionReference<Mascota>? _mascotas;
  
  firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
  //firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref();

  CollectionReference<Mascota> get mascotas {
    if ( _mascotas != null ) return _mascotas!;

    _mascotas = FirebaseFirestore.instance.collection('mascotas').withConverter<Mascota>(
      fromFirestore: (snapshot, _) => Mascota.fromJson(snapshot.data()!), 
      toFirestore: (mascota, _) => mascota.toJson(),
    );
    return _mascotas!;
  }

  CollectionReference<Cita> get citas {
    if ( _citas != null ) return _citas!;

    _citas = FirebaseFirestore.instance.collection('citas').withConverter<Cita>(
      fromFirestore: (snapshot, _) => Cita.fromJson(snapshot.data()!), 
      toFirestore: (cita, _) => cita.toJson(),
    );
    return _citas!;
  }

// ************************ Funciones de Firebase ******************************

  // Funcion que retorna todos lo administradores de la aplicación
  CollectionReference<Admin> get admins {
    if ( _admins != null ) return _admins!;

    _admins = FirebaseFirestore.instance.collection('admins').withConverter<Admin>(
      fromFirestore: (snapshot, _) => Admin.fromJson(snapshot.data()!), 
      toFirestore: (admin, _) => admin.toJson(),
    );
    return _admins!;
  }


  // Función que guarda una imagen
  Future<String?> saveImage(File filename) async {
    try {
      String fileName = basename(filename.path);
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref('images/$fileName');
      await ref.putFile(filename); 
      return ref.getDownloadURL();

    } catch (e) {
      return null;
    }
  }


  // Función que consulta la cita de una fecha dada
  Stream<QuerySnapshot<Cita>>? consultarCitasFecha(){
    
    final _currentDate = DateTime.now();
    final _dayFormatter = DateFormat('d');
    final _monthFormatter = DateFormat('MMM');
    final fechaBuscar = Fecha(_dayFormatter.format(_currentDate), _monthFormatter.format(_currentDate));
    try {
      Query<Cita> listCitasHoy = citas.where("dia", isEqualTo: "${fechaBuscar.month},${fechaBuscar.day}");
      //Query<Cita> listCitasHoy = citas.where("dia", isEqualTo: "20,Feb");
      return listCitasHoy.snapshots();

    } catch (e) { 
      return null;
    }
  }

  // Función que consulta la cita de una fecha dada
  Stream<QuerySnapshot<Cita>>? consultarCitasSemana(){
    
    final _currentDate = DateTime.now();
    final _dayFormatter = DateFormat('d');
    final _monthFormatter = DateFormat('MMM');
    
    final fechas = <Fecha>[];

    for (int i = 0; i < 5; i++) {
      final fecha = _currentDate.add(Duration(days: -i));
      fechas.add(Fecha(_dayFormatter.format(fecha), _monthFormatter.format(fecha)));
    }

    final fechasQuery = [];
    for (Fecha fecha in fechas) {
      //final fechai = Fecha(_dayFormatter.format(_currentDate), _monthFormatter.format(_currentDate));
      fechasQuery.add("${fecha.month},${fecha.day}");
    }
    print("a");
    print(fechasQuery);
    print("a");

    final fechaBuscar = Fecha(_dayFormatter.format(_currentDate), _monthFormatter.format(_currentDate));
    print("${fechaBuscar.month},${fechaBuscar.day}");
    try {
      //Query<Cita> listCitasHoy = citas.where("dia", isEqualTo: "${fechaBuscar.month},${fechaBuscar.day}");
      Query<Cita> listCitasHoy = citas.where("dia", whereIn: fechasQuery).orderBy('createdAt', descending: false);
      //Query<Cita> listCitasHoy = citas.where("dia", isEqualTo: "20,Feb");
      return listCitasHoy.snapshots();

    } catch (e) { 
      return null;
    }
  }


  // Función que retorna una Lista de Mascotas del Usuario
  Stream<QuerySnapshot<Mascota>>?  getMascotas(String userId){
    try {
      Query<Mascota> usuarioMascotas = mascotas.where('userId', isEqualTo: userId);
      return usuarioMascotas.snapshots();
      // for (var mascota1 in usuarioMascotas.docs) {
      //   print(mascota1.id);
      // }
      //List<Mascota?> listMascotas = usuarioMascotas.docs.map((doc) => doc.data()).toList();
    } catch (e) { 
      return null;
    }
  }

  // Función que agrega una mascota del usuario
  Future <String> addMascota(Mascota mascotaSave) async{
    try {
      DocumentReference mascota = await mascotas.add(mascotaSave);
      return mascota.id;
    } catch (e) {
      print("aaaaaaaa");
      print(e);
      print("aaaaaaaa");
      return "Error"; 
    }
  }



  // Función que actualiza una mascota del usuario
  Future <String> updateMascota(String idMascota, Map<String, Object?> mascotaSave) async{
    try {
      await mascotas.doc(idMascota).update(mascotaSave);
      return "Exito";
    } catch (e) {
      print(e);
      return "Error"; 
    }
  }

  // Función que borra una mascota de un usuario

  Future <String> deleteMascota(String idMascota) async{
    try {
      await mascotas.doc(idMascota).delete();
      return "Exito";
    } catch (e) {
      return "Error"; 
    }
  }

  // Función que retorna si un usario es administrador
  Future <bool> getAdmin(String userId) async{
    try {
      DocumentSnapshot<Admin> usuarioAdmin = await admins.doc(userId).get();
      if (usuarioAdmin.exists) return(true);
      return false;
    } catch (e) { 
      return false;
    }
  }

  // Función que agrega una cita
  Future <String> addCita(Cita citaSave) async{
    try {
      DocumentReference cita = await citas.add(citaSave);
      return cita.id;
    } catch (e) {
      
      return "Error"; 
    }
  }

  // Función que consulta todas las citas del usuario
  Future <List<Cita?>> consultarCitas() async{
    try {
      QuerySnapshot<Cita?> citasResult = await citas.get();
      List<Cita?> listCitas = citasResult.docs.map((doc) => doc.data()).toList();
      return listCitas;

    } catch (e) {
      return [];
    }
  }

  

  // Función que consulta solo una cita mediante su ID
  Future <Cita?> consultarCita(String id) async {
    try {
      DocumentSnapshot<Cita> citaResult =  await citas.doc(id).get();
      return citaResult.data();
    } catch (e) {
      return null;
    }
  }
}