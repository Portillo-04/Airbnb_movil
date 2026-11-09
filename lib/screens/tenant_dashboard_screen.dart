import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/propiedad_model.dart';
import '../services/propiedad_service.dart';
import '../core/constants.dart';

// ✅ IMPORTS DE LAS PANTALLAS DEL INQUILINO
import 'property_detail_screen.dart';
import 'tenant_available_properties_screen.dart';
// import 'tenant_my_rentals_screen.dart';       // TODO: Crear cuando tengas la pantalla
// import 'tenant_requests_screen.dart';         // TODO: Crear cuando tengas la pantalla
// import 'tenant_maintenance_screen.dart';      // TODO: Crear cuando tengas la pantalla
// import 'tenant_contracts_screen.dart';        // TODO: Crear cuando tengas la pantalla
// import 'tenant_payments_screen.dart';         // TODO: Crear cuando tengas la pantalla
import 'tenant_notifications_screen.dart'; // ✅ Ya conectada

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

  // ✅ MAPA DE UBICACIONES COMPLETO
  final Map<String, List<String>> _salvadorLocations = {
    'Ahuachapán': [
      'Ahuachapán',
      'Atiquizaya',
      'Concepción de Ataco',
      'El Refugio',
      'Guaymango',
      'Jujutla',
      'San Francisco Menéndez',
      'San Lorenzo',
      'San Pedro Puxtla',
      'Tacuba',
      'Turín',
    ],
    'Cabañas': [
      'Sensuntepeque',
      'Cinquera',
      'Dolores',
      'Guacotecti',
      'Ilobasco',
      'Jutiapa',
      'San Isidro',
      'Tejutepeque',
      'Victoria',
    ],
    'Chalatenango': [
      'Chalatenango',
      'Agua Caliente',
      'Arcatao',
      'Azacualpa',
      'Citalá',
      'Comalapa',
      'Concepción Quezaltepeque',
      'Dulce Nombre de María',
      'El Carrizal',
      'El Paraíso',
      'La Laguna',
      'La Palma',
      'La Reina',
      'Las Vueltas',
      'Nombre de Jesús',
      'Nueva Concepción',
      'Nueva Trinidad',
      'Ojos de Agua',
      'Potonico',
      'San Antonio de la Cruz',
      'San Antonio Los Ranchos',
      'San Fernando',
      'San Francisco Lempa',
      'San Francisco Morazán',
      'San Ignacio',
      'San Isidro Labrador',
      'San José Cancasque',
      'San José Las Flores',
      'San Luis del Carmen',
      'San Miguel de Mercedes',
      'San Rafael',
      'Santa Rita',
      'Tejutla',
    ],
    'Cuscatlán': [
      'Cojutepeque',
      'Candelaria',
      'El Carmen',
      'El Rosario',
      'Monte San Juan',
      'Oratorio de Concepción',
      'San Bartolomé Perulapía',
      'San Cristóbal',
      'San José Guayabal',
      'San Pedro Perulapán',
      'San Rafael Cedros',
      'San Ramón',
      'Santa Cruz Analquito',
      'Santa Cruz Michapa',
      'Suchitoto',
      'Tenancingo',
    ],
    'La Libertad': [
      'Santa Tecla',
      'Antiguo Cuscatlán',
      'Chiltiupán',
      'Ciudad Arce',
      'Colón',
      'Comasagua',
      'Huizúcar',
      'Jayaque',
      'Jicalapa',
      'La Libertad',
      'Nuevo Cuscatlán',
      'Opico',
      'Quezaltepeque',
      'Sacacoyo',
      'San Juan Opico',
      'San Matías',
      'San Pablo Tacachico',
      'Talnique',
      'Tamanique',
      'Teotepeque',
      'Tepecoyo',
      'Zaragoza',
    ],
    'La Paz': [
      'Zacatecoluca',
      'Cuyultitán',
      'El Rosario',
      'Jerusalén',
      'Mercedes La Ceiba',
      'Olocuilta',
      'Paraíso de Osorio',
      'San Antonio Masahuat',
      'San Emigdio',
      'San Francisco Chinameca',
      'San Juan Nonualco',
      'Juan Talpa',
      'Juan Tepezontes',
      'Luis La Herradura',
      'Luis Talpa',
      'Miguel Tepezontes',
      'Pedro Masahuat',
      'Pedro Nonualco',
      'Rafael Obrajuelo',
      'María Ostuma',
      'Santiago Nonualco',
      'Tapalhuaca',
    ],
    'La Unión': [
      'La Unión',
      'Bolívar',
      'Conchagua',
      'El Carmen',
      'Intipucá',
      'Lislique',
      'Meanguera',
      'Nueva Esparta',
      'Pasaquina',
      'Polorós',
      'San Alejo',
      'Santa Rosa de Lima',
      'Yayantique',
      'Yucuaiquín',
    ],
    'Morazán': [
      'San Francisco Gotera',
      'Arambala',
      'Cacaopera',
      'Chilanga',
      'Corinto',
      'Delicias de Concepción',
      'Divisadero',
      'Rosario',
      'Gualococti',
      'Guatajiagua',
      'Joateca',
      'Jocoaitique',
      'Jocoro',
      'Lolotiquillo',
      'Meanguera',
      'Osicala',
      'Perquín',
      'San Carlos',
      'San Fernando',
      'San Isidro',
      'San Simón',
      'Sensembra',
      'Sociedad',
      'Torola',
      'Yamabal',
      'Yoloaiquín',
    ],
    'San Miguel': [
      'San Miguel',
      'Carolina',
      'Chapeltique',
      'Chinameca',
      'Chirilagua',
      'Ciudad Barrios',
      'Comacarán',
      'Tránsito',
      'Lolotique',
      'Moncagua',
      'Nueva Guadalupe',
      'Nuevo Edén de San Juan',
      'Quelepa',
      'Antonio del Monte',
      'Gerardo',
      'Jorge',
      'Luis de la Reina',
      'Rafael Oriente',
      'Sesori',
      'Uluazapa',
    ],
    'San Salvador': [
      'San Salvador',
      'Aguilares',
      'Apopa',
      'Ayutuxtepeque',
      'Cuscatancingo',
      'Delgado',
      'Paisnal',
      'Guazapa',
      'Ilopango',
      'Mejicanos',
      'Nejapa',
      'Panchimalco',
      'Rosario de Mora',
      'Marcos',
      'Martín',
      'Texacuangos',
      'Tomás',
      'Soyapango',
      'Tonacatepeque',
    ],
    'San Vicente': [
      'San Vicente',
      'Apastepeque',
      'Guadalupe',
      'Cayetano Istepeque',
      'Esteban Catarina',
      'Ildefonso',
      'Lorenzo',
      'Sebastián',
      'Clara',
      'Domingo',
      'Tecoluca',
      'Tepetitán',
      'Verapaz',
    ],
    'Santa Ana': [
      'Santa Ana',
      'Coatepeque',
      'Chalchuapa',
      'Congo',
      'Porvenir',
      'Masahuat',
      'Metapán',
      'Antonio Pajonal',
      'Sebastián Salitrillo',
      'Rosa Guachipilín',
      'Frontera',
      'Texistepeque',
    ],
    'Sonsonate': [
      'Sonsonate',
      'Acajutla',
      'Armenia',
      'Caluco',
      'Cuisnahuat',
      'Izalco',
      'Juayúa',
      'Nahuizalco',
      'Nahulingo',
      'Salcoatitán',
      'Antonio del Monte',
      'Julián',
      'Catarina Masahuat',
      'Isabel Ishuatán',
      'Domingo de Guzmán',
      'Sonzacate',
    ],
    'Usulután': [
      'Usulután',
      'Alegría',
      'Berlín',
      'California',
      'Concepción Batres',
      'Triunfo',
      'Ereguayquín',
      'Estanzuelas',
      'Jiquilisco',
      'Jucuapa',
      'Jucuarán',
      'Umaña',
      'Granada',
      'Ozatlán',
      'Puerto El Triunfo',
      'Agustín',
      'Buenaventura',
      'Dionisio',
      'Francisco Javier',
      'Elena',
      'María',
      'De María',
      'Tecapán',
      'Vari',
    ],
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

  void _limpiarFiltros() {
    setState(() {
      _selectedDept = null;
      _selectedDistrict = null;
    });
    _applyFilters();
  }

  // ✅ LOGOUT SEGURO Y ASÍNCRONO
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
        title: Text(
          'Hola, $userName',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        actions: [
          // ✅ CAMPANITA CONECTADA A NOTIFICACIONES
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
            icon: const Icon(Icons.refresh, size: 24),
            onPressed: _cargarPropiedades,
            tooltip: 'Actualizar',
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 24),
            onPressed: _handleLogout,
            tooltip: 'Cerrar Sesión',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            color: Colors.indigo.shade800,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDept,
                    hint: const Text(
                      'Depto',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    dropdownColor: Colors.indigo.shade900,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                    isDense: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 0,
                      ),
                      constraints: const BoxConstraints(minHeight: 32),
                    ),
                    items: _salvadorLocations.keys
                        .map<DropdownMenuItem<String>>(
                          (d) => DropdownMenuItem(
                            value: d,
                            child: Text(
                              d,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedDept = val;
                        _selectedDistrict = null;
                      });
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDistrict,
                    hint: const Text(
                      'Dist.',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    dropdownColor: Colors.indigo.shade900,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                    isDense: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 0,
                      ),
                      constraints: const BoxConstraints(minHeight: 32),
                    ),
                    items:
                        (_selectedDept != null
                                ? _salvadorLocations[_selectedDept]
                                : [])
                            ?.map<DropdownMenuItem<String>>(
                              (d) => DropdownMenuItem(
                                value: d,
                                child: Text(
                                  d,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                            )
                            .toList() ??
                        [],
                    onChanged: (val) {
                      setState(() => _selectedDistrict = val);
                      _applyFilters();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta de Bienvenida Compacta
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

            // ✅ GRID DE 6 CARTAS DEL INQUILINO
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
                  onTap: () {
                    /* TODO: Navegar a tenant_my_rentals_screen */
                  },
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
                  subtitle: 'Estado de trámites',
                  icon: Icons.handshake,
                  color: Colors.orange,
                  onTap: () {
                    /* TODO: Navegar a tenant_requests_screen */
                  },
                ),
                _DashboardCard(
                  title: 'Mantenimiento',
                  subtitle: 'Reportar problemas',
                  icon: Icons.build,
                  color: Colors.redAccent,
                  onTap: () {
                    /* TODO: Navegar a tenant_maintenance_screen */
                  },
                ),
                _DashboardCard(
                  title: 'Contratos',
                  subtitle: 'Acuerdos vigentes',
                  icon: Icons.description,
                  color: Colors.purple,
                  onTap: () {
                    /* TODO: Navegar a tenant_contracts_screen */
                  },
                ),
                _DashboardCard(
                  title: 'Mis Pagos',
                  subtitle: 'Historial de egresos',
                  icon: Icons.credit_card,
                  color: Colors.teal,
                  onTap: () {
                    /* TODO: Navegar a tenant_payments_screen */
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Text(
              'Destacadas para ti',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 16),

            // Lista rápida de propiedades destacadas (opcional)
            if (_filteredProperties.isNotEmpty) ...[
              SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filteredProperties.length > 5
                      ? 5
                      : _filteredProperties.length,
                  itemBuilder: (context, index) {
                    final p = _filteredProperties[index];
                    return Container(
                      width: 220,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PropertyDetailScreen(propiedad: p),
                          ),
                        ),
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: Image.network(
                                '${AppConstants.baseUrl}${p.imagenUrl}',
                                height: 140,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 140,
                                  color: Colors.grey[300],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.direccion,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${p.precioMensual.toStringAsFixed(2)}/mes',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${p.departamento}, ${p.distrito}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Widget reutilizable para las cartas del dashboard
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
