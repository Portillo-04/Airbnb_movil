import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/contrato_model.dart';
import '../models/solicitud_alquiler_model.dart';
import '../services/contrato_service.dart';
import '../services/propiedad_service.dart';

class OwnerContractUploadScreen extends StatefulWidget {
  final SolicitudAlquiler solicitud;

  const OwnerContractUploadScreen({super.key, required this.solicitud});

  @override
  State<OwnerContractUploadScreen> createState() => _OwnerContractUploadScreenState();
}

class _OwnerContractUploadScreenState extends State<OwnerContractUploadScreen> {
  final ContratoService _contratoService = ContratoService();
  final PropiedadService _propiedadService = PropiedadService();
  final _urlCtrl = TextEditingController();
  
  bool _isLoading = false;
  bool _creandoContrato = false;
  Contrato? _contratoExistente;

  @override
  void initState() {
    super.initState();
    _buscarContratoExistente();
  }

  Future<void> _buscarContratoExistente() async {
    setState(() => _isLoading = true);
    try {
      final contratos = await _contratoService.obtenerTodosContratos();
      final encontrado = contratos.where((c) => 
        c.propiedadId == widget.solicitud.propiedadId && 
        c.inquilinoId == widget.solicitud.inquilinoId
      ).toList();
      
      if (encontrado.isNotEmpty) {
        setState(() => _contratoExistente = encontrado.first);
        if (_contratoExistente!.pdfUrl != null && _contratoExistente!.pdfUrl!.isNotEmpty) {
          _urlCtrl.text = _contratoExistente!.pdfUrl!;
        }
      }
    } catch (e) {
      print('❌ Error al buscar contrato: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _guardarContrato() async {
    final url = _urlCtrl.text.trim();
    if (url.isEmpty || !url.contains('http')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un enlace válido (debe empezar con http o https)'), 
          backgroundColor: Colors.red
        ),
      );
      return;
    }

    setState(() => _creandoContrato = true);

    try {
      if (_contratoExistente != null) {
        // Actualizar contrato existente
        final result = await _contratoService.actualizarContrato(
          id: _contratoExistente!.id,
          pdfUrl: url,
          estado: 'activo',
        );

        if (mounted) {
          if (result['success']) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Enlace del contrato actualizado'), backgroundColor: Colors.green),
            );
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result['error']), backgroundColor: Colors.red),
            );
          }
        }
      } else {
        // Crear contrato nuevo
        final property = await _propiedadService.obtenerPorId(widget.solicitud.propiedadId);
        
        final response = await _contratoService.crearContratoConPdf(
          propiedadId: widget.solicitud.propiedadId,
          inquilinoId: widget.solicitud.inquilinoId,
          fechaInicio: widget.solicitud.fechaInicio,
          fechaFin: widget.solicitud.fechaFin,
          precioMensual: property.precioMensual,
          pdfUrl: url,
        );

        if (mounted) {
          if (response['success']) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Contrato creado exitosamente'), backgroundColor: Colors.green),
            );
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response['error']), backgroundColor: Colors.red),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _creandoContrato = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Contrato'),
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
        child: _isLoading || _creandoContrato
            ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Información de la Solicitud', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Row(children: [const Icon(Icons.person, color: Colors.indigo), const SizedBox(width: 8), Expanded(child: Text('Inquilino: ${widget.solicitud.inquilinoNombre ?? "Desconocido"}'))]),
                            const SizedBox(height: 8),
                            Row(children: [const Icon(Icons.calendar_today, color: Colors.indigo), const SizedBox(width: 8), Text('Del ${_formatearFecha(widget.solicitud.fechaInicio)} al ${_formatearFecha(widget.solicitud.fechaFin)}')]),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

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
                                Icon(Icons.link, color: Colors.indigo.shade700),
                                const SizedBox(width: 8),
                                const Text('Enlace al Contrato (PDF)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '1. Sube tu PDF a Google Drive o Dropbox.\n2. Haz clic en "Compartir" -> "Copiar enlace".\n3. Pega el enlace aquí abajo:',
                              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _urlCtrl,
                              decoration: InputDecoration(
                                hintText: 'https://drive.google.com/...',
                                prefixIcon: const Icon(Icons.http, color: Colors.grey),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              keyboardType: TextInputType.url,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _guardarContrato,
                        icon: const Icon(Icons.check),
                        label: Text(_contratoExistente != null ? 'Actualizar Enlace' : 'Crear Contrato', style: const TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
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
}