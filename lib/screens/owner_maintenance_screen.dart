import 'package:flutter/material.dart';
import '../models/mantenimiento_model.dart';
// import '../services/mantenimiento_service.dart';

class OwnerMaintenanceScreen extends StatefulWidget {
  const OwnerMaintenanceScreen({super.key});

  @override
  State<OwnerMaintenanceScreen> createState() => _OwnerMaintenanceScreenState();
}

class _OwnerMaintenanceScreenState extends State<OwnerMaintenanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Mantenimiento> _reportesRecibidos = [];
  List<Mantenimiento> _misReportes = [];
  bool _isLoading = true;

  // ✅ ESTADO DEL FILTRO ACTIVO (Solo aplica a Me Reportan)
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
    // _reportesRecibidos = await _service.obtenerReportesDeMisPropiedades();
    // _misReportes = await _service.obtenerMisReportesEnviados();

    _reportesRecibidos.sort(
      (a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''),
    );
    _misReportes.sort(
      (a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''),
    );

    if (mounted) setState(() => _isLoading = false);
  }

  // Acción para cambiar estado de reporte recibido
  Future<void> _actualizarEstado(Mantenimiento rep, String nuevoEstado) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Actualizar Estado'),
        content: Text('¿Marcar como "${_traducirEstado(nuevoEstado)}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade700,
            ),
            child: const Text(
              'Confirmar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // TODO: await _service.actualizarEstadoMantenimiento(rep.id, nuevoEstado);

      // Reemplazo seguro para modelos inmutables
      setState(() {
        final index = _reportesRecibidos.indexWhere((r) => r.id == rep.id);
        if (index != -1) {
          _reportesRecibidos[index] = Mantenimiento(
            id: rep.id,
            propiedadId: rep.propiedadId,
            inquilinoId: rep.inquilinoId,
            descripcion: rep.descripcion,
            estado: nuevoEstado,
            respuestaPropietario: rep.respuestaPropietario,
            inquilinoNombre: rep.inquilinoNombre,
            createdAt: rep.createdAt,
          );
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Estado actualizado a ${_traducirEstado(nuevoEstado)}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // ✅ GETTER PARA FILTRADO DINÁMICO
  List<Mantenimiento> get _reportesFiltrados {
    if (_filtroEstado == 'TODOS') return _reportesRecibidos;
    return _reportesRecibidos
        .where((r) => r.estado.toLowerCase() == _filtroEstado.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Mantenimiento'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Me Reportan', icon: Icon(Icons.report_problem)),
            Tab(text: 'Yo Reporto', icon: Icon(Icons.build_circle)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ✅ BARRA DE FILTROS: SOLO VISIBLE EN PESTAÑA 0 ("ME REPORTAN")
                if (_tabController.index == 0)
                  Container(
                    color: Colors.grey[100],
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children:
                            [
                              'TODOS',
                              'PENDIENTE',
                              'EN_PROCESO',
                              'RESUELTO',
                              'CANCELADO',
                            ].map((estado) {
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
                    children: [_buildRecibidos(), _buildEnviados()],
                  ),
                ),
              ],
            ),
    );
  }

  // ==========================================
  // PESTAÑA 1: REPORTES RECIBIDOS (Con Filtros)
  // ==========================================
  Widget _buildRecibidos() {
    final listaMostrar = _reportesFiltrados;

    if (listaMostrar.isEmpty) {
      return Center(
        child: Text(
          _filtroEstado == 'TODOS'
              ? 'No hay reportes pendientes'
              : 'No hay reportes ${_traducirEstado(_filtroEstado).toLowerCase()}',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: listaMostrar.length,
      itemBuilder: (context, index) {
        final rep = listaMostrar[index];
        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.red.shade100,
                      child: Icon(
                        Icons.warning,
                        color: Colors.red.shade700,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Propiedad #${rep.propiedadId}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Reportado por: ${rep.inquilinoNombre ?? 'Inquilino'}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Fecha: ${_formatearFechaStr(rep.createdAt)}',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _badgeEstado(rep.estado),
                  ],
                ),
                const SizedBox(height: 12),
                Text(rep.descripcion, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: rep.estado,
                  decoration: InputDecoration(
                    labelText: 'Cambiar Estado',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: ['PENDIENTE', 'EN_PROCESO', 'RESUELTO', 'CANCELADO']
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(_traducirEstado(e)),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) _actualizarEstado(rep, val);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // PESTAÑA 2: MIS REPORTES ENVIADOS (Sin Filtros)
  // ==========================================
  Widget _buildEnviados() {
    if (_misReportes.isEmpty) {
      return const Center(child: Text('No has enviado reportes aún'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _misReportes.length,
      itemBuilder: (context, index) {
        final rep = _misReportes[index];

        Color badgeColor;
        switch (rep.estado.toLowerCase()) {
          case 'pendiente':
            badgeColor = Colors.orange;
            break;
          case 'en_proceso':
            badgeColor = Colors.blue;
            break;
          case 'resuelto':
            badgeColor = Colors.green;
            break;
          case 'cancelado':
            badgeColor = Colors.red;
            break;
          default:
            badgeColor = Colors.grey;
        }

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: badgeColor.withOpacity(0.1),
              child: Icon(Icons.build, color: badgeColor),
            ),
            title: Text(
              'Propiedad #${rep.propiedadId}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${rep.descripcion.substring(0, rep.descripcion.length > 50 ? 50 : rep.descripcion.length)}...',
            ),
            trailing: _badgeEstado(rep.estado),
          ),
        );
      },
    );
  }

  Widget _badgeEstado(String estado) {
    Color color;
    switch (estado.toLowerCase()) {
      case 'pendiente':
        color = Colors.orange;
        break;
      case 'en_proceso':
        color = Colors.blue;
        break;
      case 'resuelto':
        color = Colors.green;
        break;
      case 'cancelado':
        color = Colors.red;
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
      case 'PENDIENTE':
        return 'Pendiente';
      case 'EN_PROCESO':
        return 'En Proceso';
      case 'RESUELTO':
        return 'Resuelto';
      case 'CANCELADO':
        return 'Cancelado';
      default:
        return estado;
    }
  }

  String _formatearFechaStr(String? fechaStr) {
    if (fechaStr == null || fechaStr.isEmpty) return 'N/A';
    return fechaStr.split('T').first;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
