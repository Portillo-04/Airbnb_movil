class Mantenimiento {
  final int id;
  final int propiedadId;
  final int inquilinoId;
  final String descripcion;
  final String estado; // PENDIENTE, EN_PROCESO, RESUELTO, CANCELADO
  final String? respuestaPropietario;
  final String? inquilinoNombre;
  final String? createdAt;

  Mantenimiento({
    required this.id,
    required this.propiedadId,
    required this.inquilinoId,
    required this.descripcion,
    required this.estado,
    this.respuestaPropietario,
    this.inquilinoNombre,
    this.createdAt,
  });

  factory Mantenimiento.fromJson(Map<String, dynamic> json) {
    return Mantenimiento(
      id: json['id'] ?? 0,
      propiedadId: json['propiedad_id'] ?? 0,
      inquilinoId: json['inquilino_id'] ?? 0,
      descripcion: json['descripcion'] ?? 'Sin descripción',
      estado: json['estado'] ?? 'PENDIENTE',
      respuestaPropietario: json['respuesta_propietario'],
      inquilinoNombre: json['inquilino_nombre'],
      createdAt: json['created_at'],
    );
  }
}
