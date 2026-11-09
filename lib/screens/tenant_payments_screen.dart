import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/pago_model.dart';
import '../models/contrato_model.dart';
import '../services/pago_service.dart';
import '../services/contrato_service.dart';
import '../services/paypal_service.dart';

class TenantPaymentsScreen extends StatefulWidget {
  const TenantPaymentsScreen({super.key});

  @override
  State<TenantPaymentsScreen> createState() => _TenantPaymentsScreenState();
}

class _TenantPaymentsScreenState extends State<TenantPaymentsScreen> {
  final PagoService _pagoService = PagoService();
  final ContratoService _contratoService = ContratoService();
  final PayPalService _paypalService = PayPalService();
  
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
      print('💰 Pagos: ${pagos.length}, Contratos activos: ${_contratos.length}');
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

  void _pagarConPayPal(Contrato contrato) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pagar con PayPal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Contrato #${contrato.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Monto: \$${contrato.precioMensual.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            const Text('Serás redirigido a PayPal para completar el pago de forma segura.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _procesarPagoPayPal(contrato);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700),
            child: const Text('Continuar con PayPal'),
          ),
        ],
      ),
    );
  }

  Future<void> _procesarPagoPayPal(Contrato contrato) async {
    // Mostrar loading
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    // 1. Crear orden en PayPal
    final result = await _paypalService.crearOrden(
      monto: contrato.precioMensual,
      descripcion: 'Pago de alquiler - Contrato #${contrato.id}',
    );

    if (mounted) Navigator.pop(context);

    if (result['success']) {
      final approvalUrl = result['approval_url'] as String;
      final orderId = result['order_id'] as String;

      // 2. Abrir PayPal en el navegador
      final uri = Uri.parse(approvalUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        // 3. Esperar a que el usuario complete el pago
        // En una app real, esto se haría con un webhook o deep link
        // Por ahora, simulamos que el usuario aprobó después de 3 segundos
        
        if (mounted) {
          await Future.delayed(const Duration(seconds: 3));
          
          // 4. Capturar el pago
          final captureResult = await _paypalService.capturarPago(orderId);
          
          if (captureResult['success']) {
            final transactionId = captureResult['transaction_id'] as String;
            
            // 5. Registrar el pago en nuestra base de datos
            final pagoResult = await _pagoService.registrarPago(
              contratoId: contrato.id,
              monto: contrato.precioMensual,
              fechaPago: DateFormat('yyyy-MM-dd').format(DateTime.now()),
              metodoPago: 'paypal',
              descripcion: 'Pago via PayPal - Orden $orderId',
              transactionId: transactionId,
            );

            if (mounted) {
              if (pagoResult['success']) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Pago registrado exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
                _cargarDatos();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(pagoResult['error']),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(captureResult['error']),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo abrir PayPal'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _colorMetodo(String metodo) {
    switch (metodo.toLowerCase()) {
      case 'efectivo': return Colors.green;
      case 'transferencia': return Colors.blue;
      case 'tarjeta': return Colors.purple;
      case 'paypal': return Colors.blue.shade700;
      default: return Colors.grey;
    }
  }

  IconData _iconoMetodo(String metodo) {
    switch (metodo.toLowerCase()) {
      case 'efectivo': return Icons.money;
      case 'transferencia': return Icons.account_balance;
      case 'tarjeta': return Icons.credit_card;
      case 'paypal': return Icons.payment;
      default: return Icons.payment;
    }
  }

  String _formatearMetodo(String metodo) {
    return metodo[0].toUpperCase() + metodo.substring(1).toLowerCase();
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
    final formatter = NumberFormat.currency(locale: 'es_SV', symbol: '\$');

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Pagos')),
      floatingActionButton: _contratos.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _mostrarDialogoPago(),
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
                                      if (p.paypalTransactionId != null) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.verified, size: 12, color: Colors.blue.shade700),
                                            const SizedBox(width: 4),
                                            Text(
                                              'PayPal: ${p.paypalTransactionId}',
                                              style: TextStyle(color: Colors.blue.shade700, fontSize: 10),
                                            ),
                                          ],
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

  void _mostrarDialogoPago() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Contrato'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _contratos.length,
            itemBuilder: (context, index) {
              final contrato = _contratos[index];
              return ListTile(
                leading: const Icon(Icons.home, color: Colors.indigo),
                title: Text('Contrato #${contrato.id}'),
                subtitle: Text('\$${contrato.precioMensual.toStringAsFixed(2)}/mes'),
                onTap: () {
                  Navigator.pop(context);
                  _pagarConPayPal(contrato);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}