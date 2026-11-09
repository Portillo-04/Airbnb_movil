import 'package:flutter/material.dart';
import '../models/contrato_model.dart';
// import '../services/contrato_service.dart';

class OwnerContractsScreen extends StatefulWidget {
  const OwnerContractsScreen({super.key});

  @override
  State<OwnerContractsScreen> createState() => _OwnerContractsScreenState();
}

class _OwnerContractsScreenState extends State<OwnerContractsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Contrato> _misContratosComoPropietario = [];
  List<Contrato> _misContratosComoInquilino = [];
  bool _isLoading = true;

  // ✅ ESTADO DEL FILTRO ACTIVO (Solo aplica a Mis Propiedades)
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

    // TODO: Conectar con backend
    // _misContratosComoPropietario = await _service.obtenerContratosDeMisPropiedades();
    // _misContratosComoInquilino = await _service.obtenerContratosDondeSoyInquilino();

    _misContratosComoPropietario.sort(
      (a, b) => (b.fechaInicio ?? '').compareTo(a.fechaInicio ?? ''),
    );
    _misContratosComoInquilino.sort(
      (a, b) => (b.fechaInicio ?? '').compareTo(a.fechaInicio ?? ''),
    );

    if (mounted) setState(() => _isLoading = false);
  }

  // ✅ GETTER PARA FILTRADO DINÁMICO EN MIS PROPIEDADES
  List<Contrato> get _contratosFiltrados {
    if (_filtroEstado == 'TODOS') return _misContratosComoPropietario;
    return _misContratosComoPropietario
        .where((c) => c.estado.toLowerCase() == _filtroEstado.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Contratos'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Mis Propiedades', icon: Icon(Icons.home_work)),
            Tab(text: 'Otras Propiedades', icon: Icon(Icons.house_siding)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ✅ BARRA DE FILTROS: SOLO VISIBLE EN PESTAÑA 0 ("MIS PROPIEDADES")
                if (_tabController.index == 0)
                  Container(
                    color: Colors.grey[100],
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children:
                            ['TODOS', 'ACTIVOS', 'FINALIZADO', 'CANCELADO'].map(
                              (estado) {
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
                              },
                            ).toList(),
                      ),
                    ),
                  ),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildComoPropietario(), _buildComoInquilino()],
                  ),
                ),
              ],
            ),
    );
  }

  // ==========================================
  // PESTAÑA 1: CONTRATOS COMO PROPIETARIO (Con Filtros)
  // ==========================================
  Widget _buildComoPropietario() {
    final listaMostrar = _contratosFiltrados; // ✅ USAR LISTA FILTRADA

    if (listaMostrar.isEmpty) {
      return Center(
        child: Text(
          _filtroEstado == 'TODOS'
              ? 'No tienes contratos activos como propietario'
              : 'No hay contratos ${_traducirEstado(_filtroEstado).toLowerCase()}',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: listaMostrar.length,
      itemBuilder: (context, index) {
        final c = listaMostrar[index];

        // Placeholder seguro para evitar errores de modelo
        final infoInquilino = 'Inquilino Registrado';

        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Icon(
                Icons.home_work,
                color: Colors.blue.shade700,
                size: 24,
              ),
            ),
            title: Text(
              'Propiedad #${c.propiedadId}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Inquilino: $infoInquilino',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                Text(
                  'Vigencia: ${_formatearFecha(c.fechaInicio)} - ${_formatearFecha(c.fechaFin)}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
            trailing: _badgeEstado(c.estado),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  // ==========================================
  // PESTAÑA 2: CONTRATOS COMO INQUILINO (Sin Filtros)
  // ==========================================
  Widget _buildComoInquilino() {
    if (_misContratosComoInquilino.isEmpty) {
      return const Center(
        child: Text('No tienes contratos activos como inquilino'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _misContratosComoInquilino.length,
      itemBuilder: (context, index) {
        final c = _misContratosComoInquilino[index];

        // Placeholder seguro
        final infoPropietario = 'Propietario Registrado';

        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.teal.shade100,
              child: Icon(
                Icons.house_siding,
                color: Colors.teal.shade700,
                size: 24,
              ),
            ),
            title: Text(
              'Propiedad #${c.propiedadId}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Propietario: $infoPropietario',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                Text(
                  'Vigencia: ${_formatearFecha(c.fechaInicio)} - ${_formatearFecha(c.fechaFin)}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
            trailing: _badgeEstado(c.estado),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _badgeEstado(String estado) {
    Color color;
    switch (estado.toLowerCase()) {
      case 'activo':
        color = Colors.green;
        break;
      case 'finalizado':
        color = Colors.red;
        break;
      case 'cancelado':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _traducirEstado(estado),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _traducirEstado(String estado) {
    switch (estado.toUpperCase()) {
      case 'ACTIVOS':
        return 'Activos';
      case 'FINALIZADO':
        return 'Finalizado';
      case 'CANCELADO':
        return 'Cancelado';
      default:
        return estado;
    }
  }

  String _formatearFecha(String? fechaStr) {
    if (fechaStr == null || fechaStr.isEmpty) return 'N/A';
    return fechaStr.split('T').first;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
