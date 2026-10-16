class Contrato {
  final int id;
  final String fechaInicio;
  final String fechaFin;
  final double precioMensual;
  final String estado;
  final int propiedadId;
  final int inquilinoId;
  final String? createdAt;

  Contrato({
    required this.id,
    required this.fechaInicio,
    required this.fechaFin,
    required this.precioMensual,
    required this.estado,
    required this.propiedadId,
    required this.inquilinoId,
    this.createdAt,
  });

  factory Contrato.fromJson(Map<String, dynamic> json) {
    return Contrato(
      id: json['id'] ?? 0,
      fechaInicio: json['fecha_inicio'] ?? '',
      fechaFin: json['fecha_fin'] ?? '',
      // ✅ Usar precio_mensual (como viene de la API), con fallback a 0
      precioMensual: (json['precio_mensual'] as num?)?.toDouble() ?? 0.0,
      estado: json['estado'] ?? 'activo',
      propiedadId: json['propiedad_id'] ?? 0,
      inquilinoId: json['inquilino_id'] ?? 0,
      createdAt: json['created_at'],
    );
  }
}