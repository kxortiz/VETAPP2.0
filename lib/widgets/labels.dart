import 'package:flutter/material.dart';

class Labels extends StatelessWidget {

  final String ruta;
  final String mensaje1;
  final String mensaje2;

  // ignore: use_key_in_widget_constructors
  const Labels({
    required this.ruta,
    required this.mensaje1,
    required this.mensaje2
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(mensaje1, style: const TextStyle( color: Colors.black54, fontSize: 15, fontWeight: FontWeight.w300)),
        const SizedBox( height: 10 ),
        GestureDetector(
          child: Text(mensaje2, style: TextStyle( color: Theme.of(context).colorScheme.primary, fontSize: 18, fontWeight: FontWeight.bold)),
          onTap: (){
            Navigator.pushReplacementNamed(context, ruta);
          },
        ),
      ]
    );
  }
}