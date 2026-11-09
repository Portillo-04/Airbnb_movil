import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/usuario_model.dart';
import 'property_list_screen.dart';
import 'owner_dashboard_screen.dart';
import 'tenant_dashboard_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final rol = authProvider.usuario?.rol;

    // ✅ Propietario o Admin → Dashboard de propietario
    if (rol == RolUsuario.propietario || rol == RolUsuario.administrador) {
      return const OwnerDashboardScreen();
    }

    // ✅ Inquilino → Dashboard de inquilino
    if (rol == RolUsuario.inquilino) {
      return const TenantDashboardScreen();
    }

    // ✅ Visitante → Lista de propiedades con filtros
    return _MenuVisitante();
  }
}

class _MenuVisitante extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Viviendas Disponibles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cerrar Sesión'),
                  content: const Text('¿Estás seguro?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                    TextButton(onPressed: () { authProvider.logout(); Navigator.pop(context); }, child: const Text('Sí')),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: const PropertyListScreen(),
    );
  }
}