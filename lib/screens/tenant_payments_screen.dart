import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/pago_model.dart';
import '../models/contrato_model.dart';
import '../services/pago_service.dart';
import '../services/contrato_service.dart';

class TenantPaymentsScreen extends StatefulWidget {
  const TenantPaymentsScreen({super.key});

  @override
  State<TenantPaymentsScreen> createState() => _TenantPaymentsScreenState();
}

class _TenantPaymentsScreenState extends State<TenantPaymentsScreen> {
  final PagoService _pagoService = PagoService();
  final ContratoService _contratoService = ContratoService();
  List<Pago> _pagos = [];
  List<Contrato> _contratos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      final pagos = await _pagoService.obtenerMisPagos();
      final contratos = await _contratoService.obtenerContratosInquilino();
      setState(() {
        _pagos = pagos;
        _contratos = contratos.where((c) => c.estado.toLowerCase() == 'activo').toList();
      });
      print(' Pagos: ${pagos.length}, Contratos activos: ${_contratos.length}');
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

  void _registrarPago() {
    if (_contratos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes contratos activos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _DialogRegistrarPago(
        contratos: _contratos,
        onCreated: _cargarDatos,
      ),
    );
  }

  String _formatearFecha(String fecha) {
    try {
      final date = DateTime.parse(fecha);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return fecha;
    }
  }

  Color _colorMetodo(String metodo) {
    switch (metodo) {
      case 'efectivo': return Colors.green;
      case 'transferencia': return Colors.blue;
      case 'tarjeta': return Colors.purple;
      default: return Colors.grey;
    }
  }

  IconData _iconoMetodo(String metodo) {
    switch (metodo) {
      case 'efectivo': return Icons.money;
      case 'transferencia': return Icons.account_balance;
      case 'tarjeta': return Icons.credit_card;
      default: return Icons.payment;
    }
  }

  String _formatearMetodo(String metodo) {
    return metodo[0].toUpperCase() + metodo.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'es_SV', symbol: '\$');

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Pagos')),
      floatingActionButton: _contratos.isNotEmpty
          ? FloatingActionButton(
              onPressed: _registrarPago,
              backgroundColor: Colors.indigo,
              child: const Icon(Icons.add),
            )
          : null,
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
            : _pagos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.payment_outlined, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No hay pagos registrados',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                        if (_contratos.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Presiona + para registrar un pago',
                            style: TextStyle(color: Colors.grey[500], fontSize: 14),
                          ),
                        ],
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _cargarDatos,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _pagos.length,
                      itemBuilder: (context, index) {
                        final p = _pagos[index];
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _colorMetodo(p.metodoPago).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _iconoMetodo(p.metodoPago),
                                    color: _colorMetodo(p.metodoPago),
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Pago #${p.id}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Contrato #${p.contratoId}',
                                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatearFecha(p.fechaPago),
                                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                      ),
                                      if (p.descripcion != null && p.descripcion!.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          p.descripcion!,
                                          style: TextStyle(color: Colors.grey[500], fontSize: 11),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      formatter.format(p.monto),
                                      style: TextStyle(
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _colorMetodo(p.metodoPago),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _formatearMetodo(p.metodoPago),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
}

class _DialogRegistrarPago extends StatefulWidget {
  final List<Contrato> contratos;
  final VoidCallback onCreated;

  const _DialogRegistrarPago({required this.contratos, required this.onCreated});

  @override
  State<_DialogRegistrarPago> createState() => _DialogRegistrarPagoState();
}

class _DialogRegistrarPagoState extends State<_DialogRegistrarPago> {
  final _formKey = GlobalKey<FormState>();
  final _montoCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  int? _contratoSeleccionado;
  String _metodoPago = 'efectivo';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.contratos.isNotEmpty) {
      _contratoSeleccionado = widget.contratos.first.id;
      _montoCtrl.text = widget.contratos.first.precioMensual.toString();
    }
    _fechaCtrl.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (fecha != null) {
      setState(() => _fechaCtrl.text = DateFormat('yyyy-MM-dd').format(fecha));
    }
  }

  Future<void> _registrarPago() async {
    if (!_formKey.currentState!.validate()) return;
    if (_contratoSeleccionado == null) return;

    setState(() => _isLoading = true);

    print('📤 Registrando pago:');
    print('   Contrato ID: $_contratoSeleccionado');
    print('   Monto: ${_montoCtrl.text}');
    print('   Fecha: ${_fechaCtrl.text}');
    print('   Método: $_metodoPago');

    final result = await PagoService().registrarPago(
      contratoId: _contratoSeleccionado!,
      monto: double.parse(_montoCtrl.text),
      fechaPago: _fechaCtrl.text,
      metodoPago: _metodoPago,
      descripcion: _descripcionCtrl.text.isEmpty ? null : _descripcionCtrl.text,
    );

    print('📥 Resultado: $result');

    setState(() => _isLoading = false);

    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pago registrado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onCreated();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar Pago'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: _contratoSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Contrato',
                  prefixIcon: Icon(Icons.home),
                ),
                items: widget.contratos.map((c) {
                  return DropdownMenuItem(
                    value: c.id,
                    child: Text('Contrato #${c.id} - \$${c.precioMensual}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _contratoSeleccionado = value;
                    final contrato = widget.contratos.firstWhere((c) => c.id == value);
                    _montoCtrl.text = contrato.precioMensual.toString();
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _montoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v == null || v.isEmpty ? 'Ingresa el monto' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _fechaCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Fecha de pago',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                onTap: _seleccionarFecha,
                validator: (v) => v == null || v.isEmpty ? 'Selecciona una fecha' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _metodoPago,
                decoration: const InputDecoration(
                  labelText: 'Método de pago',
                  prefixIcon: Icon(Icons.payment),
                ),
                items: const [
                  DropdownMenuItem(value: 'efectivo', child: Text('Efectivo')),
                  DropdownMenuItem(value: 'transferencia', child: Text('Transferencia')),
                  DropdownMenuItem(value: 'tarjeta', child: Text('Tarjeta')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _metodoPago = value);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcionCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  hintText: 'Ej: Pago de octubre',
                  alignLabelWithHint: true,
                ),
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
          onPressed: _isLoading ? null : _registrarPago,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Registrar'),
        ),
      ],
    );
  }
}