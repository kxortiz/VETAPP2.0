import 'package:flutter/material.dart';
import 'package:vetapp/utils/my_colors.dart';

class Logo extends StatelessWidget {

  final String titulo;

  // ignore: use_key_in_widget_constructors
  const Logo({ required this.titulo });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only( top: 30 ),
        width: 250,
        child: SafeArea(
          child: Column(
            children: [
              const Image(image: AssetImage('assets/images/logo.jpeg')),
              Text(titulo, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: MyColors.primaryColor)),
            ],
          ),
        ),
      ),
    );
  }
}