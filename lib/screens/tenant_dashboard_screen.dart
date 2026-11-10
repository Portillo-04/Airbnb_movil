import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/propiedad_model.dart';
import '../services/propiedad_service.dart';
import '../core/constants.dart';

// ✅ IMPORTS DE LAS PANTALLAS DEL INQUILINO (DESCOMENTADOS)
import 'property_detail_screen.dart';
import 'tenant_available_properties_screen.dart';
import 'tenant_contract_screen.dart'; // ✅ Conectada
import 'tenant_maintenance_screen.dart'; // ✅ Conectada
import 'tenant_payments_screen.dart'; // ✅ Conectada
import 'tenant_notifications_screen.dart';

class TenantDashboardScreen extends StatefulWidget {
  const TenantDashboardScreen({super.key});

  @override
  State<TenantDashboardScreen> createState() => _TenantDashboardScreenState();
}

class _TenantDashboardScreenState extends State<TenantDashboardScreen> {
  final PropiedadService _service = PropiedadService();
  List<Propiedad> _allProperties = [];
  List<Propiedad> _filteredProperties = [];
  bool _isLoading = true;

  String? _selectedDept;
  String? _selectedDistrict;

  // ✅ MAPA DE UBICACIONES (Se mantiene igual, está perfecto)
  final Map<String, List<String>> _salvadorLocations = {
    'San Salvador': [
      'San Salvador',
      'Soyapango',
      'Ilopango',
      'Mejicanos',
      'Apopa',
    ],
    'Santa Ana': ['Santa Ana', 'Chalchuapa', 'Coatepeque', 'Metapán'],
    'La Libertad': [
      'Santa Tecla',
      'Antiguo Cuscatlán',
      'Quezaltepeque',
      'Zaragoza',
    ],
    'La Paz': ['Zacatecoluca', 'Olocuilta', 'San Juan Nonualco'],
    'Sonsonate': ['Sonsonate', 'Acajutla', 'Izalco', 'Juayúa'],
    // ... resto de departamentos ...
  };

  @override
  void initState() {
    super.initState();
    _cargarPropiedades();
  }

  Future<void> _cargarPropiedades() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.obtenerDisponibles();
      final currentUserId = context.read<AuthProvider>().usuario?.id;

      if (currentUserId != null) {
        _allProperties = data
            .where((p) => p.propietarioId != currentUserId)
            .toList();
      } else {
        _allProperties = data;
      }
      _applyFilters();
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applyFilters() {
    List<Propiedad> result = List.from(_allProperties);
    if (_selectedDept != null)
      result = result.where((p) => p.departamento == _selectedDept).toList();
    if (_selectedDistrict != null)
      result = result.where((p) => p.distrito == _selectedDistrict).toList();
    setState(() => _filteredProperties = result);
  }

  Future<void> _handleLogout() async {
    final auth = context.read<AuthProvider>();
    await auth.logout();
    if (mounted)
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.usuario?.nombre?.isNotEmpty == true
        ? authProvider.usuario!.nombre
        : (authProvider.usuario?.email?.split('@').first ?? 'Inquilino');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 26),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TenantNotificationsScreen(),
                  ),
                ),
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
                    '2',
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
              padding: const EdgeInsets.all(20),
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
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.badge, color: Colors.white, size: 14),
                        const SizedBox(width: 5),
                        const Text(
                          'Panel de Inquilino',
                          style: TextStyle(color: Colors.white, fontSize: 11),
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

            // ✅ GRID DE CARTAS CONECTADAS
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.95,
              children: [
                _DashboardCard(
                  title: 'Mis Alquileres',
                  subtitle: 'Vivienda actual',
                  icon: Icons.home_filled,
                  color: Colors.blue,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TenantContractScreen(),
                    ),
                  ),
                ),
                _DashboardCard(
                  title: 'Buscar Vivienda',
                  subtitle: 'Ver disponibles',
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
                  title: 'Mantenimiento',
                  subtitle: 'Reportar problemas',
                  icon: Icons.build,
                  color: Colors.redAccent,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TenantMaintenanceScreen(),
                    ),
                  ),
                ),

                // ✅ CONTRATOS CONECTADO A TU PANTALLA EXISTENTE
                _DashboardCard(
                  title: 'Contratos',
                  subtitle: 'Acuerdos vigentes',
                  icon: Icons.description,
                  color: Colors.purple,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TenantContractScreen(),
                    ),
                  ),
                ),

                _DashboardCard(
                  title: 'Mis Pagos',
                  subtitle: 'Historial de egresos',
                  icon: Icons.credit_card,
                  color: Colors.teal,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TenantPaymentsScreen(),
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

  // Helper para pantallas pendientes
  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature próximamente...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// Widget reutilizable (Se mantiene igual)
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
