import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vetapp/models/mascota_model.dart';
import 'package:vetapp/pages/agregar_vacuna_page.dart';
import 'package:vetapp/services/auth_service.dart';
import 'package:vetapp/services/firebase.dart';
import 'package:vetapp/services/mascotas_service.dart';

class ListarVacunasPage extends StatefulWidget {
  const ListarVacunasPage({Key? key}) : super(key: key);

  @override
  State<ListarVacunasPage> createState() => _ListarVacunasPageState();
}

class _ListarVacunasPageState extends State<ListarVacunasPage> {
  
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

    // final _firebaseService = FirebaseService.fb;
    // final _authService = Provider.of<AuthService>(context);
    
    return ChangeNotifierProvider(
      create: ( _ ) => MascotasService(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Listado de Vacunas"),
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
                              shrinkWrap: true,
                              itemCount: documentsMascotas.length,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, int index){
                                
                                final mascotaDocument = documentsMascotas[index];
                          
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5),
                                    Container(
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
                                              const Text("Mascota: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                              Text(mascotaDocument.data().nombre)
                                            ],
                                          ),
                                          InkWell(
                                            onTap: (){
                                              Navigator.push(
                                                context, MaterialPageRoute(builder: (context) => AgregarVacunaPage(mascotaDocument: mascotaDocument))
                                              );
                                            },
                                            child: Row(
                                              children: const [
                                                Text("Editar", style: TextStyle(fontWeight: FontWeight.bold)),
                                                SizedBox(width: 5),
                                                Icon(Icons.edit, size: 15)
                                              ],
                                            ),
                                          )
                                        ],
                                      )
                                    ),

                                    const SizedBox(height: 20),
                                    _BackgroundImage(mascotaDocument.data().image),
                                    const SizedBox(height: 20),

                                    Container(
                                      margin: const EdgeInsets.symmetric( horizontal: 20),
                                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                      child: mascotaDocument.data().vacunas.isNotEmpty
                                      ? Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text("Vacunas:", style: TextStyle(fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 5),
                                            for (String vacuna in mascotaDocument.data().vacunas) (
                                              Text(vacuna)
                                            )
                                          ]
                                        )
                                      : const Text("No hay vacunas", style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),

                                    const Divider(thickness: 4),

                                  ],
                                );
                              }
                            );
                          },
                        )
                      ]
                    ),
                  ),
                ),
              ),
            ],
          )
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
    return Align(
      alignment: Alignment.center,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Container(
          width: 100,
          height: 100,
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
      ),
    );
  }
}
