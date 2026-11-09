class Propiedad {
  final int id;
  final String direccion;
  final String departamento; // ✅ AGREGADO: Campo obligatorio del backend
  final String distrito; // ✅ AGREGADO: Campo obligatorio del backend
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
    required this.departamento, // ✅ PARAMETRO REQUERIDO
    required this.distrito, // ✅ PARAMETRO REQUERIDO
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
      // ✅ MAPEO SEGURO CON VALORES POR DEFECTO
      departamento: json['departamento']?.toString() ?? 'Sin Departamento',
      distrito: json['distrito']?.toString() ?? 'Sin Distrito',
      descripcion: json['descripcion'] ?? '',
      precioMensual: (json['precio_mensual'] as num?)?.toDouble() ?? 0.0,
      estado: json['estado'] ?? 'DISPONIBLE',
      imagenUrl: json['imagen_url'],
      propietarioId: json['propietario_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
