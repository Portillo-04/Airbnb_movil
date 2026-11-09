import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/propiedad_service.dart';
import '../models/propiedad_model.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';

class PropertyFormScreen extends StatefulWidget {
  final Propiedad? propiedad; // Null = Crear Nueva | Objeto = Editar Existente
  final VoidCallback onSave;

  const PropertyFormScreen({super.key, this.propiedad, required this.onSave});

  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _direccionCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();

  String? _selectedDept;
  String? _selectedDistrict;
  String _estado = 'DISPONIBLE';
  File? _imagenFile;
  bool _isLoading = false;

  final PropiedadService _service = PropiedadService();
  final ImagePicker _picker = ImagePicker();

  // ✅ LOS 14 DEPARTAMENTOS Y SUS DISTRITOS
  final Map<String, List<String>> _salvadorLocations = {
    'Ahuachapán': [
      'Ahuachapán',
      'Atiquizaya',
      'Concepción de Ataco',
      'El Refugio',
      'Guaymango',
      'Jujutla',
      'San Francisco Menéndez',
      'San Lorenzo',
      'San Pedro Puxtla',
      'Tacuba',
      'Turín',
    ],
    'Cabañas': [
      'Sensuntepeque',
      'Cinquera',
      'Dolores',
      'Guacotecti',
      'Ilobasco',
      'Jutiapa',
      'San Isidro',
      'Tejutepeque',
      'Victoria',
    ],
    'Chalatenango': [
      'Chalatenango',
      'Agua Caliente',
      'Arcatao',
      'Azacualpa',
      'Citalá',
      'Comalapa',
      'Concepción Quezaltepeque',
      'Dulce Nombre de María',
      'El Carrizal',
      'El Paraíso',
      'La Laguna',
      'La Palma',
      'La Reina',
      'Las Vueltas',
      'Nombre de Jesús',
      'Nueva Concepción',
      'Nueva Trinidad',
      'Ojos de Agua',
      'Potonico',
      'San Antonio de la Cruz',
      'San Antonio Los Ranchos',
      'San Fernando',
      'San Francisco Lempa',
      'San Francisco Morazán',
      'San Ignacio',
      'San Isidro Labrador',
      'San José Cancasque',
      'San José Las Flores',
      'San Luis del Carmen',
      'San Miguel de Mercedes',
      'San Rafael',
      'Santa Rita',
      'Tejutla',
    ],
    'Cuscatlán': [
      'Cojutepeque',
      'Candelaria',
      'El Carmen',
      'El Rosario',
      'Monte San Juan',
      'Oratorio de Concepción',
      'San Bartolomé Perulapía',
      'San Cristóbal',
      'San José Guayabal',
      'San Pedro Perulapán',
      'San Rafael Cedros',
      'San Ramón',
      'Santa Cruz Analquito',
      'Santa Cruz Michapa',
      'Suchitoto',
      'Tenancingo',
    ],
    'La Libertad': [
      'Santa Tecla',
      'Antiguo Cuscatlán',
      'Chiltiupán',
      'Ciudad Arce',
      'Colón',
      'Comasagua',
      'Huizúcar',
      'Jayaque',
      'Jicalapa',
      'La Libertad',
      'Nuevo Cuscatlán',
      'Opico',
      'Quezaltepeque',
      'Sacacoyo',
      'San Juan Opico',
      'San Matías',
      'San Pablo Tacachico',
      'Talnique',
      'Tamanique',
      'Teotepeque',
      'Tepecoyo',
      'Zaragoza',
    ],
    'La Paz': [
      'Zacatecoluca',
      'Cuyultitán',
      'El Rosario',
      'Jerusalén',
      'Mercedes La Ceiba',
      'Olocuilta',
      'Paraíso de Osorio',
      'San Antonio Masahuat',
      'San Emigdio',
      'San Francisco Chinameca',
      'San Juan Nonualco',
      'Juan Talpa',
      'Juan Tepezontes',
      'Luis La Herradura',
      'Luis Talpa',
      'Miguel Tepezontes',
      'Pedro Masahuat',
      'Pedro Nonualco',
      'Rafael Obrajuelo',
      'María Ostuma',
      'Santiago Nonualco',
      'Tapalhuaca',
    ],
    'La Unión': [
      'La Unión',
      'Bolívar',
      'Conchagua',
      'El Carmen',
      'Intipucá',
      'Lislique',
      'Meanguera',
      'Nueva Esparta',
      'Pasaquina',
      'Polorós',
      'San Alejo',
      'Santa Rosa de Lima',
      'Yayantique',
      'Yucuaiquín',
    ],
    'Morazán': [
      'San Francisco Gotera',
      'Arambala',
      'Cacaopera',
      'Chilanga',
      'Corinto',
      'Delicias de Concepción',
      'Divisadero',
      'Rosario',
      'Gualococti',
      'Guatajiagua',
      'Joateca',
      'Jocoaitique',
      'Jocoro',
      'Lolotiquillo',
      'Meanguera',
      'Osicala',
      'Perquín',
      'San Carlos',
      'San Fernando',
      'San Isidro',
      'San Simón',
      'Sensembra',
      'Sociedad',
      'Torola',
      'Yamabal',
      'Yoloaiquín',
    ],
    'San Miguel': [
      'San Miguel',
      'Carolina',
      'Chapeltique',
      'Chinameca',
      'Chirilagua',
      'Ciudad Barrios',
      'Comacarán',
      'Tránsito',
      'Lolotique',
      'Moncagua',
      'Nueva Guadalupe',
      'Nuevo Edén de San Juan',
      'Quelepa',
      'Antonio del Monte',
      'Gerardo',
      'Jorge',
      'Luis de la Reina',
      'Rafael Oriente',
      'Sesori',
      'Uluazapa',
    ],
    'San Salvador': [
      'San Salvador',
      'Aguilares',
      'Apopa',
      'Ayutuxtepeque',
      'Cuscatancingo',
      'Delgado',
      'Paisnal',
      'Guazapa',
      'Ilopango',
      'Mejicanos',
      'Nejapa',
      'Panchimalco',
      'Rosario de Mora',
      'Marcos',
      'Martín',
      'Texacuangos',
      'Tomás',
      'Soyapango',
      'Tonacatepeque',
    ],
    'San Vicente': [
      'San Vicente',
      'Apastepeque',
      'Guadalupe',
      'Cayetano Istepeque',
      'Esteban Catarina',
      'Ildefonso',
      'Lorenzo',
      'Sebastián',
      'Clara',
      'Domingo',
      'Tecoluca',
      'Tepetitán',
      'Verapaz',
    ],
    'Santa Ana': [
      'Santa Ana',
      'Coatepeque',
      'Chalchuapa',
      'Congo',
      'Porvenir',
      'Masahuat',
      'Metapán',
      'Antonio Pajonal',
      'Sebastián Salitrillo',
      'Rosa Guachipilín',
      'Frontera',
      'Texistepeque',
    ],
    'Sonsonate': [
      'Sonsonate',
      'Acajutla',
      'Armenia',
      'Caluco',
      'Cuisnahuat',
      'Izalco',
      'Juayúa',
      'Nahuizalco',
      'Nahulingo',
      'Salcoatitán',
      'Antonio del Monte',
      'Julián',
      'Catarina Masahuat',
      'Isabel Ishuatán',
      'Domingo de Guzmán',
      'Sonzacate',
    ],
    'Usulután': [
      'Usulután',
      'Alegría',
      'Berlín',
      'California',
      'Concepción Batres',
      'Triunfo',
      'Ereguayquín',
      'Estanzuelas',
      'Jiquilisco',
      'Jucuapa',
      'Jucuarán',
      'Umaña',
      'Granada',
      'Ozatlán',
      'Puerto El Triunfo',
      'Agustín',
      'Buenaventura',
      'Dionisio',
      'Francisco Javier',
      'Elena',
      'María',
      'De María',
      'Tecapán',
      'Vari',
    ],
  };

