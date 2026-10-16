import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/api_client.dart';

class RegisterPropertyScreen extends StatefulWidget {
  const RegisterPropertyScreen({super.key});

  @override
  State<RegisterPropertyScreen> createState() => _RegisterPropertyScreenState();
}

class _RegisterPropertyScreenState extends State<RegisterPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _direccionController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  String _estadoSeleccionado = 'DISPONIBLE';
  bool _isLoading = false;

  Future<void> _registrarPropiedad() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await apiClient.dio.post(
        '/propiedades',
        data: {
          'direccion': _direccionController.text,
          'descripcion': _descripcionController.text,
          'precio_mensual': double.parse(_precioController.text),
          'estado': _estadoSeleccionado,
        },
      );

      print('✅ Respuesta exitosa: ${response.data}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Propiedad registrada exitosamente'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } on DioException catch (e) {
      print('❌ Error: ${e.response?.data}');
      
      if (mounted) {
        String errorMessage = 'Error al registrar propiedad';
        
        if (e.response?.statusCode == 422) {
          final errors = e.response?.data['detail'];
          if (errors is List && errors.isNotEmpty) {
            errorMessage = 'Error de validación: ${errors[0]['msg']}';
          }
        } else if (e.response?.data['detail'] != null) {
          errorMessage = e.response?.data['detail'];
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.indigo),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Registrar Vivienda',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Formulario
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card de información
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.indigo.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.home_rounded,
                                        color: Colors.indigo.shade700,
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Información de la Propiedad',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Completa todos los campos',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                
                                // Dirección
                                TextFormField(
                                  controller: _direccionController,
                                  decoration: InputDecoration(
                                    labelText: 'Dirección',
                                    hintText: 'Ej: Calle Principal #123',
                                    prefixIcon: Icon(Icons.location_on, color: Colors.indigo.shade700),
                                  ),
                                  maxLines: 2,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ingresa la dirección';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                
                                // Descripción
                                TextFormField(
                                  controller: _descripcionController,
                                  decoration: InputDecoration(
                                    labelText: 'Descripción',
                                    hintText: 'Describe la propiedad...',
                                    prefixIcon: Icon(Icons.description, color: Colors.indigo.shade700),
                                  ),
                                  maxLines: 4,
                                  maxLength: 1000,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ingresa una descripción';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                
                                // Precio
                                TextFormField(
                                  controller: _precioController,
                                  decoration: InputDecoration(
                                    labelText: 'Precio Mensual',
                                    hintText: 'Ej: 500.00',
                                    prefixIcon: Icon(Icons.attach_money, color: Colors.indigo.shade700),
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ingresa el precio';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Precio inválido';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                
                                // Estado
                                DropdownButtonFormField<String>(
                                  value: _estadoSeleccionado,
                                  decoration: InputDecoration(
                                    labelText: 'Estado',
                                    prefixIcon: Icon(Icons.info_outline, color: Colors.indigo.shade700),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'DISPONIBLE', child: Text('Disponible')),
                                    DropdownMenuItem(value: 'ALQUILADA', child: Text('Alquilada')),
                                    DropdownMenuItem(value: 'MANTENIMIENTO', child: Text('En mantenimiento')),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _estadoSeleccionado = value);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Botón de registro
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: _isLoading
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: Colors.indigo.shade200,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: _registrarPropiedad,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo.shade700,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 4,
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_home_rounded, size: 24),
                                      SizedBox(width: 8),
                                      Text(
                                        'Registrar Propiedad',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}