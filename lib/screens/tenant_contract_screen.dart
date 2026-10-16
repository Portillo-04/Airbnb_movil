import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/contrato_model.dart';
import '../services/contrato_service.dart';

class TenantContractScreen extends StatefulWidget {
  const TenantContractScreen({super.key});

  @override
  State<TenantContractScreen> createState() => _TenantContractScreenState();
}

class _TenantContractScreenState extends State<TenantContractScreen> {
  final ContratoService _service = ContratoService();
  List<Contrato> _contratos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarContratos();
  }

  Future<void> _cargarContratos() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.obtenerContratosInquilino();
      print('📋 Contratos recibidos: ${data.length}');
      for (var c in data) {
        print('   - ID: ${c.id}, Estado: ${c.estado}, Precio: ${c.precioMensual}');
      }
      setState(() => _contratos = data);
    } catch (e) {
      print('❌ Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ✅ Formatear fecha
  String _formatearFecha(String fecha) {
    try {
      final date = DateTime.parse(fecha);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return fecha;
    }
  }

  // ✅ Color según estado (la API devuelve minúsculas: "activo", "finalizado", "cancelado")
  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'activo': return Colors.green;
      case 'finalizado': return Colors.blue;
      case 'cancelado': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'es_SV', symbol: '\$');

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Contrato')),
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
                        Icon(Icons.description_outlined, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No tienes contratos activos',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _contratos.length,
                    itemBuilder: (context, index) {
                      final c = _contratos[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Contrato #${c.id}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _colorEstado(c.estado),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      c.estado.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              _InfoRow(
                                icon: Icons.calendar_today,
                                label: 'Fecha de inicio',
                                value: _formatearFecha(c.fechaInicio),
                              ),
                              const SizedBox(height: 12),
                              _InfoRow(
                                icon: Icons.event,
                                label: 'Fecha de fin',
                                value: _formatearFecha(c.fechaFin),
                              ),
                              const SizedBox(height: 12),
                              _InfoRow(
                                icon: Icons.attach_money,
                                label: 'Monto mensual',
                                value: formatter.format(c.precioMensual),
                                valueColor: Colors.green.shade700,
                              ),
                              const SizedBox(height: 12),
                              _InfoRow(
                                icon: Icons.home,
                                label: 'Propiedad ID',
                                value: '#${c.propiedadId}',
                              ),
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.indigo.shade700, size: 20),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}