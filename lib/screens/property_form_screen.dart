import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/propiedad_model.dart';
import '../services/propiedad_service.dart';
import 'property_form_screen.dart';

class PropertyFormScreen extends StatefulWidget {
  final Propiedad? propiedad; // Si es null, es crear; si tiene valor, es editar
  final File? imagenInicial; // Imagen seleccionada al crear
  final VoidCallback onSave; // Callback para recargar la lista

  const PropertyFormScreen({
    super.key,
    this.propiedad,
    this.imagenInicial,
    required this.onSave,
  });

  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _direccionCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();

  final PropiedadService _service = PropiedadService();
  final ImagePicker _picker = ImagePicker();

  String _estado = 'disponible';
  File? _imagenFile;
  String? _imagenUrl; // URL de la imagen ya subida (al editar)
  bool _isLoading = false;
  bool _isUploadingImage = false;

  bool get _esEditar => widget.propiedad != null;

  @override
  void initState() {
    super.initState();
    if (_esEditar) {
      _direccionCtrl.text = widget.propiedad!.direccion;
      _descripcionCtrl.text = widget.propiedad!.descripcion;
      _precioCtrl.text = widget.propiedad!.precioMensual.toString();
      _estado = widget.propiedad!.estado;
      if (widget.propiedad!.imagenUrl != null && widget.propiedad!.imagenUrl!.isNotEmpty) {
        _imagenUrl = widget.propiedad!.imagenUrl;
      }
    } else {
      _imagenFile = widget.imagenInicial;
    }
  }

  @override
  void dispose() {
    _direccionCtrl.dispose();
    _descripcionCtrl.dispose();
    _precioCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar imagen'),
        content: const Text('¿De dónde quieres seleccionar la imagen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text('Cámara'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text('Galería'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (source == null) return;

    final XFile? imagen = await _picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (imagen != null) {
      setState(() {
        _imagenFile = File(imagen.path);
        _imagenUrl = null; // Limpiar URL anterior si cambia la imagen
      });
    }
  }

  Future<String?> _subirImagenSiExiste() async {
    // Si hay una imagen nueva seleccionada, subirla
    if (_imagenFile != null) {
      setState(() => _isUploadingImage = true);
      
      final result = await _service.subirImagen(_imagenFile!);
      
      setState(() => _isUploadingImage = false);
      
      if (result['success']) {
        return result['imagen_url'] as String;
      } else {
        return null;
      }
    }
    
    // Si no hay imagen nueva, mantener la URL existente (al editar)
    return _imagenUrl;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Subir imagen si hay una nueva
      final imagenUrl = await _subirImagenSiExiste();
      
      if (_imagenFile != null && imagenUrl == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al subir la imagen'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      Map<String, dynamic> result;

      if (_esEditar) {
        // EDITAR
        result = await _service.actualizarPropiedad(
          id: widget.propiedad!.id,
          direccion: _direccionCtrl.text,
          descripcion: _descripcionCtrl.text,
          precioMensual: double.parse(_precioCtrl.text),
          estado: _estado,
          imagenUrl: imagenUrl,
        );
      } else {
        // CREAR
        result = await _service.crearPropiedad(
          direccion: _direccionCtrl.text,
          descripcion: _descripcionCtrl.text,
          precioMensual: double.parse(_precioCtrl.text),
          estado: _estado,
          imagenUrl: imagenUrl,
        );
      }

      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_esEditar ? 'Propiedad actualizada' : 'Propiedad creada'),
              backgroundColor: Colors.green,
            ),
          );
          widget.onSave();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEditar ? 'Editar Propiedad' : 'Nueva Propiedad'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade50, Colors.white],
          ),
        ),
        child: _isLoading || _isUploadingImage
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.indigo),
                    const SizedBox(height: 16),
                    Text(
                      _isUploadingImage ? 'Subiendo imagen...' : 'Guardando...',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sección de imagen
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Text(
                                'Imagen de la propiedad',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: _seleccionarImagen,
                                child: Container(
                                  height: 200,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.indigo.shade200, width: 2),
                                  ),
                                  child: _buildImagenPreview(),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: _seleccionarImagen,
                                icon: const Icon(Icons.photo_library, color: Colors.indigo),
                                label: const Text(
                                  'Seleccionar imagen',
                                  style: TextStyle(color: Colors.indigo),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Dirección
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Información de la propiedad',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _direccionCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Dirección',
                                  hintText: 'Ej: Calle Principal #123',
                                  prefixIcon: Icon(Icons.location_on),
                                ),
                                maxLines: 2,
                                validator: (v) => v == null || v.isEmpty ? 'Ingresa la dirección' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _descripcionCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Descripción',
                                  hintText: 'Describe la propiedad...',
                                  prefixIcon: Icon(Icons.description),
                                  alignLabelWithHint: true,
                                ),
                                maxLines: 4,
                                validator: (v) => v == null || v.isEmpty ? 'Ingresa una descripción' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _precioCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Precio mensual',
                                  hintText: 'Ej: 300.00',
                                  prefixIcon: Icon(Icons.attach_money),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Ingresa el precio';
                                  if (double.tryParse(v) == null) return 'Precio inválido';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _estado,
                                decoration: const InputDecoration(
                                  labelText: 'Estado',
                                  prefixIcon: Icon(Icons.info_outline),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'disponible', child: Text('Disponible')),
                                  DropdownMenuItem(value: 'alquilada', child: Text('Alquilada')),
                                  DropdownMenuItem(value: 'mantenimiento', child: Text('En mantenimiento')),
                                ],
                                onChanged: (value) {
                                  if (value != null) setState(() => _estado = value);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Botón guardar
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _guardar,
                          icon: Icon(_esEditar ? Icons.save : Icons.add),
                          label: Text(_esEditar ? 'Guardar cambios' : 'Crear propiedad', style: const TextStyle(fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildImagenPreview() {
    // Prioridad: imagen nueva seleccionada > imagen existente de la propiedad
    if (_imagenFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          _imagenFile!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    if (_imagenUrl != null && _imagenUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          'http://127.0.0.1:8000$_imagenUrl',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => _placeholderImagen(),
        ),
      );
    }

    return _placeholderImagen();
  }

  Widget _placeholderImagen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo, size: 48, color: Colors.indigo.shade300),
        const SizedBox(height: 8),
        Text(
          'Toca para agregar una imagen',
          style: TextStyle(color: Colors.grey[500], fontSize: 14),
        ),
      ],
    );
  }
}