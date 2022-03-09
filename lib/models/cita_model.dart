class Cita {
  Cita({required this.correo, required this.nombre, required this.dia, required this.hora, required this.completado, required this.createdAt});

  final String correo;
  final String nombre;
  final String dia;
  final String hora;
  final bool completado;
  final int createdAt;

  Cita.fromJson(Map<String, Object?> json)
  : this(
    correo: json['correo']! as String,
    nombre: json['nombre']! as String,
    dia: json['dia']! as String,
    hora: json['hora']! as String,
    completado: json['completado']! as bool,
    createdAt: json['createdAt']! as int,
  );

  Map<String, Object?> toJson() => {
    'correo': correo,
    'nombre': nombre,
    'dia': dia,
    'hora': hora,
    'completado': completado,
    'createdAt': createdAt
  };
}