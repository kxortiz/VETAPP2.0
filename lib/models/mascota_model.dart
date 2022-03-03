class Mascota {
  
  final String nombre;
  final List vacunas;
  final String userId;
  final String? image;
  
  Mascota({
    required this.nombre,
    required this.vacunas,
    required this.userId,
    this.image
  });



  Mascota.fromJson(Map<String, Object?> json)
  : this(
    nombre: json['nombre']! as String,
    vacunas: json['vacunas']! as List,
    userId: json['userId']! as String,
    image: json['image'] as String?,
  );

  Map<String, Object?> toJson() => {
    'nombre': nombre,
    'vacunas': vacunas,
    'userId': userId,
    'image': image
  };
}
