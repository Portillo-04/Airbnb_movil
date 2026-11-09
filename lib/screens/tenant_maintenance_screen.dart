import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/contrato_model.dart';
import '../services/contrato_service.dart';

class TenantMaintenanceScreen extends StatefulWidget {
  const TenantMaintenanceScreen({super.key});

  @override
  State<TenantMaintenanceScreen> createState() => _TenantMaintenanceScreenState();
}

class _TenantMaintenanceScreenState extends State<TenantMaintenanceScreen> {
  final ContratoService _contratoService = ContratoService();
  List<Contrato> _contratos = [];
  Contrato? _contratoSeleccionado;
  bool _isLoading = true;
  final _descripcionCtrl = TextEditingController();
  final _ubicacionCtrl = TextEditingController();
  String _prioridad = 'media';

  @override
  void initState() {
    super.initState();
    _cargarContratos();
  }

  Future<void> _cargarContratos() async {
    setState(() => _isLoading = true);
    try {
      print('🏠 Cargando contratos del inquilino...');
      final contratos = await _contratoService.obtenerContratosInquilino();
      print('✅ Contratos encontrados: ${contratos.length}');
      
      if (mounted) {
        setState(() {
          _contratos = contratos;
          if (contratos.isNotEmpty) {
            _contratoSeleccionado = contratos.first;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _enviarSolicitud() async {
    if (_descripcionCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Describe el problema'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_contratoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tienes contratos activos'), backgroundColor: Colors.red),
      );
      return;
    }

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Aquí llamarías a tu servicio de mantenimiento
      // Por ahora simulamos el envío exitoso
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) Navigator.pop(context); // Quitar loading
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Solicitud de mantenimiento enviada'),
            backgroundColor: Colors.green,
          ),
        );
        _descripcionCtrl.clear();
        _ubicacionCtrl.clear();
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar Mantenimiento'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
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
            : _contratos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home_outlined, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No tienes contratos registrados',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Primero debes alquilar una propiedad',
                          style: TextStyle(color: Colors.grey[500], fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Selector de contrato/propiedad
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.home, color: Colors.indigo.shade700),
                                    const SizedBox(width: 8),
                                    const Text('Propiedad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<Contrato>(
                                  value: _contratoSeleccionado,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  items: _contratos.map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Text('Propiedad #${c.propiedadId} - \$${c.precioMensual.toStringAsFixed(2)}/mes'),
                                  )).toList(),
                                  onChanged: (value) => setState(() => _contratoSeleccionado = value),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Descripción del problema
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.description, color: Colors.indigo.shade700),
                                    const SizedBox(width: 8),
                                    const Text('Descripción del problema *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _descripcionCtrl,
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    hintText: 'Ej: La llave del baño gotea constantemente...',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Ubicación del problema
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.location_on, color: Colors.indigo.shade700),
                                    const SizedBox(width: 8),
                                    const Text('Ubicación en la propiedad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _ubicacionCtrl,
                                  decoration: InputDecoration(
                                    hintText: 'Ej: Baño principal, cocina, etc.',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Prioridad
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.priority_high, color: Colors.indigo.shade700),
                                    const SizedBox(width: 8),
                                    const Text('Prioridad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(child: _botonPrioridad('baja', 'Baja', Colors.green)),
                                    const SizedBox(width: 8),
                                    Expanded(child: _botonPrioridad('media', 'Media', Colors.orange)),
                                    const SizedBox(width: 8),
                                    Expanded(child: _botonPrioridad('alta', 'Alta', Colors.red)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Botón enviar
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            onPressed: _enviarSolicitud,
                            icon: const Icon(Icons.send, size: 22),
                            label: const Text('Enviar Solicitud', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _botonPrioridad(String valor, String texto, Color color) {
    final isSelected = _prioridad == valor;
    return GestureDetector(
      onTap: () => setState(() => _prioridad = valor),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : Colors.grey[300]!),
        ),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}