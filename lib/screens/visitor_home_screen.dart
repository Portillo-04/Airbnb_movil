import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/propiedad_model.dart';
import '../services/propiedad_service.dart';
import '../core/constants.dart'; // ✅ IMPORTANTE: Para usar la URL base remota
import 'property_detail_screen.dart';
import 'login_screen.dart';

class VisitorHomeScreen extends StatefulWidget {
  const VisitorHomeScreen({super.key});

  @override
  State<VisitorHomeScreen> createState() => _VisitorHomeScreenState();
}

class _VisitorHomeScreenState extends State<VisitorHomeScreen> {
  final PropiedadService _service = PropiedadService();
  List<Propiedad> _propiedades = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarPropiedades();
  }

  Future<void> _cargarPropiedades() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🏠 Cargando propiedades disponibles...');
      final data = await _service.obtenerDisponibles();
      print('✅ Viviendas disponibles: ${data.length}');

      if (mounted) {
        setState(() {
          _propiedades = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error al cargar propiedades: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'es_SV', symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Viviendas Disponibles'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.login_rounded),
          tooltip: 'Iniciar Sesión',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar lista',
            onPressed: _cargarPropiedades,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade50, Colors.white],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.indigo),
              )
            : _errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _cargarPropiedades,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            : _propiedades.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.home_outlined,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay viviendas disponibles',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vuelve a consultar más tarde',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _cargarPropiedades,
                color: Colors.indigo.shade700,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _propiedades.length,
                  itemBuilder: (context, index) {
                    final p = _propiedades[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PropertyDetailScreen(propiedad: p),
                          ),
                        ),
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child:
                                  p.imagenUrl != null && p.imagenUrl!.isNotEmpty
                                  ? Image.network(
                                      // ✅ CORREGIDO: Usa la IP remota desde constants
                                      '${AppConstants.baseUrl}${p.imagenUrl}',
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _placeholder(),
                                    )
                                  : _placeholder(),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.direccion ?? 'Sin dirección',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${formatter.format(p.precioMensual)}/mes',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    p.descripcion ?? '',
                                    style: TextStyle(color: Colors.grey[600]),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        color: Colors.indigo.shade700,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Disponible para alquiler',
                                          style: TextStyle(
                                            color: Colors.indigo.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade600,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: const Text(
                                          'Disponible',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
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
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 200,
      color: Colors.indigo.shade100,
      child: Icon(
        Icons.image_outlined,
        size: 60,
        color: Colors.indigo.shade300,
      ),
    );
  }
}
