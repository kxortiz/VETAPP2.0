import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vetapp/models/mascota_model.dart';
import 'package:vetapp/pages/agregar_mascota_page.dart';
import 'package:vetapp/services/auth_service.dart';
import 'package:vetapp/services/firebase.dart';
import 'package:vetapp/services/mascotas_service.dart';
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
    final _firebaseService = FirebaseService.fb;
    final _authService = Provider.of<AuthService>(context, listen: false);
    _streamMascotas = await _firebaseService.getMascotas(_authService.usuario!.id);
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    
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
                child: SingleChildScrollView(
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
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: documentsMascotas.length,
                              itemBuilder: (BuildContext context, int index){
                                
                                final mascotaDocument = documentsMascotas[index];
                                final mascota = mascotaDocument.data();
                          
                                return _MascotaCard(mascota: mascota, mascotaDocument: mascotaDocument);
                              }
                            );
                          },
                          
                        )
                      ]
                    ),
                  ),
                ),
              ),

              MainButton(
                text: "Agregar Mascota",
                onPressed: (){
                  //showAlertDialog2(context, _firebaseService, _authService);
                
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => AgregarMascotaPage())
                  );
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

class _MascotaCard extends StatelessWidget {
  const _MascotaCard({
    Key? key,
    required this.mascota,
    required this.mascotaDocument,
  }): super(key: key);

  final Mascota mascota;
  final QueryDocumentSnapshot<Mascota> mascotaDocument;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        margin: const EdgeInsets.only(top: 30, bottom: 10),
        width: double.infinity,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0,7),
              blurRadius: 10
            )
          ]
        ),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            _BackgroundImage( mascota.image ),

            _NombreMascota(nombre: mascota.nombre),
            
            Positioned(
              top: 0,
              right: 0,
              child: _ButtonDelete(mascotaDocument: mascotaDocument)
            ),

          ],
        ),

        //           const SizedBox(width: 10), 
        //           InkWell(
        //             child: const Icon(Icons.edit, size: 15, color: Colors.blue), 
        //             onTap: () {
        //               showAlertDialog(context, mascotaDocument, _firebaseService);

        // )
      ),
    );
    
  }
}

class _ButtonDelete extends StatelessWidget {

  final QueryDocumentSnapshot<Mascota> mascotaDocument;

  const _ButtonDelete({
    Key? key,
    required this.mascotaDocument,
  });

  @override
  Widget build(BuildContext context) {

    final _firebaseService = FirebaseService.fb;
  
    return Container(
      child: FittedBox(
        fit: BoxFit.contain,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10 ),
          child: Row(
            children: [
              InkWell(
                child: Row(
                  children: [
                    const Icon(Icons.delete, size: 25, color: Colors.pink,),
                  ],
                ), 
                onTap: () {
                  showAlertDialog1(context, (){
                    _firebaseService.deleteMascota(mascotaDocument.id);
                    Navigator.pop(context);
                  });
                },
              ),
              const SizedBox(width: 10),
              InkWell(
                child: Row(
                  children: [
                    const Icon(Icons.edit, size: 20, color: Colors.white,),
                  ],
                ), 
                onTap: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => AgregarMascotaPage(mascotaDocument: mascotaDocument))
                    );
                },
              ),
            ],
          ), 
        ),
      ),
      width: 100,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.indigo,
        borderRadius: BorderRadius.only( topRight: Radius.circular(25), bottomLeft: Radius.circular(25) )
      ),
    );
  }
}

class _NombreMascota extends StatelessWidget {
  const _NombreMascota({
    Key? key,
    required this.nombre,
  }) : super(key: key);

  final String nombre;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only( right: 50 ),
      child: Container(
        padding: EdgeInsets.symmetric( horizontal: 20, vertical: 10 ),
        width: double.infinity,
        height:40,
        decoration: BoxDecoration(
          color: Colors.indigo,
          borderRadius: BorderRadius.only( bottomLeft: Radius.circular(25), topRight: Radius.circular(25) )
        ),
        child: Text(
          nombre, 
          style: TextStyle( fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _BackgroundImage extends StatelessWidget {
 
  final String? url;

  const _BackgroundImage( this.url );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: double.infinity,
        height: 300,
        child: url == null
          ? Image(
              image: AssetImage('assets/images/noimage.png'),
              fit: BoxFit.cover,
              height: 100,
              width: 100,
            )
          : FadeInImage(
            placeholder: AssetImage('assets/images/jar-loading.gif'),
            image: NetworkImage(url!),
            fit: BoxFit.cover,
          ),
      ),
    );
  }
}

// showAlertDialog(BuildContext context, QueryDocumentSnapshot<Mascota?> mascotaDocument, FirebaseService firebaseService) {

//   final nameCtlr = TextEditingController(text: mascotaDocument.data()!.nombre);

//   // set up the AlertDialog
//   AlertDialog alert = AlertDialog(
//     title: Row(
//       children: [
//         Icon(Icons.error_outline, size: 30, color: Theme.of(context).colorScheme.primary),
//         const SizedBox(width: 10),
//         const Expanded (
//           child: Text("Actualizar Nombre de la Mascota",  maxLines: 2, overflow: TextOverflow.ellipsis)
//         )
//       ],
//     ),
//     content: Column(
//       mainAxisSize: MainAxisSize.min, 
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 20), 
//         CustomInput(
//           icon: Icons.favorite_sharp, 
//           placeholder: "Nombre deL la Mascota", 
//           textController: nameCtlr
//         ),
//         const SizedBox(height: 20),

//         MainButton(
//           text: "Actualizar",
//           onPressed: () async{
//             firebaseService.updateMascota(mascotaDocument.id, {"nombre": nameCtlr.text.trim()});
//             Navigator.pop(context);
//           }
//         )
        
//       ]
        
//     )
//   );

//   // show the dialog
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return alert;
//     },
//   );
// }


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
