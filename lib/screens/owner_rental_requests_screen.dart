import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/solicitud_alquiler_model.dart';
import '../services/solicitud_alquiler_service.dart';

class OwnerRentalRequestsScreen extends StatefulWidget {
  const OwnerRentalRequestsScreen({super.key});

  @override
  State<OwnerRentalRequestsScreen> createState() => _OwnerRentalRequestsScreenState();
}

class _OwnerRentalRequestsScreenState extends State<OwnerRentalRequestsScreen> {
  final SolicitudAlquilerService _service = SolicitudAlquilerService();
  List<SolicitudAlquiler> _solicitudes = [];
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
      final data = await _service.obtenerSolicitudes();
      setState(() => _solicitudes = data);
      print(' Solicitudes cargadas: ${data.length}');
    } catch (e) {
      print('❌ Error al cargar solicitudes: $e');
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
      case 'PENDIENTE': return Colors.orange;
      case 'APROBADA': return Colors.green;
      case 'RECHAZADA': return Colors.red;
      case 'POSPUESTA': return Colors.blue;
      default: return Colors.grey;
    }
  }

  IconData _iconoEstado(String estado) {
    switch (estado) {
      case 'PENDIENTE': return Icons.hourglass_empty;
      case 'APROBADA': return Icons.check_circle;
      case 'RECHAZADA': return Icons.cancel;
      case 'POSPUESTA': return Icons.pause_circle;
      default: return Icons.info;
    }
  }

  String _formatearFecha(String fecha) {
    try {
      final date = DateTime.parse(fecha);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return fecha;
    }
  }

  List<SolicitudAlquiler> get _solicitudesFiltradas {
    if (_filtroEstado == 'TODAS') return _solicitudes;
    if (_filtroEstado == 'PENDIENTES') {
      return _solicitudes.where((s) => s.estado == 'PENDIENTE').toList();
    }
    if (_filtroEstado == 'PROCESADAS') {
      return _solicitudes.where((s) => s.estado != 'PENDIENTE').toList();
    }
    return _solicitudes;
  }

  void _actualizarEstado(SolicitudAlquiler solicitud, String nuevoEstado) {
    showDialog(
      context: context,
      builder: (context) => _DialogRespuesta(
        solicitud: solicitud,
        nuevoEstado: nuevoEstado,
        onConfirm: (respuesta) async {
          // Mostrar loading
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(
                child: CircularProgressIndicator(color: Colors.indigo),
              ),
            );
          }

          print('🔄 Llamando al servicio para solicitud #${solicitud.id}');
          print('   Nuevo estado: $nuevoEstado');

          final result = await _service.actualizarEstado(
            solicitudId: solicitud.id,
            nuevoEstado: nuevoEstado,
            respuesta: respuesta,
          );

          print('📥 Resultado: $result');

          // Cerrar loading
          if (mounted) Navigator.pop(context);

          if (mounted) {
            if (result['success']) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ Solicitud $nuevoEstado exitosamente'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              await _cargarSolicitudes();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ ${result['error'] ?? 'Error al actualizar'}'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 5),
                ),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.indigo),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Solicitudes de Alquiler',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.indigo),
                      onPressed: _cargarSolicitudes,
                    ),
                  ],
                ),
              ),

              // Filtros
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _FiltroChip(
                      label: 'Todas',
                      isSelected: _filtroEstado == 'TODAS',
                      onTap: () => setState(() => _filtroEstado = 'TODAS'),
                    ),
                    const SizedBox(width: 8),
                    _FiltroChip(
                      label: 'Pendientes',
                      isSelected: _filtroEstado == 'PENDIENTES',
                      onTap: () => setState(() => _filtroEstado = 'PENDIENTES'),
                    ),
                    const SizedBox(width: 8),
                    _FiltroChip(
                      label: 'Procesadas',
                      isSelected: _filtroEstado == 'PROCESADAS',
                      onTap: () => setState(() => _filtroEstado = 'PROCESADAS'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Lista
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
                    : _solicitudesFiltradas.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                Text(
                                  'No hay solicitudes ${_filtroEstado == 'TODAS' ? '' : _filtroEstado.toLowerCase()}',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                ),
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
                                final esPendiente = s.estado == 'PENDIENTE';

                                return Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
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
                                                'Solicitud #${s.id}',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
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
                                                    s.estado,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Icon(Icons.person, color: Colors.indigo.shade700, size: 20),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Inquilino: ${s.inquilinoNombre ?? "Desconocido"}',
                                                style: const TextStyle(fontWeight: FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today, color: Colors.indigo.shade700, size: 20),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Del ${_formatearFecha(s.fechaInicio)} al ${_formatearFecha(s.fechaFin)}',
                                                style: TextStyle(color: Colors.grey[700]),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (s.respuestaPropietario != null && s.respuestaPropietario!.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.comment, color: Colors.grey[600], size: 20),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    s.respuestaPropietario!,
                                                    style: TextStyle(color: Colors.grey[700]),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                        // ✅ Solo mostrar botones si está PENDIENTE
                                        if (esPendiente) ...[
                                          const SizedBox(height: 16),
                                          const Divider(),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ElevatedButton.icon(
                                                  onPressed: () => _actualizarEstado(s, 'APROBADA'),
                                                  icon: const Icon(Icons.check),
                                                  label: const Text('Aceptar'),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.green,
                                                    foregroundColor: Colors.white,
                                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: ElevatedButton.icon(
                                                  onPressed: () => _actualizarEstado(s, 'RECHAZADA'),
                                                  icon: const Icon(Icons.close),
                                                  label: const Text('Rechazar'),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                    foregroundColor: Colors.white,
                                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: ElevatedButton.icon(
                                                  onPressed: () => _actualizarEstado(s, 'POSPUESTA'),
                                                  icon: const Icon(Icons.pause),
                                                  label: const Text('Posponer'),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.blue,
                                                    foregroundColor: Colors.white,
                                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ] else ...[
                                          // ✅ Mostrar estado procesado sin botones
                                          const SizedBox(height: 16),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: _colorEstado(s.estado).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  _iconoEstado(s.estado),
                                                  color: _colorEstado(s.estado),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    'Solicitud ${s.estado.toLowerCase()}',
                                                    style: TextStyle(
                                                      color: _colorEstado(s.estado),
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
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
      ),
    );
  }
}

// Widget para los chips de filtro
class _FiltroChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FiltroChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.indigo : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.indigo),
            boxShadow: isSelected ? [
              BoxShadow(
                color: Colors.indigo.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.indigo,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

// Diálogo para respuesta del propietario
class _DialogRespuesta extends StatefulWidget {
  final SolicitudAlquiler solicitud;
  final String nuevoEstado;
  final Function(String respuesta) onConfirm;

  const _DialogRespuesta({
    required this.solicitud,
    required this.nuevoEstado,
    required this.onConfirm,
  });

  @override
  State<_DialogRespuesta> createState() => _DialogRespuestaState();
}

class _DialogRespuestaState extends State<_DialogRespuesta> {
  final _respuestaCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.nuevoEstado} Solicitud #${widget.solicitud.id}'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Inquilino: ${widget.solicitud.inquilinoNombre}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _respuestaCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Mensaje (opcional)',
                hintText: 'Ej: Me gustaría posponer para el próximo mes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onConfirm(_respuestaCtrl.text);
            Navigator.pop(context);
          },
          child: Text(widget.nuevoEstado),
        ),
      ],
    );
  }
}