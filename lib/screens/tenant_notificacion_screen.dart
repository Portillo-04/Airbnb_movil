import 'package:flutter/material.dart';
import '../models/notificacion_model.dart';
import '../services/notificacion_service.dart';

class TenantNotificationsScreen extends StatefulWidget {
  const TenantNotificationsScreen({super.key});

  @override
  State<TenantNotificationsScreen> createState() => _TenantNotificationsScreenState();
}

class _TenantNotificationsScreenState extends State<TenantNotificationsScreen> {
  final NotificacionService _service = NotificacionService();
  List<Notificacion> _notificaciones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarNotificaciones();
  }

  Future<void> _cargarNotificaciones() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.obtenerMisNotificaciones();
      setState(() => _notificaciones = data);
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

  IconData _iconoTipo(String tipo) {
    switch (tipo) {
      case 'APROBACION': return Icons.check_circle;
      case 'RECHAZO': return Icons.cancel;
      case 'POSPUESTA': return Icons.pause_circle;
      default: return Icons.notifications;
    }
  }

  Color _colorTipo(String tipo) {
    switch (tipo) {
      case 'APROBACION': return Colors.green;
      case 'RECHAZO': return Colors.red;
      case 'POSPUESTA': return Colors.orange;
      default: return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Notificaciones')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notificaciones.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('No tienes notificaciones', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notificaciones.length,
                  itemBuilder: (context, index) {
                    final n = _notificaciones[index];
                    return Card(
                      elevation: n.leida ? 2 : 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: _colorTipo(n.tipo).withOpacity(0.1),
                          child: Icon(_iconoTipo(n.tipo), color: _colorTipo(n.tipo)),
                        ),
                        title: Text(
                          n.titulo,
                          style: TextStyle(fontWeight: n.leida ? FontWeight.normal : FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(n.mensaje, style: TextStyle(color: Colors.grey[700])),
                        ),
                        trailing: n.leida ? null : Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle)),
                      ),
                    );
                  },
                ),
    );
  }
}