import 'package:flutter/material.dart';
import '../models/pago_model.dart';
// import '../services/pago_service.dart';

class OwnerPaymentsScreen extends StatefulWidget {
  const OwnerPaymentsScreen({super.key});

  @override
  State<OwnerPaymentsScreen> createState() => _OwnerPaymentsScreenState();
}

class _OwnerPaymentsScreenState extends State<OwnerPaymentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Pago> _pagosRecibidos = [];
  List<Pago> _pagosRealizados = [];
  bool _isLoading = true;
  bool _isProcessingPayment = false;

  // ✅ ESTADO DEL FILTRO ACTIVO (Solo aplica a Me Han Pagado)
  String _filtroEstado = 'TODOS';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    // TODO: _pagosRecibidos = await _service.obtenerPagosDeMisPropiedades();
    // TODO: _pagosRealizados = await _service.obtenerMisPagosRealizados();

    if (mounted) setState(() => _isLoading = false);
  }

  // ✅ GETTER PARA FILTRADO DINÁMICO EN ME HAN PAGADO
  List<Pago> get _pagosFiltrados {
    // Como tu modelo actual no tiene 'estado', por defecto muestra todos
    // Cuando agregues el campo 'estado' a Pago, descomenta la línea de abajo:
    // if (_filtroEstado == 'TODOS') return _pagosRecibidos;
    // return _pagosRecibidos.where((p) => p.estado.toLowerCase() == _filtroEstado.toLowerCase()).toList();
    return _pagosRecibidos;
  }

  // ✅ MÉTODO PARA PROCESAR PAGO VÍA PAYPAL
  Future<void> _iniciarPagoPayPal(Pago pago) async {
    if (_isProcessingPayment) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pagar con PayPal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Monto a transferir: \$${pago.monto.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text(
              'Concepto: Alquiler mensual',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            const Text(
              'Serás redirigido a PayPal para completar la transferencia.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.account_balance_wallet),
            label: const Text('Continuar a PayPal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003087),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isProcessingPayment = true);

      try {
        await Future.delayed(const Duration(seconds: 2));

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Pago procesado exitosamente vía PayPal'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en PayPal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) setState(() => _isProcessingPayment = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Pagos'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Me Han Pagado', icon: Icon(Icons.arrow_downward)),
            Tab(text: 'He Pagado', icon: Icon(Icons.arrow_upward)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ✅ BARRA DE FILTROS: SOLO VISIBLE EN PESTAÑA 0 ("ME HAN PAGADO")
                if (_tabController.index == 0)
                  Container(
                    color: Colors.grey[100],
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: ['TODOS', 'PAGADOS', 'PENDIENTE'].map((
                          estado,
                        ) {
                          final isSelected = _filtroEstado == estado;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(
                                estado == 'TODOS'
                                    ? 'Todos'
                                    : _traducirEstado(estado),
                              ),
                              selected: isSelected,
                              onSelected: (_) =>
                                  setState(() => _filtroEstado = estado),
                              backgroundColor: Colors.white,
                              selectedColor: Colors.indigo.shade100,
                              checkmarkColor: Colors.indigo.shade700,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.indigo.shade900
                                    : Colors.grey[700],
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildRecibidos(), _buildRealizados()],
                  ),
                ),
              ],
            ),
    );
  }

  // ==========================================
  // PESTAÑA 1: PAGOS RECIBIDOS (Con Filtros)
  // ==========================================
  Widget _buildRecibidos() {
    final listaMostrar = _pagosFiltrados; // ✅ USAR LISTA FILTRADA

    if (listaMostrar.isEmpty) {
      return Center(
        child: Text(
          _filtroEstado == 'TODOS'
              ? 'No hay pagos pendientes'
              : 'No hay pagos ${_traducirEstado(_filtroEstado).toLowerCase()}',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: listaMostrar.length,
      itemBuilder: (context, index) {
        final p = listaMostrar[index];

        // Placeholder seguro ya que 'estado' no existe en tu modelo actual
        final esPendiente = true;

        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: esPendiente
                  ? Colors.orange.shade100
                  : Colors.green.shade100,
              child: Icon(
                esPendiente ? Icons.pending_actions : Icons.check_circle,
                color: esPendiente
                    ? Colors.orange.shade700
                    : Colors.green.shade700,
                size: 24,
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Alquiler Mensual',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Text(
                  '\$${p.monto.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Alquiler mensual',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                Text(
                  'Fecha: Pendiente',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
            trailing: esPendiente
                ? ElevatedButton.icon(
                    onPressed: _isProcessingPayment
                        ? null
                        : () => _iniciarPagoPayPal(p),
                    icon: const Icon(Icons.account_balance_wallet, size: 16),
                    label: const Text(
                      'Pagar con PayPal',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003087),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, color: Colors.green, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Pagado',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  // ==========================================
  // PESTAÑA 2: PAGOS REALIZADOS (Sin Filtros)
  // ==========================================
  Widget _buildRealizados() {
    if (_pagosRealizados.isEmpty) {
      return const Center(child: Text('No has realizado pagos aún'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pagosRealizados.length,
      itemBuilder: (context, index) {
        final p = _pagosRealizados[index];

        final esPendiente = true;

        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: esPendiente
                  ? Colors.red.shade100
                  : Colors.blue.shade100,
              child: Icon(
                esPendiente ? Icons.warning_amber : Icons.payment,
                color: esPendiente ? Colors.red.shade700 : Colors.blue.shade700,
                size: 24,
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Alquiler Mensual',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '-\$${p.monto.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Alquiler mensual',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                Text(
                  'Fecha: Pendiente',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: esPendiente ? Colors.orange : Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                esPendiente ? 'Pendiente' : 'Pagado',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  String _traducirEstado(String estado) {
    switch (estado.toUpperCase()) {
      case 'PAGADOS':
        return 'Pagados';
      case 'PENDIENTE':
        return 'Pendiente';
      default:
        return estado;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
