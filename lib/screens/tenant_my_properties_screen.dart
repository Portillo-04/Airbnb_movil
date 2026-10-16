import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/propiedad_model.dart';
import '../services/propiedad_service.dart';
import 'property_detail_screen.dart';

class TenantMyPropertiesScreen extends StatefulWidget {
  const TenantMyPropertiesScreen({super.key});

  @override
  State<TenantMyPropertiesScreen> createState() => _TenantMyPropertiesScreenState();
}

class _TenantMyPropertiesScreenState extends State<TenantMyPropertiesScreen> {
  final PropiedadService _service = PropiedadService();
  List<Propiedad> _propiedades = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarMisPropiedades();
  }

  Future<void> _cargarMisPropiedades() async {
    setState(() => _isLoading = true);
    try {
      // ✅ Este método obtiene solo las propiedades con contrato activo del inquilino
      final data = await _service.obtenerPropiedadesAlquiladas();
      setState(() => _propiedades = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'es_SV', symbol: '\$');

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Viviendas')),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.green.shade50, Colors.white])),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.green))
            : _propiedades.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home_outlined, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('Aún no has alquilado ninguna vivienda', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.search),
                          label: const Text('Buscar viviendas'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _cargarMisPropiedades,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _propiedades.length,
                      itemBuilder: (context, index) {
                        final p = _propiedades[index];
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: InkWell(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailScreen(propiedad: p))),
                            borderRadius: BorderRadius.circular(16),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  child: p.imagenUrl != null && p.imagenUrl!.isNotEmpty
                                      ? Image.network('http://127.0.0.1:8000${p.imagenUrl}', height: 180, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder())
                                      : _placeholder(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                                          const SizedBox(width: 8),
                                          const Text('Contrato Activo', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(p.direccion, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(height: 8),
                                      Text(formatter.format(p.precioMensual) + '/mes', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
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
    return Container(height: 180, color: Colors.green.shade100, child: Icon(Icons.home, size: 60, color: Colors.green.shade300));
  }
}