class Contrato {
  final int id;
  final String fechaInicio;
  final String fechaFin;
  final double precioMensual;
  final String estado;
  final int propiedadId;
  final int inquilinoId;
  final String? pdfUrl;
  final String? createdAt;

  Contrato({
    required this.id,
    required this.fechaInicio,
    required this.fechaFin,
    required this.precioMensual,
    required this.estado,
    required this.propiedadId,
    required this.inquilinoId,
    this.pdfUrl,
    this.createdAt,
  });

  factory Contrato.fromJson(Map<String, dynamic> json) {
    return Contrato(
      id: json['id'] ?? 0,
      fechaInicio: json['fecha_inicio'] ?? '',
      fechaFin: json['fecha_fin'] ?? '',
      precioMensual: (json['precio_mensual'] as num?)?.toDouble() ?? 0.0,
      estado: json['estado'] ?? 'pendiente',
      propiedadId: json['propiedad_id'] ?? 0,
      inquilinoId: json['inquilino_id'] ?? 0,
      pdfUrl: json['pdf_url'],
      createdAt: json['created_at'],
    );
  }
}