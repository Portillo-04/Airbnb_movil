class Pago {
  final int id;
  final int contratoId;
  final double monto;
  final String fechaPago;
  final String metodoPago;
  final String? descripcion;
  final String? paypalTransactionId; // ✅ NUEVO
  final String? createdAt;

  Pago({
    required this.id,
    required this.contratoId,
    required this.monto,
    required this.fechaPago,
    required this.metodoPago,
    this.descripcion,
    this.paypalTransactionId,
    this.createdAt,
  });

  factory Pago.fromJson(Map<String, dynamic> json) {
    return Pago(
      id: json['id'] ?? 0,
      contratoId: json['contrato_id'] ?? 0,
      monto: (json['monto'] as num?)?.toDouble() ?? 0.0,
      fechaPago: json['fecha_pago'] ?? '',
      metodoPago: json['metodo_pago'] ?? '',
      descripcion: json['descripcion'],
      paypalTransactionId: json['paypal_transaction_id'], // ✅ NUEVO
      createdAt: json['created_at'],
    );
  }
}