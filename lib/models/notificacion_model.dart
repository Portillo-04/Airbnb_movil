class Notificacion {
  final int id;
  final int usuarioId;
  final String titulo;
  final String mensaje;
  final bool leida;
  final String tipo;
  final String? createdAt;

  Notificacion({
    required this.id,
    required this.usuarioId,
    required this.titulo,
    required this.mensaje,
    required this.leida,
    required this.tipo,
    this.createdAt,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['id'],
      usuarioId: json['usuario_id'],
      titulo: json['titulo'],
      mensaje: json['mensaje'],
      leida: json['leida'] ?? false,
      tipo: json['tipo'] ?? 'GENERAL',
      createdAt: json['created_at'],
    );
  }
}