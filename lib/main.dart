import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

// ✅ IMPORTA TODAS TUS PANTALLAS
import 'screens/visitor_home_screen.dart'; // Pantalla de visitantes (Casa de Bolívar)
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/owner_dashboard_screen.dart'; // Dashboard de Diego
import 'screens/tenant_dashboard_screen.dart'; // Dashboard de inquilinos
import 'screens/admin_dashboard_screen.dart'; // Dashboard admin

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => AuthProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Airbnb Alquileres',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),

      // ✅ 1. INICIA EN VISITANTES (PARA QUE VEAN LAS CASAS DE UNA)
      home: const VisitorHomeScreen(),

      // ✅ 2. AGREGA ESTAS RUTAS PARA QUE EL LOGIN FUNCIONE
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),

        // ESTA ES LA QUE TE FALTABA Y TE TIRABA EL ERROR ROJO
        '/dashboard-owner': (context) => const OwnerDashboardScreen(),

        // LAS OTRAS POR SI ACASO
        '/dashboard-tenant': (context) => const TenantDashboardScreen(),
        '/dashboard-admin': (context) => const AdminDashboardScreen(),
      },
    );
  }
}
