enum RolUsuario { administrador, propietario, inquilino, visitante }

class Usuario {
  final int id;
  final String nombre;
  final String email;
  final String telefono;
  final RolUsuario rol;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.rol,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    // Normalizamos el rol a minúsculas para evitar errores de coincidencia
    final rolString = (json['rol'] ?? 'visitante').toString().toLowerCase();

    return Usuario(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? 'Usuario',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? '',
      rol: RolUsuario.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == rolString,
        orElse: () => RolUsuario.visitante,
      ),
    );
  }

  // Método útil para mostrar el rol con formato legible en la UI
  String get rolFormateado {
    switch (rol) {
      case RolUsuario.administrador:
        return 'Administrador';
      case RolUsuario.propietario:
        return 'Propietario';
      case RolUsuario.inquilino:
        return 'Inquilino';
      case RolUsuario.visitante:
        return 'Visitante';
    }
  }
}
