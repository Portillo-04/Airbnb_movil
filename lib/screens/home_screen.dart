import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'menu_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Proyecto F - Alquileres')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Bienvenido a la plataforma de alquileres', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>  LoginScreen())),
                child: const Text('Iniciar Sesión'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>  RegisterScreen())),
                child: const Text('¿No tienes cuenta? Regístrate aquí'),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ Si está autenticado, mostrar el menú principal
    return const MenuScreen();
  }
}