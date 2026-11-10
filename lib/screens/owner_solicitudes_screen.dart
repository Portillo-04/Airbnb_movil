import 'package:flutter/material.dart';
import '../services/solicitud_alquiler_service.dart'; // Asegurate de tener este servicio
import '../models/solicitud_alquiler_model.dart'; // Asegurate de tener este modelo

class OwnerSolicitudesScreen extends StatefulWidget {
  const OwnerSolicitudesScreen({super.key});

  @override
  State<OwnerSolicitudesScreen> createState() => _OwnerSolicitudesScreenState();
}

class _OwnerSolicitudesScreenState extends State<OwnerSolicitudesScreen> {
  final SolicitudAlquilerService _service = SolicitudAlquilerService();
  List<SolicitudAlquiler> _solicitudes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarSolicitudes();
  }

  Future<void> _cargarSolicitudes() async {
    setState(() => _isLoading = true);
    try {
      // Llama al GET /solicitudes-alquiler/ que ya filtró por propietario en backend
      final data = await _service.obtenerSolicitudesPropietario();
      if (mounted) {
        setState(() {
          _solicitudes = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _responderSolicitud(int id, String nuevoEstado) async {
    try {
      await _service.responderSolicitud(id: id, estado: nuevoEstado);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Solicitud $nuevoEstado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      _cargarSolicitudes(); // Recargar lista
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al responder: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getStatusColor(String? estado) {
    switch (estado?.toUpperCase()) {
      case 'PENDIENTE':
        return Colors.orange;
      case 'APROBADA':
        return Colors.green;
      case 'RECHAZADA':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes de Alquiler'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
          : _solicitudes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay solicitudes pendientes',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _cargarSolicitudes,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _solicitudes.length,
                itemBuilder: (context, index) {
                  final s = _solicitudes[index];
                  final esPendiente = s.estado?.toUpperCase() == 'PENDIENTE';

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                                  s.inquilinoNombre ??
                                      'Inquilino Desconocido', // ✅ Usa el campo que agregamos
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    s.estado,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  s.estado ?? 'N/A',
                                  style: TextStyle(
                                    color: _getStatusColor(s.estado),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Fechas: ${s.fechaInicio?.toString().substring(0, 10)} - ${s.fechaFin?.toString().substring(0, 10)}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),

                          if (esPendiente) ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _responderSolicitud(s.id!, 'APROBADA'),
                                    icon: const Icon(Icons.check, size: 18),
                                    label: const Text('Aprobar'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        _responderSolicitud(s.id!, 'RECHAZADA'),
                                    icon: const Icon(Icons.close, size: 18),
                                    label: const Text('Rechazar'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: BorderSide(color: Colors.red),
                                    ),
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
    );
  }
}
