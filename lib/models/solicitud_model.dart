class SolicitudAlquiler {
  final int id;
  final int propiedadId;
  final int inquilinoId;
  final String fechaInicio;
  final String fechaFin;
  final String estado;
  final String? respuestaPropietario;
  final String? inquilinoNombre;
  final String? createdAt;

  SolicitudAlquiler({
    required this.id,
    required this.propiedadId,
    required this.inquilinoId,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado,
    this.respuestaPropietario,
    this.inquilinoNombre,
    this.createdAt,
  });

  factory SolicitudAlquiler.fromJson(Map<String, dynamic> json) {
    return SolicitudAlquiler(
      id: json['id'] ?? 0,
      propiedadId: json['propiedad_id'] ?? 0,
      inquilinoId: json['inquilino_id'] ?? 0,
      fechaInicio: json['fecha_inicio'] ?? '',
      fechaFin: json['fecha_fin'] ?? '',
      estado: json['estado'] ?? 'EN_CURSO',
      respuestaPropietario: json['respuesta_propietario'],
      inquilinoNombre: json['inquilino_nombre'],
      createdAt: json['created_at'],
    );
  }
}
