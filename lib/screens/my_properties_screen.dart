import 'package:flutter/material.dart';
import '../services/propiedad_service.dart';
import '../models/propiedad_model.dart';
import '../core/constants.dart'; // ✅ Import necesario para AppConstants
import 'property_form_screen.dart';

class MyPropertiesScreen extends StatefulWidget {
  const MyPropertiesScreen({super.key});

  @override
  State<MyPropertiesScreen> createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends State<MyPropertiesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PropiedadService _service = PropiedadService();

  List<Propiedad> _misPropiedades = [];
  List<Propiedad> _misAlquileres = [];
  bool _isLoading = true;

  String _filtroEstado = 'TODOS';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // ✅ Escuchar cambios de pestaña para actualizar el botón flotante
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    _cargarDatos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      final props = await _service.obtenerMisPropiedades();
      final rentals = await _service.obtenerPropiedadesAlquiladas();

      if (mounted) {
        setState(() {
          _misPropiedades = props;
          _misAlquileres = rentals;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Filtrado local para la pestaña "Mis Propiedades"
  List<Propiedad> get _propiedadesFiltradas {
    if (_filtroEstado == 'TODOS') return _misPropiedades;
    return _misPropiedades
        .where((p) => p.estado.toUpperCase() == _filtroEstado)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Propiedades'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Mis Propiedades', icon: Icon(Icons.home_work)),
            Tab(text: 'Mis Alquileres', icon: Icon(Icons.handshake)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
          : TabBarView(
              controller: _tabController,
              children: [_buildMisPropiedadesTab(), _buildMisAlquileresTab()],
            ),

      // ✅ BOTÓN CONDICIONAL: Solo visible en la pestaña 0 (Mis Propiedades)
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PropertyFormScreen(onSave: _cargarDatos),
                  ),
                ).then((_) => _cargarDatos());
              },
              backgroundColor: Colors.indigo.shade700,
              icon: const Icon(Icons.add_home, color: Colors.white),
              label: const Text(
                'Nueva Propiedad',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null, // En la pestaña de Alquileres no hay botón
    );
  }

  // ==========================================
  // WIDGET: PESTAÑA MIS PROPIEDADES
  // ==========================================
  Widget _buildMisPropiedadesTab() {
    return Column(
      children: [
        // Barra de Filtros Horizontal
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.grey[100],
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['TODOS', 'DISPONIBLE', 'ALQUILADA', 'MANTENIMIENTO']
                  .map((estado) {
                    final isSelected = _filtroEstado == estado;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          estado == 'TODOS' ? 'Todos' : estado.capitalize(),
                        ),
                        selected: isSelected,
                        onSelected: (_) =>
                            setState(() => _filtroEstado = estado),
                        backgroundColor: Colors.white,
                        selectedColor: Colors.indigo.shade100,
                        checkmarkColor: Colors.indigo.shade700,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.indigo.shade900
                              : Colors.grey[700],
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  })
                  .toList(),
            ),
          ),
        ),

        // Lista de Propiedades Filtradas
        Expanded(
          child: _propiedadesFiltradas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.home_outlined,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tienes propiedades ${_filtroEstado == 'TODOS' ? '' : 'en estado $_filtroEstado'}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _propiedadesFiltradas.length,
                  itemBuilder: (context, index) {
                    final p = _propiedadesFiltradas[index];
                    return _PropertyCard(
                      propiedad: p,
                      onDelete: () => _eliminarPropiedad(p.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ==========================================
  // WIDGET: PESTAÑA MIS ALQUILERES
  // ==========================================
  Widget _buildMisAlquileresTab() {
    if (_misAlquileres.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.handshake_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No tienes alquileres activos',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Las propiedades que alquiles aparecerán aquí con sus fechas.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _misAlquileres.length,
      itemBuilder: (context, index) {
        final p = _misAlquileres[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Icon(Icons.calendar_today, color: Colors.green.shade700),
            ),
            title: Text(
              p.direccion,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Desde: ${p.createdAt ?? 'N/A'}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  'Hasta: ${p.updatedAt ?? 'N/A'}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            trailing: Chip(
              label: const Text(
                'Activo',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
              backgroundColor: Colors.green.shade600,
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        );
      },
    );
  }

  Future<void> _eliminarPropiedad(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('¿Eliminar propiedad?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await _service.eliminarPropiedad(id);
      if (result['success']) {
        _cargarDatos();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Propiedad eliminada'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error']), backgroundColor: Colors.red),
        );
      }
    }
  }
}

// Extensión para capitalizar texto
extension StringCapitalization on String {
  String capitalize() =>
      '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
}

// ==========================================
// WIDGET: TARJETA DE PROPIEDAD REUTILIZABLE
// ==========================================
class _PropertyCard extends StatelessWidget {
  final Propiedad propiedad;
  final VoidCallback onDelete;

  const _PropertyCard({required this.propiedad, required this.onDelete});

  Color _getColorByStatus(String status) {
    switch (status.toUpperCase()) {
      case 'DISPONIBLE':
        return Colors.blue;
      case 'ALQUILADA':
        return Colors.green;
      case 'MANTENIMIENTO':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorByStatus(propiedad.estado);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  PropertyFormScreen(propiedad: propiedad, onSave: () {}),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  '${AppConstants.baseUrl}${propiedad.imagenUrl ?? ''}',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: color.withOpacity(0.2),
                    child: Icon(Icons.home, color: color),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      propiedad.direccion,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${propiedad.precioMensual.toStringAsFixed(2)}/mes',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(
                        propiedad.estado.capitalize(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                      backgroundColor: color,
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ),

              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onDelete,
                tooltip: 'Eliminar',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
