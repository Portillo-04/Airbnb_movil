import 'package:flutter/material.dart';
import '../models/solicitud_model.dart';
// import '../services/solicitud_service.dart';

class OwnerSolicitudesScreen extends StatefulWidget {
  const OwnerSolicitudesScreen({super.key});

  @override
  State<OwnerSolicitudesScreen> createState() => _OwnerSolicitudesScreenState();
}

class _OwnerSolicitudesScreenState extends State<OwnerSolicitudesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<SolicitudAlquiler> _solicitudesRecibidas = [];
  List<SolicitudAlquiler> _solicitudesEnviadas = [];
  bool _isLoading = true;

  // ✅ ESTADO DEL FILTRO ACTIVO (Solo aplica a Recibidas)
  String _filtroEstado = 'TODAS';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Escuchar cambios de pestaña para actualizar UI si es necesario
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);

    // TODO: Conectar con backend
    // _solicitudesRecibidas = await _service.obtenerSolicitudesParaMisPropiedades();
    // _solicitudesEnviadas = await _service.obtenerMisSolicitudesDeAlquiler();

    _solicitudesRecibidas.sort(
      (a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''),
    );
    _solicitudesEnviadas.sort(
      (a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''),
    );

    if (mounted) setState(() => _isLoading = false);
  }

  // Acción para aceptar/rechazar solicitud recibida
  Future<void> _responderSolicitud(SolicitudAlquiler sol, String accion) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          accion == 'aceptar' ? '¿Aceptar Solicitud?' : '¿Rechazar Solicitud?',
        ),
        content: Text(
          'Estás a punto de ${accion} la solicitud de ${sol.inquilinoNombre ?? 'este usuario'}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: accion == 'aceptar' ? Colors.green : Colors.red,
            ),
            child: Text(
              accion.toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // TODO: await _service.actualizarEstado(sol.id, accion);
      setState(() => _solicitudesRecibidas.remove(sol));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Solicitud ${accion}da exitosamente'),
          backgroundColor: accion == 'aceptar' ? Colors.green : Colors.red,
        ),
      );
    }
  }

  // ✅ GETTER PARA FILTRADO DINÁMICO
  List<SolicitudAlquiler> get _solicitudesFiltradas {
    if (_filtroEstado == 'TODAS') return _solicitudesRecibidas;
    return _solicitudesRecibidas
        .where((s) => s.estado.toLowerCase() == _filtroEstado.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Solicitudes'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Me Solicitan', icon: Icon(Icons.inbox)),
            Tab(text: 'Yo Solicito', icon: Icon(Icons.send)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ✅ BARRA DE FILTROS: SOLO VISIBLE EN PESTAÑA 0 ("ME SOLICITAN")
                if (_tabController.index == 0)
                  Container(
                    color: Colors.grey[100],
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children:
                            ['TODAS', 'PENDIENTE', 'ACEPTADA', 'RECHAZADA'].map(
                              (estado) {
                                final isSelected = _filtroEstado == estado;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(
                                      estado == 'TODAS'
                                          ? 'Todas'
                                          : _capitalizar(estado),
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
                    children: [_buildRecibidas(), _buildEnviadas()],
                  ),
                ),
              ],
            ),
    );
  }

  // ==========================================
  // PESTAÑA 1: SOLICITUDES RECIBIDAS (Con Filtros)
  // ==========================================
  Widget _buildRecibidas() {
    final listaMostrar = _solicitudesFiltradas;

    if (listaMostrar.isEmpty) {
      return Center(
        child: Text(
          _filtroEstado == 'TODAS'
              ? 'No tienes nuevas solicitudes'
              : 'No hay solicitudes $_filtroEstado',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: listaMostrar.length,
      itemBuilder: (context, index) {
        final sol = listaMostrar[index];
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
                    CircleAvatar(child: Text((sol.inquilinoNombre ?? 'U')[0])),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sol.inquilinoNombre ?? 'Usuario Desconocido',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Solicitó el: ${_formatearFechaStr(sol.createdAt)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Propiedad ID: #${sol.propiedadId}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Fechas: ${sol.fechaInicio} - ${sol.fechaFin}',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _responderSolicitud(sol, 'rechazar'),
                      icon: const Icon(Icons.close, color: Colors.red),
                      label: const Text(
                        'Rechazar',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _responderSolicitud(sol, 'aceptar'),
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text(
                        'Aceptar',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // PESTAÑA 2: SOLICITUDES ENVIADAS (Sin Filtros)
  // ==========================================
  Widget _buildEnviadas() {
    if (_solicitudesEnviadas.isEmpty) {
      return const Center(child: Text('No has enviado solicitudes aún'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _solicitudesEnviadas.length,
      itemBuilder: (context, index) {
        final sol = _solicitudesEnviadas[index];

        Color badgeColor;
        String estadoTexto;

        switch (sol.estado.toLowerCase()) {
          case 'en_curso':
            badgeColor = Colors.orange;
            estadoTexto = 'En Curso';
            break;
          case 'aceptada':
            badgeColor = Colors.green;
            estadoTexto = 'Aceptada';
            break;
          case 'rechazada':
            badgeColor = Colors.red;
            estadoTexto = 'Rechazada';
            break;
          default:
            badgeColor = Colors.grey;
            estadoTexto = sol.estado;
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
              child: Icon(Icons.home, color: badgeColor),
            ),
            title: Text(
              'Propiedad #${sol.propiedadId}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Enviada el: ${_formatearFechaStr(sol.createdAt)}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                estadoTexto,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatearFechaStr(String? fechaStr) {
    if (fechaStr == null || fechaStr.isEmpty) return 'N/A';
    return fechaStr.split('T').first;
  }

  String _capitalizar(String texto) {
    if (texto.isEmpty) return texto;
    return '${texto[0].toUpperCase()}${texto.substring(1).toLowerCase()}';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
