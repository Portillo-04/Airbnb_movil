class SolicitudMantenimiento {
  final int id;
  final String titulo;
  final String descripcion;
  final String estado;
  final int propiedadId;
  final int inquilinoId;
  final String? createdAt;

  SolicitudMantenimiento({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.estado,
    required this.propiedadId,
    required this.inquilinoId,
    this.createdAt,
  });

  factory SolicitudMantenimiento.fromJson(Map<String, dynamic> json) {
    return SolicitudMantenimiento(
      id: json['id'] ?? 0,
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      estado: json['estado'] ?? 'pendiente',
      propiedadId: json['propiedad_id'] ?? 0,
      inquilinoId: json['inquilino_id'] ?? 0,
      createdAt: json['created_at'],
    );
  }
}