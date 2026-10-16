class Pago {
  final int id;
  final String fechaPago;
  final double monto;
  final String metodoPago;
  final String? descripcion;
  final int contratoId;
  final String? createdAt;

  Pago({
    required this.id,
    required this.fechaPago,
    required this.monto,
    required this.metodoPago,
    this.descripcion,
    required this.contratoId,
    this.createdAt,
  });

  factory Pago.fromJson(Map<String, dynamic> json) {
    return Pago(
      id: json['id'] ?? 0,
      fechaPago: json['fecha_pago'] ?? '',
      monto: (json['monto'] as num?)?.toDouble() ?? 0.0,
      metodoPago: json['metodo_pago'] ?? 'efectivo',
      descripcion: json['descripcion'],
      contratoId: json['contrato_id'] ?? 0,
      createdAt: json['created_at'],
    );
  }
}