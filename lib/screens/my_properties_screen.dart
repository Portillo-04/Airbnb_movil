import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/propiedad_model.dart';
import '../services/propiedad_service.dart';
import 'property_detail_screen.dart';
import 'property_form_screen.dart';  // ✅ AGREGAR ESTA LÍNEA

class MyPropertiesScreen extends StatefulWidget {
  const MyPropertiesScreen({super.key});

  @override
  State<MyPropertiesScreen> createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends State<MyPropertiesScreen> {
  final PropiedadService _service = PropiedadService();
  final ImagePicker _picker = ImagePicker();
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
      final data = await _service.obtenerMisPropiedades();
      setState(() => _propiedades = data);
      print('🏠 Propiedades cargadas: ${data.length}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _seleccionarImagen() async {
    final XFile? imagen = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (imagen != null) {
      _nuevaPropiedad(imagen: File(imagen.path));
    }
  }

  void _nuevaPropiedad({File? imagen}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PropertyFormScreen(
          imagenInicial: imagen,
          onSave: _cargarPropiedades,
        ),
      ),
    );
  }

  void _editarPropiedad(Propiedad propiedad) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PropertyFormScreen(
          propiedad: propiedad,
          onSave: _cargarPropiedades,
        ),
      ),
    );
  }

  void _eliminarPropiedad(Propiedad propiedad) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Propiedad'),
        content: Text('¿Estás seguro de eliminar "${propiedad.direccion}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final result = await _service.eliminarPropiedad(propiedad.id);
              
              if (mounted) {
                if (result['success']) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Propiedad eliminada'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _cargarPropiedades();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['error']),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'disponible': return Colors.green;
      case 'alquilada': return Colors.blue;
      case 'mantenimiento': return Colors.orange;
      default: return Colors.grey;
    }
  }

  String _formatearEstado(String estado) {
    return estado[0].toUpperCase() + estado.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'es_SV', symbol: '\$');

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Propiedades')),
      floatingActionButton: FloatingActionButton(
        onPressed: _seleccionarImagen,
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add_a_photo),
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
            ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
            : _propiedades.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home_outlined, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No tienes propiedades registradas',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Presiona + para agregar una',
                          style: TextStyle(color: Colors.grey[500], fontSize: 14),
                        ),
                      ],
                    ),
                  )
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
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => PropertyDetailScreen(propiedad: p)),
                            ),
                            borderRadius: BorderRadius.circular(16),
                            child: Column(
                              children: [
                                // Imagen
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  child: p.imagenUrl != null && p.imagenUrl!.isNotEmpty
                                      ? Image.network(
                                          'http://127.0.0.1:8000${p.imagenUrl}',
                                          height: 200,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            height: 200,
                                            color: Colors.indigo.shade100,
                                            child: Icon(Icons.home, size: 80, color: Colors.indigo.shade300),
                                          ),
                                        )
                                      : Container(
                                          height: 200,
                                          color: Colors.indigo.shade100,
                                          child: Icon(Icons.home, size: 80, color: Colors.indigo.shade300),
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              p.direccion,
                                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: _colorEstado(p.estado),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              _formatearEstado(p.estado),
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        formatter.format(p.precioMensual) + '/mes',
                                        style: TextStyle(color: Colors.green.shade700, fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        p.descripcion,
                                        style: TextStyle(color: Colors.grey[600]),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () => _editarPropiedad(p),
                                              icon: const Icon(Icons.edit, size: 16),
                                              label: const Text('Editar'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () => _eliminarPropiedad(p),
                                              icon: const Icon(Icons.delete, size: 16),
                                              label: const Text('Eliminar'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(vertical: 12),
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
}