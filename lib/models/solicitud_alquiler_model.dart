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
      id: json['id'],
      propiedadId: json['propiedad_id'],
      inquilinoId: json['inquilino_id'],
      fechaInicio: json['fecha_inicio'],
      fechaFin: json['fecha_fin'],
      estado: json['estado'],
      respuestaPropietario: json['respuesta_propietario'],
      inquilinoNombre: json['inquilino_nombre'],
      createdAt: json['created_at'],
    );
  }
}