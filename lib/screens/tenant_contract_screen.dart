import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/contrato_model.dart';
import '../services/contrato_service.dart';

class TenantContractScreen extends StatefulWidget {
  const TenantContractScreen({super.key});

  @override
  State<TenantContractScreen> createState() => _TenantContractScreenState();
}

class _TenantContractScreenState extends State<TenantContractScreen> {
  final ContratoService _contratoService = ContratoService();
  Contrato? _contrato;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarContrato();
  }

  Future<void> _cargarContrato() async {
    setState(() => _isLoading = true);
    try {
      final contratos = await _contratoService.obtenerContratosInquilino();
      if (contratos.isNotEmpty) {
        setState(() => _contrato = contratos.first);
      }
    } catch (e) {
      print('❌ Error al cargar contrato: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _abrirContrato() async {
    if (_contrato?.pdfUrl == null || _contrato!.pdfUrl!.isEmpty) {
      print('❌ La URL del contrato está vacía');
      return;
    }

    String rawUrl = _contrato!.pdfUrl!.trim();
    
    if (!rawUrl.startsWith('http://') && !rawUrl.startsWith('https://')) {
      rawUrl = 'https://$rawUrl';
    }

    // ✅ Convertir enlace de Drive a enlace directo de descarga
    // Si es un enlace de Google Drive, lo transformamos para que abra directo
    if (rawUrl.contains('drive.google.com')) {
      // Extraer el ID del archivo
      final uri = Uri.parse(rawUrl);
      final pathSegments = uri.pathSegments;
      
      String? fileId;
      if (pathSegments.length >= 3 && pathSegments[1] == 'file') {
        fileId = pathSegments[2];
      } else if (pathSegments.length >= 2 && pathSegments[0] == 'd') {
        fileId = pathSegments[1];
      }
      
      if (fileId != null) {
        rawUrl = 'https://drive.google.com/uc?export=download&id=$fileId';
      }
    }

    print('🔗 Abriendo URL: $rawUrl');
    final url = Uri.parse(rawUrl);

    try {
      // ✅ Forzar apertura en navegador externo (Chrome)
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        print('⚠️ No se pudo abrir automáticamente');
        _mostrarDialogoCopiarUrl(rawUrl);
      }
    } catch (e) {
      print('❌ Error: $e');
      _mostrarDialogoCopiarUrl(rawUrl);
    }
  }

  void _mostrarDialogoCopiarUrl(String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abrir Contrato'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Copia este enlace y pégalo en Chrome:'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                url,
                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Contrato'),
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
            : _contrato == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description_outlined, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No tienes un contrato activo',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.verified, color: Colors.green.shade700, size: 28),
                                    const SizedBox(width: 8),
                                    const Text('Contrato Activo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const Divider(height: 24),
                                _infoRow(Icons.home, 'Propiedad ID', _contrato!.propiedadId.toString()),
                                const SizedBox(height: 12),
                                _infoRow(Icons.calendar_today, 'Vigencia', 'Hasta ${_contrato!.fechaFin}'),
                                const SizedBox(height: 12),
                                _infoRow(Icons.attach_money, 'Monto Mensual', '\$${_contrato!.precioMensual.toStringAsFixed(2)}'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        if (_contrato!.pdfUrl != null && _contrato!.pdfUrl!.isNotEmpty)
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton.icon(
                              onPressed: _abrirContrato,
                              icon: const Icon(Icons.picture_as_pdf, size: 28),
                              label: const Text('Ver Contrato (PDF)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          )
                        else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.orange.shade700),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'El propietario aún no ha adjuntado el enlace del contrato. Por favor, contáctalo.',
                                    style: TextStyle(color: Colors.orange.shade900),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.indigo.shade700, size: 22),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ],
    );
  }
}