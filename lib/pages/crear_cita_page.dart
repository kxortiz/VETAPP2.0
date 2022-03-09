
import 'package:flutter/material.dart';
import 'package:vetapp/models/cita_model.dart';
import 'package:vetapp/models/fecha_model.dart';
import 'package:vetapp/models/hora_model.dart';
import 'package:vetapp/pages/cita_datos_page.dart';
import 'package:vetapp/services/firebase.dart';
import 'package:vetapp/widgets/custom_input.dart';
import 'package:vetapp/widgets/main_button.dart';

import 'package:vetapp/utils/utils.dart' as utils;
import 'package:intl/intl.dart';

showAlertDialog(BuildContext context, String email, String name, Fecha fecha, Hora hora, Function() onPressed) {
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Row(
      children: [
        Icon(Icons.error_outline, size: 30, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        const Expanded (
          child: Text("Confirma los datos de la cita",  maxLines: 2, overflow: TextOverflow.ellipsis)
        )
      ],
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min, 
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20), 
        Text("Nombre: $name", style: const TextStyle(fontSize: 14)),
        Text("Correo: $email", style: const TextStyle(fontSize: 14)),
        Text("Fecha: ${fecha.month} ${fecha.day}", style: const TextStyle(fontSize: 14)),
        Text("Hora: ${hora.hour}:${hora.minutes}", style: const TextStyle(fontSize: 14)),

        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [    
            ElevatedButton(onPressed: (){
              Navigator.pop(context, false);
            }, child: const Text("Cancelar")),

            const SizedBox(width: 20),

            ElevatedButton(
              onPressed: onPressed,
              child: const Text("Generar")
            ),
          ],
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

class CrearCitaPage extends StatelessWidget {
  const CrearCitaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Crear Cita")
        ),
        body: _Form(),
      ),
    );
  }
}

class _Form extends StatefulWidget {
  @override
  __FormState createState() => __FormState();
}

class __FormState extends State<_Form> {
  
  final emailCtlr = TextEditingController();
  final nameCtlr = TextEditingController();

  final _currentDate = DateTime.now();

  final _dayFormatter = DateFormat('d');
  final _monthFormatter = DateFormat('MMM');

  int selectedDate = 0;
  int selectedTime = 0;

  final _firebaseService = FirebaseService.fb;
  
  @override
  Widget build(BuildContext context) {

    final fechas = <Fecha>[];
    final fechasOriginal = <DateTime> [];
    final horas = utils.getMockTimeAndPrice();

    for (int i = 0; i < 180; i++) {
      final fecha = _currentDate.add(Duration(days: -i));
      fechas.add(Fecha(_dayFormatter.format(fecha), _monthFormatter.format(fecha)));
      fechasOriginal.add(fecha);
    }

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [

            const SizedBox(height: 20),

            const Text("Seleccione la Fecha y Hora"),
            _listDate(fechas),

            const SizedBox(height: 20.0,),

            _listTime(horas),

            const SizedBox(height: 50),
            const Text("Digite los Datos del Paciente"),
            CustomInput(
              icon: Icons.mail_outline,
              placeholder: "Correo",
              keyboardType: TextInputType.emailAddress,
              textController: emailCtlr,
            ),

            CustomInput(
              icon: Icons.person,
              placeholder: "Nombre",
              keyboardType: TextInputType.name,
              textController: nameCtlr,
            ),
            const SizedBox(height: 30),
            
            MainButton(
              text: "Generar Cita",
              onPressed: () async{
                Fecha fecha = fechas[selectedDate];
                Hora hora = horas[selectedTime];

                final horaNueva = hora.hour.padLeft(2, '0');
                final minutosNueva = hora.minutes;
              
                final fechaNueva = fechasOriginal[selectedDate];
                final fechaNueva1 = new DateTime(fechaNueva.year, fechaNueva.month, fechaNueva.day, int.parse(horaNueva), int.parse(minutosNueva));

                showAlertDialog(
                  context, 
                  emailCtlr.text.trim(),
                  nameCtlr.text.trim(),
                  fecha,
                  hora,
                  () async {

                    Cita citaSave = Cita(
                      correo: emailCtlr.text.trim(), 
                      nombre: nameCtlr.text.trim(), 
                      dia: "${fecha.month},${fecha.day}", 
                      hora: "${hora.hour},${hora.minutes}", 
                      completado: false,
                      createdAt: fechaNueva1.millisecondsSinceEpoch
                    );

                  
                    String cita = await _firebaseService.addCita(citaSave);

                    if(cita != "Error"){
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => CitaDatosPage(cita: citaSave, id: cita))
                      );
                    }
                  }
                );

              },
            ),
           ]
         )
      ),
    );
  }

  Widget _listDate(List<Fecha> fechas) {
    return SizedBox(
            width: double.infinity,
            height: 80.0,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: fechas.length,
              itemBuilder: (BuildContext context, int index){
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 8),
                  child: _DateButton(
                    selected: (index == selectedDate),
                    fecha: fechas[index],
                    onPressed: () => setState(() => selectedDate = index),
                  ),
                );
              },
            ),
          );
  }

  Widget _listTime(List<Hora> horas) {
    return SizedBox(
      width: double.infinity,
      height: 80.0,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: horas.length,
        itemBuilder: (BuildContext context, int index){
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 8),
            child: _TimeButton(
              data: horas[index], 
              selected: selectedTime == index, 
              onPressed: () => setState(() => selectedTime = index),
            )
          );
        },
      ),
    );
  }
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({
    Key? key,
    required this.data,
    required this.selected,
    this.onPressed,
  }) : super(key: key);

  final Hora data;
  final bool selected;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 90,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(
            width: 2,
            color: Colors.black12
          ),
          color: selected ? const Color(0xFFFED100): null
        ),
        child: Center(
          child: Text(
            "${data.hour.toString()}:${data.minutes.toString()}", 
            style: const TextStyle(fontSize: 20)
          )
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    Key? key,
    required this.fecha,
    required this.selected,
    this.onPressed,
  }) : super(key: key);

  final Fecha fecha;
  final bool selected;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 50,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          color: selected ? const Color(0xFFFED100) : const Color(0xFF001D54)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              fecha.month, 
              style: TextStyle(
                fontSize: 20, 
                color: !selected ? Colors.white : Colors.black
              ),
            ),
            const SizedBox(height: 5),
            Text(
              fecha.day,
              style: TextStyle(
                color: !selected ? Colors.white : Colors.black
              ),
            ),
          ],
        ),
      ),
    );
  }
}