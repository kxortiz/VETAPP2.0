import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
        body: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Text("Agrega las vacunas que hayas admnistrado a tu mascota:"),
            ),
            const SizedBox(height: 20),
            _FormAgregarVacuna(mascotaDocument: mascotaDocument),
            const SizedBox(height: 40)
          ],
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

    Intl.defaultLocale = 'es';      // Para configurar las fechas a español

    vacunasUpdate = widget.mascotaDocument.data().vacunas;
  }

  @override
  Widget build(BuildContext context) {

    final _firebaseService = FirebaseService.fb;

    List<String> vacunasOpciones = ["Rabia", "Parásitos", "Vacuna contra parvovirus", "Vacuna contra el distemper", "Vacuna contra la hepatitis infecciosa canina o adenovirus canino 2 (AVC-2)","Vacuna contra la leptospirosis",];
    
    //initializeDateFormatting();
    
    return Expanded(
      child: ListView.builder(
        itemCount: vacunasOpciones.length,
        itemBuilder: (BuildContext context, int index){
    
          final opcionVacuna = vacunasOpciones[index];
    
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(        
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(top: 6, bottom: 6, right: 10),
                      child: Checkbox(
                        value: (vacunasUpdate.indexWhere((element) => element["vacuna"] == opcionVacuna) >= 0),

                        onChanged: (bool? value){
                          if(vacunasUpdate.indexWhere((element) => element["vacuna"] == opcionVacuna) >= 0){
                            // Quitar la vacuna de la Lista
                            setState(() {
                              vacunasUpdate.removeAt(vacunasUpdate.indexWhere((element) => element["vacuna"] == opcionVacuna));
                              _firebaseService.updateMascota(widget.mascotaDocument.id, {"vacunas": vacunasUpdate});
                            });
                          }else{
                            // Agregar una vacuna a la Lista
                            setState(() {
                              vacunasUpdate.add(
                                {
                                  "vacuna": opcionVacuna,
                                  "fecha": new DateTime.now().microsecondsSinceEpoch
                                }
                              );
                                
                              _firebaseService.updateMascota(widget.mascotaDocument.id, {"vacunas": vacunasUpdate});
                            });
                          }
                        }
                      ),
                    ),
                    Expanded(
                      child: Text(
                        opcionVacuna, 
                        overflow: TextOverflow.ellipsis, 
                        maxLines: 2,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    )
                  ],
                ),
              ),
              (vacunasUpdate.indexWhere((element) => element["vacuna"] == opcionVacuna) >= 0) ?

                Padding(
                  padding: EdgeInsets.only(left: 80, top: 4),
                  child: DateTimePicker(
                    locale: Locale('es', ''), 
                    cancelText: "CANCELAR",
                    calendarTitle: "Fecha de la Vacuna",
                    type: DateTimePickerType.date,
                    dateMask: 'd MMM, yyyy',
                    initialValue: DateTime.now().toString(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.event),
                      labelText: "Fecha de la Vacuna"
                    ),
                    //onSaved: (val) => print(val),
                    onChanged: (val){
                      vacunasUpdate.removeAt(vacunasUpdate.indexWhere((element) => element["vacuna"] == opcionVacuna));
                      vacunasUpdate.add(
                        {
                          "vacuna": opcionVacuna,
                          "fecha": DateTime.parse(val).microsecondsSinceEpoch
                        }
                      );
                        
                      _firebaseService.updateMascota(widget.mascotaDocument.id, {"vacunas": vacunasUpdate});
                    },
                  ),
                )
              : SizedBox.shrink(),

              const Divider(thickness: 4),

            ],
          );
        }
      ),
    );
  }
}