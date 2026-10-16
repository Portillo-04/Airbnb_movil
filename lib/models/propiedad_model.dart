class Propiedad {
  final int id;
  final String direccion;
  final String descripcion;
  final double precioMensual;
  final String estado;
  final String? imagenUrl;
  final int? propietarioId;
  final String? createdAt;
  final String? updatedAt;

  Propiedad({
    required this.id,
    required this.direccion,
    required this.descripcion,
    required this.precioMensual,
    required this.estado,
    this.imagenUrl,
    this.propietarioId,
    this.createdAt,
    this.updatedAt,
  });

  factory Propiedad.fromJson(Map<String, dynamic> json) {
    return Propiedad(
      id: json['id'] ?? 0,
      direccion: json['direccion'] ?? '',
      descripcion: json['descripcion'] ?? '',
      precioMensual: (json['precio_mensual'] as num?)?.toDouble() ?? 0.0,
      estado: json['estado'] ?? 'disponible',
      imagenUrl: json['imagen_url'],
      propietarioId: json['propietario_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}