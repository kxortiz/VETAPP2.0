import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vetapp/models/cita_model.dart';
import 'package:vetapp/services/firebase.dart';
import 'package:vetapp/utils/my_colors.dart';

class ConsultarCitaPage extends StatefulWidget {
  const ConsultarCitaPage({Key? key}) : super(key: key);

  @override
  State<ConsultarCitaPage> createState() => _ConsultarCitaPageState();
}

class _ConsultarCitaPageState extends State<ConsultarCitaPage> {

  //List<Cita?>? citas;
  Stream<QuerySnapshot<Cita>>? _streamCitas;


  @override
  void initState() {
    _obtenerCitas();
    super.initState();
  }

  void _obtenerCitas () async {
    final _firebaseService = FirebaseService.fb;
    //citas = await _firebaseService.consultarCitas();
    _streamCitas = _firebaseService.consultarCitasFecha();
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Citas de Hoy"),
        ),
        body: Column(
          children: [
            SizedBox(height: 20),
            StreamBuilder<QuerySnapshot<Cita>>(
              stream: _streamCitas,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Cita>> snapshot){
                if (snapshot.hasError) {
                  return const Text('Algo ha salido mal');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("Cargando");
                }

                final documentsCitasHoy = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: documentsCitasHoy.length,
                  itemBuilder: (BuildContext context, int index){
                    
                    final citaDocument = documentsCitasHoy[index];
                    final cita = citaDocument.data();

                    return InkWell(

                      onTap: (() => showAlertDialog(context, cita)),

                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: const BorderRadius.all(Radius.circular(7))
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cita.nombre),
                                Text(cita.correo),
                              ],
                            ),
                            Row(
                              children: [
                                Column(
                                  children: [
                                    const Text("Fecha:", style: TextStyle(fontWeight: FontWeight.bold),),
                                    Text('${cita.dia.split(",")[0]} ${cita.dia.split(",")[1]}')
                                  ],
                                ),
                                SizedBox(width: 30),
                                Column(
                                  children: [
                                    const Text("Hora:", style: TextStyle(fontWeight: FontWeight.bold),),
                                    Text('${cita.hora.split(",")[0]}:${cita.hora.split(",")[1]}')
                                  ],
                                )
                              ],
                            ),
                          ],
                        )
                      ),
                    );
                  }
                );
              },
            ),
          ],
        )
      ),
    );
  }
}

showAlertDialog(BuildContext context, Cita cita) {

  AlertDialog alert = AlertDialog(
    insetPadding: EdgeInsets.all(10),
    title: Row(
      children: [
        Icon(Icons.date_range, size: 30, color: MyColors.primaryColor),
        const SizedBox(width: 10),
        const Expanded (
          child: Text("Datos de la Cita",  maxLines: 2, overflow: TextOverflow.ellipsis)
        )
      ],
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min, 
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("Mascota: ", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(cita.nombre), 
          ],
        ),
        Row(
          children: [
            Text("Correo: ", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(cita.correo), 
          ],
        ),
        Row(
          children: [
            Text("Hora: ", style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${cita.hora.split(",")[0]}:${cita.hora.split(",")[1]}')
          ],
        ),
        Row(
          children: [
            Text("Fecha: ", style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${cita.dia.split(",")[0]} ${cita.dia.split(",")[1]}')
          ],
        ),
      ]   
    ),
    actions: [
      Align(
        alignment: Alignment.topCenter,
        child: ElevatedButton(
          onPressed: (){
            Navigator.pop(context);
          }, 
          child: Text("Ok")
        ),
      )
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}