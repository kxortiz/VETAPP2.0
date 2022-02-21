import 'package:flutter/material.dart';

class Opcion {
  final String name;
  final String description;
  final String image;
  final Widget Function(BuildContext) route;

  Opcion(this.name, this.description, this.image, this.route);
}