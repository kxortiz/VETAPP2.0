class Cita {
  Cita({required this.correo, required this.nombre, required this.dia, required this.hora, required this.completado});

  final String correo;
  final String nombre;
  final String dia;
  final String hora;
  final bool completado;

  Cita.fromJson(Map<String, Object?> json)
  : this(
    correo: json['correo']! as String,
    nombre: json['nombre']! as String,
    dia: json['dia']! as String,
    hora: json['hora']! as String,
    completado: json['completado']! as bool,
  );

  Map<String, Object?> toJson() => {
    'correo': correo,
    'nombre': nombre,
    'dia': dia,
    'hora': hora,
    'completado': completado,
  };
}