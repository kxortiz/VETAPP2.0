import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vetapp/models/mascota_model.dart';
import 'package:vetapp/services/firebase.dart';

class AgregarVacunaPage extends StatelessWidget {
  const AgregarVacunaPage({
    required this.mascotaDocument,
    Key? key
  }) : super(key: key);

  final QueryDocumentSnapshot<Mascota> mascotaDocument;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Agregar Vacuna"),
          
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text("Agrega las vacunas que hayas admnistrado a tu mascota:"),
              const SizedBox(height: 20),
              _FormAgregarVacuna(mascotaDocument: mascotaDocument),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormAgregarVacuna extends StatefulWidget {
  const _FormAgregarVacuna({
    required this.mascotaDocument,
    Key? key,
  }) : super(key: key);

  final QueryDocumentSnapshot<Mascota> mascotaDocument;

  @override
  State<_FormAgregarVacuna> createState() => _FormAgregarVacunaState();
}

class _FormAgregarVacunaState extends State<_FormAgregarVacuna> {

  bool isChecked = false;
  List vacunasUpdate = [];
  
  @override
  void initState() {
    super.initState();
    vacunasUpdate = widget.mascotaDocument.data().vacunas;
  }

  @override
  Widget build(BuildContext context) {

    final _firebaseService = FirebaseService.fb;

    List<String> vacunasOpciones = ["Rabia", "Parásitos", "Peste Negra", "Covid", "Viruela"];
    
    return Expanded(
      child: ListView.builder(
        itemCount: vacunasOpciones.length,
        itemBuilder: (BuildContext context, int index){
    
          final opcionVacuna = vacunasOpciones[index];
    
          return Row(
            children: [
              Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(top: 4, bottom: 4, right: 10),
                child: Checkbox(
                  value: (vacunasUpdate.contains(opcionVacuna)), 
                  onChanged: (bool? value){
                    if(vacunasUpdate.contains(opcionVacuna)){
                      // Quitar la vacuna de la Lista
                      setState(() {
                        vacunasUpdate.remove(opcionVacuna);
                        _firebaseService.updateMascota(widget.mascotaDocument.id, {"vacunas": vacunasUpdate});
                      });
                    }else{
                      // Agregar una vacuna a la Lista
                      setState(() {
                        vacunasUpdate.add(opcionVacuna);
                        _firebaseService.updateMascota(widget.mascotaDocument.id, {"vacunas": vacunasUpdate});
                      });
                    }
                  }
                ),
              ),
              Text(opcionVacuna)
            ],
          );
        }
      ),
    );

    // return Checkbox(
    //   checkColor: Colors.white,
    //   value: isChecked,
    //   onChanged: (bool? value) {
    //     setState(() {
    //       isChecked = value!;
    //     });
    //   },
    // );
  }
}