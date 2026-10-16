import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/propiedad_model.dart';
import '../services/propiedad_service.dart';
import 'property_detail_screen.dart';

class TenantAvailablePropertiesScreen extends StatefulWidget {
  const TenantAvailablePropertiesScreen({super.key});

  @override
  State<TenantAvailablePropertiesScreen> createState() => _TenantAvailablePropertiesScreenState();
}

class _TenantAvailablePropertiesScreenState extends State<TenantAvailablePropertiesScreen> {
  final PropiedadService _service = PropiedadService();
  List<Propiedad> _propiedades = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarPropiedades();
  }

  Future<void> _cargarPropiedades() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.obtenerDisponibles();
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
      appBar: AppBar(title: const Text('Viviendas Disponibles')),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.blue.shade50, Colors.white])),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.blue))
            : _propiedades.isEmpty
                ? const Center(child: Text('No hay viviendas disponibles en este momento'))
                : RefreshIndicator(
                    onRefresh: _cargarPropiedades,
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
                                      Text(p.direccion, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 8),
                                      Text(formatter.format(p.precioMensual) + '/mes', style: TextStyle(color: Colors.green.shade700, fontSize: 18, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      Text(p.descripcion, style: TextStyle(color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
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
    return Container(height: 180, color: Colors.blue.shade100, child: Icon(Icons.home, size: 60, color: Colors.blue.shade300));
  }
}