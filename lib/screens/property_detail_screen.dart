import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/propiedad_model.dart';
import '../providers/auth_provider.dart';
import '../models/usuario_model.dart';
import '../services/solicitud_alquiler_service.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Propiedad propiedad;
  const PropertyDetailScreen({super.key, required this.propiedad});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final SolicitudAlquilerService _solicitudService = SolicitudAlquilerService();

  void _solicitarVisita() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Solicitar Visita'),
        content: const Text('Se ha enviado tu solicitud de visita. El propietario se contactará contigo pronto.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Entendido')),
        ],
      ),
    );
  }

  void _rentarPropiedad() {
    showDialog(
      context: context,
      builder: (context) => _DialogRentar(propiedad: widget.propiedad),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'es_SV', symbol: '\$');
    final authProvider = context.watch<AuthProvider>();
    final rol = authProvider.usuario?.rol;

    print('👤 Rol del usuario: $rol');  // ✅ Log para debug

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Propiedad')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            (widget.propiedad.imagenUrl?.isNotEmpty ?? false)
                ? Image.network(widget.propiedad.imagenUrl!, width: double.infinity, height: 250, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 250, color: Colors.grey[300], child: const Icon(Icons.home, size: 80)))
                : Container(height: 250, color: Colors.grey[300], child: const Center(child: Icon(Icons.home, size: 80))),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(widget.propiedad.direccion, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: widget.propiedad.estado == 'DISPONIBLE' ? Colors.green : Colors.orange, borderRadius: BorderRadius.circular(20)),
                        child: Text(widget.propiedad.estado, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(formatter.format(widget.propiedad.precioMensual), style: const TextStyle(fontSize: 24, color: Colors.green, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('Descripción:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(widget.propiedad.descripcion, style: const TextStyle(fontSize: 16, height: 1.5)),
                  const SizedBox(height: 24),

                  // ✅ Botón para Visitantes
                  if (rol == RolUsuario.visitante && widget.propiedad.estado == 'DISPONIBLE') ...[
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text('¿Te interesa esta propiedad?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _solicitarVisita,
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Solicitar Visita / Información'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],

                  // ✅ Botón para Inquilinos
                  if (rol == RolUsuario.inquilino && widget.propiedad.estado == 'DISPONIBLE') ...[
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text('¿Quieres alquilar esta propiedad?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _rentarPropiedad,
                        icon: const Icon(Icons.home_work),
                        label: const Text('Quiero Alquilar'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Diálogo para solicitar alquiler
class _DialogRentar extends StatefulWidget {
  final Propiedad propiedad;
  const _DialogRentar({required this.propiedad});

  @override
  State<_DialogRentar> createState() => _DialogRentarState();
}

class _DialogRentarState extends State<_DialogRentar> {
  final _formKey = GlobalKey<FormState>();
  final _fechaInicioCtrl = TextEditingController();
  final _fechaFinCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _seleccionarFecha(TextEditingController controller) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (fecha != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(fecha);
    }
  }

  Future<void> _confirmarSolicitud() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    print('📤 Enviando solicitud:');
    print('   Propiedad ID: ${widget.propiedad.id}');
    print('   Fecha inicio: ${_fechaInicioCtrl.text}');
    print('   Fecha fin: ${_fechaFinCtrl.text}');

    final result = await SolicitudAlquilerService().crearSolicitud(
      propiedadId: widget.propiedad.id,
      fechaInicio: _fechaInicioCtrl.text,
      fechaFin: _fechaFinCtrl.text,
    );

    print('📥 Respuesta: $result');

    setState(() => _isLoading = false);

    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud enviada. El propietario revisará tu solicitud.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context); // Cerrar diálogo
        Navigator.pop(context); // Volver a la lista
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Error al enviar solicitud'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Solicitar Alquiler'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Propiedad: ${widget.propiedad.direccion}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fechaInicioCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Fecha de inicio',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _seleccionarFecha(_fechaInicioCtrl),
                validator: (v) => v == null || v.isEmpty ? 'Selecciona fecha de inicio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _fechaFinCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Fecha de fin',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _seleccionarFecha(_fechaFinCtrl),
                validator: (v) => v == null || v.isEmpty ? 'Selecciona fecha de fin' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _confirmarSolicitud,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Enviar Solicitud'),
        ),
      ],
    );
  }
}