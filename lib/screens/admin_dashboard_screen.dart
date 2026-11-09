import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Encabezado tipo SliverAppBar
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.indigo.shade700,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.indigo.shade800, Colors.indigo.shade600],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'Bienvenido,',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'admin@gmail.com',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.logout,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.popUntil(
                                  context,
                                  (route) => route.isFirst,
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.admin_panel_settings,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Panel de Administrador',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Cuerpo con la cuadrícula de 5 tarjetas
          SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              delegate: SliverChildListDelegate([
                _buildCard(
                  context,
                  title: 'Todos los Usuarios',
                  subtitle: 'Gestionar roles y cuentas',
                  icon: Icons.people_alt_rounded,
                  colorStart: Colors.blue.shade400,
                  colorEnd: Colors.blue.shade700,
                  onTap: () => _navigateTo(context, 'Usuarios'),
                ),
                _buildCard(
                  context,
                  title: 'Todas las Propiedades',
                  subtitle: 'Catálogo global',
                  icon: Icons.apartment_rounded,
                  colorStart: Colors.green.shade400,
                  colorEnd: Colors.green.shade700,
                  onTap: () => _navigateTo(context, 'Propiedades'),
                ),
                _buildCard(
                  context,
                  title: 'Contratos Globales',
                  subtitle: 'Supervisar acuerdos',
                  icon: Icons.description_rounded,
                  colorStart: Colors.orange.shade400,
                  colorEnd: Colors.orange.shade700,
                  onTap: () => _navigateTo(context, 'Contratos'),
                ),
                _buildCard(
                  context,
                  title: 'Mantenimiento',
                  subtitle: 'Todas las solicitudes',
                  icon: Icons.build_rounded,
                  colorStart: Colors.red.shade400,
                  colorEnd: Colors.red.shade700,
                  onTap: () => _navigateTo(context, 'Mantenimiento'),
                ),
                _buildCard(
                  context,
                  title: 'Pagos Globales',
                  subtitle: 'Historial financiero',
                  icon: Icons.credit_card_rounded,
                  colorStart: Colors.purple.shade400,
                  colorEnd: Colors.purple.shade700,
                  onTap: () => _navigateTo(context, 'Pagos'),
                ),
                // ✅ Tarjeta de Configuración ELIMINADA
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // Widget de Tarjeta Estilo "Imagen"
  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color colorStart,
    required Color colorEnd,
    required VoidCallback onTap,
  }) {
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
              colors: [colorStart, colorEnd],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 32),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, String screenName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abriendo módulo: $screenName'),
        backgroundColor: Colors.indigo.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
