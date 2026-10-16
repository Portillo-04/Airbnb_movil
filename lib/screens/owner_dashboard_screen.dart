import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'my_properties_screen.dart';
import 'owner_contracts_screen.dart';
import 'owner_payments_screen.dart';
import 'owner_maintenance_screen.dart';
import 'owner_rental_requests_screen.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header con gradiente
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade700, Colors.indigo.shade400],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bienvenido,',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              authProvider.usuario?.nombre ?? 'Propietario',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Cerrar Sesión'),
                                content: const Text('¿Estás seguro?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      authProvider.logout();
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Sí'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.business, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Panel de Propietario',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Grid de módulos
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _ModernDashboardCard(
                        icon: Icons.home_rounded,
                        title: 'Mis Propiedades',
                        subtitle: 'Gestiona tus inmuebles',
                        gradient: [Colors.blue.shade400, Colors.blue.shade700],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MyPropertiesScreen()),
                        ),
                      ),
                      _ModernDashboardCard(
                        icon: Icons.description_rounded,
                        title: 'Contratos',
                        subtitle: 'Contratos activos',
                        gradient: [Colors.green.shade400, Colors.green.shade700],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const OwnerContractsScreen()),
                        ),
                      ),
                      _ModernDashboardCard(
                        icon: Icons.payment_rounded,
                        title: 'Pagos',
                        subtitle: 'Historial de pagos',
                        gradient: [Colors.orange.shade400, Colors.orange.shade700],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const OwnerPaymentsScreen()),
                        ),
                      ),
                      _ModernDashboardCard(
                        icon: Icons.build_rounded,
                        title: 'Mantenimiento',
                        subtitle: 'Solicitudes',
                        gradient: [Colors.red.shade400, Colors.red.shade700],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const OwnerMaintenanceScreen()),
                        ),
                      ),
                      _ModernDashboardCard(
                        icon: Icons.handshake_rounded,
                        title: 'Solicitudes Alquiler',
                        subtitle: 'Gestionar solicitudes',
                        gradient: [Colors.purple.shade400, Colors.purple.shade700],
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const OwnerRentalRequestsScreen()),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModernDashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _ModernDashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}