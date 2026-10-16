enum RolUsuario { administrador, propietario, inquilino, visitante }

class Usuario {
  final int id;
  final String nombre;
  final String email;
  final String telefono;
  final RolUsuario rol;

  Usuario({required this.id, required this.nombre, required this.email, required this.telefono, required this.rol});

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nombre: json['nombre'],
      email: json['email'],
      telefono: json['telefono'] ?? '',
      rol: RolUsuario.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == (json['rol'] ?? 'visitante').toString().toLowerCase(),
        orElse: () => RolUsuario.visitante,
      ),
    );
  }
}