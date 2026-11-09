import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/propiedad_model.dart';
import '../models/contrato_model.dart';
import '../services/propiedad_service.dart';
import '../services/contrato_service.dart';
import 'property_detail_screen.dart';

class TenantPropertyScreen extends StatefulWidget {
  const TenantPropertyScreen({super.key});

  @override
  State<TenantPropertyScreen> createState() => _TenantPropertyScreenState();
}

class _TenantPropertyScreenState extends State<TenantPropertyScreen> {
  final ContratoService _contratoService = ContratoService();
  final PropiedadService _propiedadService = PropiedadService();
  List<Propiedad> _propiedadesAlquiladas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarMiVivienda();
  }

  Future<void> _cargarMiVivienda() async {
    setState(() => _isLoading = true);
    try {
      // Obtener contratos del inquilino
      final contratos = await _contratoService.obtenerContratosInquilino();
      
      // Para cada contrato, obtener la propiedad
      List<Propiedad> propiedades = [];
      for (var contrato in contratos) {
        if (contrato.estado == 'ACTIVO') {
          try {
            final propiedad = await _propiedadService.obtenerPorId(contrato.propiedadId);
            propiedades.add(propiedad);
          } catch (e) {
            print('Error al cargar propiedad: $e');
          }
        }
      }
      
      setState(() => _propiedadesAlquiladas = propiedades);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'es_SV', symbol: '\$');

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Vivienda')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _propiedadesAlquiladas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home_outlined, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No tienes viviendas alquiladas',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _propiedadesAlquiladas.length,
                  itemBuilder: (context, index) {
                    final prop = _propiedadesAlquiladas[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PropertyDetailScreen(propiedad: prop)),
                        ),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.indigo.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(Icons.home, color: Colors.indigo.shade700, size: 40),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          prop.direccion,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          formatter.format(prop.precioMensual) + '/mes',
                                          style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                                  const SizedBox(width: 8),
                                  const Text('Contrato activo', style: TextStyle(fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}