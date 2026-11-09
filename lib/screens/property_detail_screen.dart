import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ✅ Import necesario para AuthProvider
import '../models/propiedad_model.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart'; // ✅ Import para verificar autenticación
import 'login_screen.dart'; // ✅ Import para navegar al login

class PropertyDetailScreen extends StatelessWidget {
  final Propiedad propiedad;

  const PropertyDetailScreen({super.key, required this.propiedad});

  void _handleSolicitud(BuildContext context) {
    final auth = context.read<AuthProvider>();

    // ✅ VERIFICACIÓN DE AUTENTICACIÓN
    if (auth.usuario == null) {
      // Si es visitante, mandar al Login
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      // Si ya está logueado, mostrar confirmación
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Solicitar Alquiler'),
          content: Text(
            '¿Deseas solicitar alquiler de esta propiedad en ${propiedad.distrito}, ${propiedad.departamento}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Solicitud enviada correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
                // TODO: Aquí iría la llamada real al backend para crear la solicitud
              },
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Propiedad'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ IMAGEN PRINCIPAL CON MANEJO DE ERRORES
            (propiedad.imagenUrl?.isNotEmpty ?? false)
                ? Image.network(
                    '${AppConstants.baseUrl}${propiedad.imagenUrl}',
                    width: double.infinity,
                    height: 280,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 280,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.home,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : Container(
                    height: 280,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.home, size: 80, color: Colors.grey),
                    ),
                  ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TÍTULO Y ESTADO
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          propiedad.direccion,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: propiedad.estado == 'DISPONIBLE'
                              ? Colors.green
                              : Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          propiedad.estado,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // PRECIO
                  Text(
                    '\$${propiedad.precioMensual.toStringAsFixed(2)}/mes',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // DESCRIPCIÓN
                  const Text(
                    'Descripción:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    propiedad.descripcion,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black54,
                    ),
                  ),

                  // ✅ UBICACIÓN EXACTA (DEPARTAMENTO Y DISTRITO)
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.indigo.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.indigo.shade700,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${propiedad.departamento}, ${propiedad.distrito}',
                            style: TextStyle(
                              color: Colors.indigo.shade900,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Espacio extra abajo para que el contenido no quede tapado por el botón flotante
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),

      // ✅ BOTÓN FLOTANTE CON LÓGICA DE LOGIN
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            _handleSolicitud(context), // ✅ LLAMA A LA FUNCIÓN DE VERIFICACIÓN
        backgroundColor: Colors.indigo.shade700,
        icon: const Icon(Icons.handshake, color: Colors.white),
        label: const Text(
          'Solicitar',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
