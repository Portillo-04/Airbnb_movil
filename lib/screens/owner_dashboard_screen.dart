import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

// ✅ IMPORTS DE TODAS LAS PANTALLAS DEL DASHBOARD
import 'my_properties_screen.dart';
import 'tenant_available_properties_screen.dart';
import 'owner_solicitudes_screen.dart';
import 'owner_maintenance_screen.dart';
import 'owner_contracts_screen.dart';
import 'owner_payments_screen.dart';
import 'tenant_notifications_screen.dart'; // ✅ AGREGADO PARA LA CAMPANITA

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  // ✅ LOGOUT SEGURO QUE LIMPIA TODO EL HISTORIAL
  Future<void> _handleLogout() async {
    final auth = context.read<AuthProvider>();

    // 1. Ejecutar logout en el provider
    await auth.logout();

    // 2. Navegar al login borrando todas las rutas anteriores
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos watch para que se reconstruya si cambia el usuario
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.usuario;

    // ✅ LÓGICA DE NOMBRE A PRUEBA DE FALLAS
    String displayName = 'Propietario'; // Valor por defecto seguro

    if (user != null) {
      // Prioridad 1: Campo nombre explícito
      if (user.nombre.isNotEmpty && user.nombre != 'null') {
        displayName = user.nombre;
      }
      // Prioridad 2: Extraer del email (diego@gmail.com -> Diego)
      else if (user.email.contains('@')) {
        final nameFromEmail = user.email.split('@').first;
        displayName =
            nameFromEmail[0].toUpperCase() + nameFromEmail.substring(1);
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Panel de Propietario'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // ✅ NOTIFICACIONES CON BADGE Y NAVEGACIÓN FUNCIONAL
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 26),
                onPressed: () {
                  Navigator.push(
                    context,
                    // ✅ NOMBRE EXACTO DE TU CLASE (Inglés y con 's')
                    MaterialPageRoute(
                      builder: (_) => TenantNotificationsScreen(),
                    ),
                  );
                },
                tooltip: 'Notificaciones',
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.indigo.shade700,
                      width: 1.5,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 14,
                    minHeight: 14,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),

          // ✅ BOTÓN DE SALIR
          IconButton(
            icon: const Icon(Icons.logout, size: 24),
            onPressed: _handleLogout,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta de Bienvenida
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade700, Colors.indigo.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bienvenido,',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.badge, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        const Text(
                          'Panel de Propietario',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Gestión Rápida',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 16),

            // Grid de Botones
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.95,
              children: [
                _DashboardCard(
                  title: 'Mis Propiedades',
                  subtitle: 'Gestionar inmuebles',
                  icon: Icons.home_work,
                  color: Colors.blue,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MyPropertiesScreen(),
                    ),
                  ),
                ),
                _DashboardCard(
                  title: 'Viviendas Disponibles',
                  subtitle: 'Buscar para alquilar',
                  icon: Icons.search,
                  color: Colors.green,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TenantAvailablePropertiesScreen(),
                    ),
                  ),
                ),
                _DashboardCard(
                  title: 'Solicitudes',
                  subtitle: 'Revisar interesados',
                  icon: Icons.handshake,
                  color: Colors.orange,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OwnerSolicitudesScreen(),
                    ),
                  ),
                ),
                _DashboardCard(
                  title: 'Mantenimiento',
                  subtitle: 'Solicitudes activas',
                  icon: Icons.build,
                  color: Colors.redAccent,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OwnerMaintenanceScreen(),
                    ),
                  ),
                ),
                _DashboardCard(
                  title: 'Contratos',
                  subtitle: 'Acuerdos vigentes',
                  icon: Icons.description,
                  color: Colors.purple,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OwnerContractsScreen(),
                    ),
                  ),
                ),
                _DashboardCard(
                  title: 'Mis Pagos',
                  subtitle: 'Historial de ingresos',
                  icon: Icons.credit_card,
                  color: Colors.teal,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OwnerPaymentsScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Widget reutilizable para tarjetas
class _DashboardCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
