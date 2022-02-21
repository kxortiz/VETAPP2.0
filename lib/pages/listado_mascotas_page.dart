import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vetapp/models/mascota_model.dart';
import 'package:vetapp/services/auth_service.dart';
import 'package:vetapp/services/firebase.dart';
import 'package:vetapp/services/mascotas_service.dart';
import 'package:vetapp/widgets/custom_input.dart';
import 'package:vetapp/widgets/main_button.dart';

class ListadoMascotas extends StatefulWidget {
  const ListadoMascotas({Key? key}) : super(key: key);

  @override
  State<ListadoMascotas> createState() => _ListadoMascotasState();
}

class _ListadoMascotasState extends State<ListadoMascotas> {
  
  //List<Mascota?>? mascotas;
  Stream<QuerySnapshot<Mascota>>? _streamMascotas;

  @override
  void initState() {
    _obtenerMascotas();
    super.initState();
  }

  void _obtenerMascotas () async {
    //final _mascotasService = Provider.of<MascotasService>(context);
    final _firebaseService = FirebaseService.fb;
    final _authService = Provider.of<AuthService>(context, listen: false);
    _streamMascotas = await _firebaseService.getMascotas(_authService.usuario!.id);
    //_mascotasService.
    //mascotas = documentsMascotas!.map((doc) => doc.data()).toList();
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {

    final _firebaseService = FirebaseService.fb;
    final _authService = Provider.of<AuthService>(context);
    
    return ChangeNotifierProvider(
      create: ( _ ) => MascotasService(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Listado de Mascotas"),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _streamMascotas == null
                      ? const Center(child: CircularProgressIndicator())
                      : StreamBuilder<QuerySnapshot<Mascota>>(
                        stream: _streamMascotas,
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Mascota>> snapshot){
                          if (snapshot.hasError) {
                            return const Text('Algo ha salido mal');
                          }
              
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Text("Cargando");
                          }
                          
                          final documentsMascotas = snapshot.data!.docs;
              
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: documentsMascotas.length,
                            itemBuilder: (BuildContext context, int index){
                              
                              final mascotaDocument = documentsMascotas[index];
                        
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: const BorderRadius.all(Radius.circular(7))
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Text("Nombre: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                        Text(mascotaDocument.data().nombre)
                                      ],
                                    ),
                                    Row(
                                      children: [
                                      InkWell(
                                        child: const Icon(Icons.delete, size: 15, color: Colors.red,), 
                                        onTap: () {
                                          showAlertDialog1(context, (){
                                            _firebaseService.deleteMascota(mascotaDocument.id);
                                            Navigator.pop(context);
                                          });
                                        },
                                      ), 
                                      const SizedBox(width: 10), 
                                      InkWell(
                                        child: const Icon(Icons.edit, size: 15, color: Colors.blue), 
                                        onTap: () {
                                          showAlertDialog(context, mascotaDocument, _firebaseService);
                                        },
                                      )  
                                      ],
                                    )
                                  ],
                                )
                              );
                            }
                          );
                        },
                        
                      )
                    ]
                  ),
                ),
              ),
              MainButton(
                text: "Agregar Mascota",
                onPressed: (){
                  showAlertDialog2(context, _firebaseService, _authService);
                },
              ),
              const SizedBox(height: 20)
            ],
            
          )
        ),
      ),
    );
  }
}

showAlertDialog(BuildContext context, QueryDocumentSnapshot<Mascota?> mascotaDocument, FirebaseService firebaseService) {

  final nameCtlr = TextEditingController(text: mascotaDocument.data()!.nombre);

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Row(
      children: [
        Icon(Icons.error_outline, size: 30, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        const Expanded (
          child: Text("Actualizar Nombre de la Mascota",  maxLines: 2, overflow: TextOverflow.ellipsis)
        )
      ],
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min, 
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20), 
        CustomInput(
          icon: Icons.favorite_sharp, 
          placeholder: "Nombre deL la Mascota", 
          textController: nameCtlr
        ),
        const SizedBox(height: 20),
        MainButton(
          text: "Actualizar",
          onPressed: () async{
            firebaseService.updateMascota(mascotaDocument.id, {"nombre": nameCtlr.text.trim()});
            Navigator.pop(context);
          }
        )
      ]
        
    )
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}


showAlertDialog1(BuildContext context, Function() onPressed) {


  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Row(
      children: [
        Icon(Icons.error_outline, size: 30, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        const Expanded (
          child: Text("Elliminar la Mascota",  maxLines: 2, overflow: TextOverflow.ellipsis)
        )
      ],
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min, 
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20), 

        const SizedBox(height: 20),
        MainButton(
          text: "Eliminar",
          onPressed: onPressed
        )
      ]
        
    )
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showAlertDialog2(BuildContext context, FirebaseService firebaseService, AuthService authService) {

  final nameCtlr = TextEditingController();
  
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Row(
      children: [
        Icon(Icons.error_outline, size: 30, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        const Expanded (
          child: Text("Agregar una Mascota",  maxLines: 2, overflow: TextOverflow.ellipsis)
        )
      ],
    ),
    content: Column(
        mainAxisSize: MainAxisSize.min, 
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Nombre de la Mascota"),
          CustomInput(
            icon: Icons.favorite_sharp, 
            placeholder: "Nombre", 
            textController: nameCtlr
          ),

          const SizedBox(height: 20),
          MainButton(
            text: "Agregar Mascota",
            onPressed: () async{

              if(nameCtlr.text.trim() == "") return;

              await firebaseService.addMascota(
                Mascota(
                  nombre: nameCtlr.text.trim(), 
                  vacunas: [], 
                  userId: authService.usuario!.id
                )
              );
              Navigator.pop(context);
            },
          )
        ],
      ),
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}