  @override
  void initState() {
    super.initState();
    if (widget.propiedad != null) {
      _direccionCtrl.text = widget.propiedad!.direccion;
      _descripcionCtrl.text = widget.propiedad!.descripcion;
      _precioCtrl.text = widget.propiedad!.precioMensual.toString();
      _estado = widget.propiedad!.estado;

      // ✅ AHORA FUNCIONA GRACIAS A LA ACTUALIZACIÓN DEL MODELO
      _selectedDept = widget.propiedad!.departamento;
      _selectedDistrict = widget.propiedad!.distrito;
    }
  }

  @override
  void dispose() {
    _direccionCtrl.dispose();
    _descripcionCtrl.dispose();
    _precioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imagenFile = File(picked.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDept == null || _selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Selecciona departamento y distrito'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = context.read<AuthProvider>().usuario?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      Map<String, dynamic> result;

      if (widget.propiedad == null) {
        // CREAR NUEVA PROPIEDAD CON CAMPOS OBLIGATORIOS
        result = await _service.crearPropiedad(
          direccion: _direccionCtrl.text.trim(),
          descripcion: _descripcionCtrl.text.trim(),
          precioMensual: double.parse(_precioCtrl.text),
          estado: _estado,
          propietarioId: userId,
          departamento: _selectedDept!,
          distrito: _selectedDistrict!,
          file: _imagenFile,
        );
      } else {
        // ACTUALIZAR PROPIEDAD EXISTENTE
        result = await _service.actualizarPropiedad(
          id: widget.propiedad!.id!,
          direccion: _direccionCtrl.text.trim(),
          descripcion: _descripcionCtrl.text.trim(),
          precioMensual: double.parse(_precioCtrl.text),
          estado: _estado,
          departamento: _selectedDept!,
          distrito: _selectedDistrict!,
          file: _imagenFile,
        );
      }

      if (!mounted) return;

      if (result['success']) {
        Navigator.pop(context);
        widget.onSave();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.propiedad == null
                  ? '✅ Propiedad creada'
                  : '✅ Propiedad actualizada',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Error desconocido'),
            backgroundColor: Colors.red,
          ),
        );
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
    final isEditing = widget.propiedad != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Propiedad' : 'Nueva Propiedad'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Selector de Imagen
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    image: _imagenFile != null
                        ? DecorationImage(
                            image: FileImage(_imagenFile!),
                            fit: BoxFit.cover,
                          )
                        : (widget.propiedad?.imagenUrl != null &&
                                  widget.propiedad!.imagenUrl!.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(
                                    '${AppConstants.baseUrl}${widget.propiedad!.imagenUrl}',
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null),
                  ),
                  child:
                      _imagenFile == null &&
                          (widget.propiedad?.imagenUrl == null ||
                              widget.propiedad!.imagenUrl!.isEmpty)
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Toca para agregar foto',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 24),

              // Dirección Exacta
              TextFormField(
                controller: _direccionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Dirección Exacta',
                  hintText: 'Ej: Calle Principal #123',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingresa la dirección' : null,
              ),
              const SizedBox(height: 16),

              // DROPDOWN DEPARTAMENTO
              DropdownButtonFormField<String>(
                value: _selectedDept,
                hint: const Text('Selecciona Departamento'),
                decoration: const InputDecoration(
                  labelText: 'Departamento',
                  border: OutlineInputBorder(),
                ),
                items: _salvadorLocations.keys
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedDept = val;
                    _selectedDistrict = null;
                  });
                },
                validator: (v) =>
                    v == null ? 'Selecciona un departamento' : null,
              ),
              const SizedBox(height: 16),

              // ✅ DROPDOWN DISTRITO CON CORRECCIÓN DE TIPADO
              DropdownButtonFormField<String>(
                value: _selectedDistrict,
                hint: const Text('Selecciona Distrito/Municipio'),
                decoration: const InputDecoration(
                  labelText: 'Distrito / Municipio',
                  border: OutlineInputBorder(),
                ),
                // ✅ SOLUCIÓN AL ERROR: <DropdownMenuItem<String>> explícito
                items:
                    (_selectedDept != null
                            ? _salvadorLocations[_selectedDept]
                            : [])
                        ?.map<DropdownMenuItem<String>>(
                          (d) => DropdownMenuItem(value: d, child: Text(d)),
                        )
                        .toList() ??
                    [],
                onChanged: (val) => setState(() => _selectedDistrict = val),
                validator: (v) => v == null ? 'Selecciona un distrito' : null,
              ),
              const SizedBox(height: 16),

              // Precio Mensual
              TextFormField(
                controller: _precioCtrl,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Precio Mensual (\$)',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa el precio';
                  if (double.tryParse(v) == null)
                    return 'Ingresa un número válido';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Descripción
              TextFormField(
                controller: _descripcionCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Detalles de la propiedad, amenidades, etc.',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingresa una descripción' : null,
              ),
              const SizedBox(height: 16),

              // Estado de la Propiedad
              DropdownButtonFormField<String>(
                value: _estado,
                decoration: const InputDecoration(
                  labelText: 'Estado Actual',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'DISPONIBLE',
                    child: Text('Disponible'),
                  ),
                  DropdownMenuItem(
                    value: 'ALQUILADA',
                    child: Text('Alquilada'),
                  ),
                  DropdownMenuItem(
                    value: 'MANTENIMIENTO',
                    child: Text('En Mantenimiento'),
                  ),
                ],
                onChanged: (val) => setState(() => _estado = val!),
              ),
              const SizedBox(height: 32),

              // Botón Guardar
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isEditing
                            ? 'Actualizar Propiedad'
                            : 'Guardar Propiedad',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
