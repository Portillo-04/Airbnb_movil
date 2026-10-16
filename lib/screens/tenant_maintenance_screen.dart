import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mantenimiento_model.dart';
import '../models/propiedad_model.dart';
import '../services/mantenimiento_service.dart';
import '../services/propiedad_service.dart';

class TenantMaintenanceScreen extends StatefulWidget {
  const TenantMaintenanceScreen({super.key});

  @override
  State<TenantMaintenanceScreen> createState() => _TenantMaintenanceScreenState();
}

class _TenantMaintenanceScreenState extends State<TenantMaintenanceScreen> {
  final MantenimientoService _service = MantenimientoService();
  final PropiedadService _propiedadService = PropiedadService();
  List<SolicitudMantenimiento> _solicitudes = [];
  List<Propiedad> _propiedades = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      // Cargar propiedades del inquilino (las que tiene alquiladas)
      final propiedades = await _propiedadService.obtenerMisPropiedades();
      setState(() => _propiedades = propiedades);

      final solicitudes = await _service.obtenerMisSolicitudes();
      setState(() => _solicitudes = solicitudes);
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

  void _crearSolicitud() {
    if (_propiedades.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tienes propiedades alquiladas'), backgroundColor: Colors.orange),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _DialogCrearSolicitud(
        propiedades: _propiedades,
        onCreated: _cargarDatos,
      ),
    );
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'pendiente': return Colors.orange;
      case 'en_proceso': return Colors.blue;
      case 'resuelto': return Colors.green;
      case 'cancelado': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _iconoEstado(String estado) {
    switch (estado) {
      case 'pendiente': return Icons.hourglass_empty;
      case 'en_proceso': return Icons.build;
      case 'resuelto': return Icons.check_circle;
      case 'cancelado': return Icons.cancel;
      default: return Icons.info;
    }
  }

  String _formatearEstado(String estado) {
    return estado.replaceAll('_', ' ').split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mantenimiento')),
      floatingActionButton: FloatingActionButton(
        onPressed: _crearSolicitud,
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
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
            : _solicitudes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.build_outlined, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No hay solicitudes de mantenimiento',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _cargarDatos,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _solicitudes.length,
                      itemBuilder: (context, index) {
                        final s = _solicitudes[index];
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        s.titulo,
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _colorEstado(s.estado),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(_iconoEstado(s.estado), color: Colors.white, size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatearEstado(s.estado),
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Text('Descripción:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 4),
                                Text(s.descripcion, style: TextStyle(color: Colors.grey[700], height: 1.5)),
                                if (s.createdAt != null) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Creada: ${_formatearFecha(s.createdAt!)}',
                                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
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

  String _formatearFecha(String fecha) {
    try {
      final date = DateTime.parse(fecha);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return fecha;
    }
  }
}

class _DialogCrearSolicitud extends StatefulWidget {
  final List<Propiedad> propiedades;
  final VoidCallback onCreated;

  const _DialogCrearSolicitud({required this.propiedades, required this.onCreated});

  @override
  State<_DialogCrearSolicitud> createState() => _DialogCrearSolicitudState();
}

class _DialogCrearSolicitudState extends State<_DialogCrearSolicitud> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  int? _propiedadSeleccionada;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.propiedades.isNotEmpty) {
      _propiedadSeleccionada = widget.propiedades.first.id;
    }
  }

  Future<void> _crearSolicitud() async {
    if (!_formKey.currentState!.validate()) return;
    if (_propiedadSeleccionada == null) return;

    setState(() => _isLoading = true);

    final result = await MantenimientoService().crearSolicitud(
      titulo: _tituloCtrl.text,
      descripcion: _descripcionCtrl.text,
      propiedadId: _propiedadSeleccionada!,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitud creada exitosamente'), backgroundColor: Colors.green),
        );
        widget.onCreated();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error']), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crear Solicitud de Mantenimiento'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: _propiedadSeleccionada,
                decoration: const InputDecoration(labelText: 'Propiedad', prefixIcon: Icon(Icons.home)),
                items: widget.propiedades.map((p) {
                  return DropdownMenuItem(value: p.id, child: Text(p.direccion));
                }).toList(),
                onChanged: (value) => setState(() => _propiedadSeleccionada = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tituloCtrl,
                decoration: const InputDecoration(labelText: 'Título', hintText: 'Ej: Fuga de agua'),
                validator: (v) => v == null || v.isEmpty ? 'Ingresa un título' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcionCtrl,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Descripción', hintText: 'Describe el problema...', alignLabelWithHint: true),
                validator: (v) => v == null || v.isEmpty ? 'Ingresa una descripción' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: _isLoading ? null : _crearSolicitud,
          child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Crear'),
        ),
      ],
    );
  }
}