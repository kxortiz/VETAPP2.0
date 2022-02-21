import 'package:flutter/material.dart';
import 'package:vetapp/models/opcion.dart';
import 'package:vetapp/pages/consultar_cita_page.dart';
import 'package:vetapp/pages/crear_cita_page.dart';
import 'package:vetapp/pages/escanear_qr_page.dart';
import 'package:vetapp/utils/my_colors.dart';

final List<Opcion> opciones = [
  Opcion("Crear Cita", "Consulta Citas", "agendar.png",
      (context) => const CrearCitaPage()),
  Opcion("Citas de Hoy", "Consultar citas de hoy", "citash.png",
      (context) => const ConsultarCitaPage()),
  Opcion(
      "Escanear QR", "Escanea QR", "qr.png", (context) => const EscanearQR()),
];

class AdministradorPage extends StatelessWidget {
  const AdministradorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text("Opciones de Administrador"),
      ),
      body: ListView.builder(
          shrinkWrap: true,
          //physics: const NeverScrollableScrollPhysics(),
          itemCount: opciones.length,
          itemBuilder: (BuildContext context, int index) {
            final opcion = opciones[index];

            return (Container(
              margin: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: MediaQuery.of(context).size.width * 0.04),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: MyColors.contraRelojLight,
              ),
              height: 130,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context, MaterialPageRoute(builder: opcion.route));
                    },
                    child: Row(
                      children: [
                        Image(
                            image: AssetImage('assets/images/${opcion.image}')),
                        Expanded(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              opcion.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(opcion.description)
                          ],
                        )),
                        Icon(Icons.arrow_forward_ios_rounded,
                            color: MyColors.contraReloj)
                      ],
                    )),
              ),
            ));
          }),
    ));
  }
}
