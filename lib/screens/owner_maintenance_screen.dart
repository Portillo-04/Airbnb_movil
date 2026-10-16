import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mantenimiento_model.dart';
import '../services/mantenimiento_service.dart';

class OwnerMaintenanceScreen extends StatefulWidget {
  const OwnerMaintenanceScreen({super.key});

  @override
  State<OwnerMaintenanceScreen> createState() => _OwnerMaintenanceScreenState();
}

class _OwnerMaintenanceScreenState extends State<OwnerMaintenanceScreen> {
  final MantenimientoService _service = MantenimientoService();
  List<SolicitudMantenimiento> _solicitudes = [];
  bool _isLoading = true;
  String _filtroEstado = 'TODAS';

  @override
  void initState() {
    super.initState();
    _cargarSolicitudes();
  }

  Future<void> _cargarSolicitudes() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.obtenerSolicitudesPropietario();
      setState(() => _solicitudes = data);
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

  List<SolicitudMantenimiento> get _solicitudesFiltradas {
    if (_filtroEstado == 'TODAS') return _solicitudes;
    return _solicitudes.where((s) => s.estado == _filtroEstado).toList();
  }

  void _actualizarEstado(SolicitudMantenimiento solicitud, String nuevoEstado) {
    showDialog(
      context: context,
      builder: (context) => _DialogRespuesta(
        solicitud: solicitud,
        nuevoEstado: nuevoEstado,
        onConfirm: (respuesta) async {
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(child: CircularProgressIndicator()),
            );
          }

          final result = await _service.actualizarEstado(
            solicitudId: solicitud.id,
            nuevoEstado: nuevoEstado,
            descripcion: respuesta,
          );

          if (mounted) Navigator.pop(context);

          if (mounted) {
            if (result['success']) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Estado actualizado a ${_formatearEstado(nuevoEstado)}'), backgroundColor: Colors.green),
              );
              _cargarSolicitudes();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(result['error']), backgroundColor: Colors.red),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mantenimiento')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.indigo.shade50, Colors.white]),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _FiltroChip(label: 'Todas', isSelected: _filtroEstado == 'TODAS', onTap: () => setState(() => _filtroEstado = 'TODAS')),
                  const SizedBox(width: 8),
                  _FiltroChip(label: 'Pendientes', isSelected: _filtroEstado == 'pendiente', onTap: () => setState(() => _filtroEstado = 'pendiente')),
                  const SizedBox(width: 8),
                  _FiltroChip(label: 'En Proceso', isSelected: _filtroEstado == 'en_proceso', onTap: () => setState(() => _filtroEstado = 'en_proceso')),
                  const SizedBox(width: 8),
                  _FiltroChip(label: 'Resueltas', isSelected: _filtroEstado == 'resuelto', onTap: () => setState(() => _filtroEstado = 'resuelto')),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
                  : _solicitudesFiltradas.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.build_outlined, size: 80, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text('No hay solicitudes', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _cargarSolicitudes,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _solicitudesFiltradas.length,
                            itemBuilder: (context, index) {
                              final s = _solicitudesFiltradas[index];
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
                                            child: Text(s.titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(color: _colorEstado(s.estado), borderRadius: BorderRadius.circular(20)),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(_iconoEstado(s.estado), color: Colors.white, size: 14),
                                                const SizedBox(width: 4),
                                                Text(_formatearEstado(s.estado), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Icon(Icons.home, color: Colors.indigo.shade700, size: 18),
                                          const SizedBox(width: 8),
                                          Text('Propiedad ID: ${s.propiedadId}', style: TextStyle(color: Colors.grey[600])),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      const Text('Descripción:', style: TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text(s.descripcion, style: TextStyle(color: Colors.grey[700])),
                                      if (s.estado == 'pendiente') ...[
                                        const SizedBox(height: 12),
                                        const Divider(),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () => _actualizarEstado(s, 'en_proceso'),
                                                icon: const Icon(Icons.build, size: 16),
                                                label: const Text('En Proceso'),
                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 10)),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () => _actualizarEstado(s, 'resuelto'),
                                                icon: const Icon(Icons.check, size: 16),
                                                label: const Text('Resolver'),
                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 10)),
                                              ),
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
          ],
        ),
      ),
    );
  }
}

class _FiltroChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FiltroChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.indigo : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.indigo),
          ),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? Colors.white : Colors.indigo, fontWeight: FontWeight.bold, fontSize: 11)),
        ),
      ),
    );
  }
}

class _DialogRespuesta extends StatefulWidget {
  final SolicitudMantenimiento solicitud;
  final String nuevoEstado;
  final Function(String respuesta) onConfirm;

  const _DialogRespuesta({required this.solicitud, required this.nuevoEstado, required this.onConfirm});

  @override
  State<_DialogRespuesta> createState() => _DialogRespuestaState();
}

class _DialogRespuestaState extends State<_DialogRespuesta> {
  final _respuestaCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.nuevoEstado.replaceAll('_', ' ')} Solicitud'),
      content: SizedBox(
        width: double.maxFinite,
        child: TextField(
          controller: _respuestaCtrl,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Respuesta (opcional)', hintText: 'Ej: El técnico irá mañana...', border: OutlineInputBorder()),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () {
            widget.onConfirm(_respuestaCtrl.text);
            Navigator.pop(context);
          },
          child: Text(widget.nuevoEstado.replaceAll('_', ' ')),
        ),
      ],
    );
  }
}