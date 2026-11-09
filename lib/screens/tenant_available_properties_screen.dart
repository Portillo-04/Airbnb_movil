import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/propiedad_model.dart';
import '../services/propiedad_service.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';

class TenantAvailablePropertiesScreen extends StatefulWidget {
  const TenantAvailablePropertiesScreen({super.key});

  @override
  State<TenantAvailablePropertiesScreen> createState() =>
      _TenantAvailablePropertiesScreenState();
}

class _TenantAvailablePropertiesScreenState
    extends State<TenantAvailablePropertiesScreen> {
  final PropiedadService _service = PropiedadService();
  List<Propiedad> _allProperties = [];
  List<Propiedad> _filteredProperties = [];
  bool _isLoading = true;

  // Estado de filtros
  String _sortBy = 'none'; // none, low_to_high, high_to_low
  String? _selectedDept;
  String? _selectedDistrict;

  // ✅ LOS 14 DEPARTAMENTOS DE EL SALVADOR Y SUS MUNICIPIOS/DISTRITOS
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
    _cargarPropiedades();
  }

  Future<void> _cargarPropiedades() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.obtenerDisponibles();

      // ✅ EXCLUIR PROPIEDADES DEL USUARIO ACTUAL
      final currentUserId = context.read<AuthProvider>().usuario?.id;

      if (currentUserId != null) {
        _allProperties = data
            .where((p) => p.propietarioId != currentUserId)
            .toList();
      } else {
        _allProperties = data;
      }

      _applyFilters();

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ✅ FILTRADO EXACTO USANDO LOS NUEVOS CAMPOS DEL BACKEND
  void _applyFilters() {
    List<Propiedad> result = List.from(_allProperties);

    if (_selectedDept != null) {
      result = result.where((p) => p.departamento == _selectedDept).toList();
    }

    if (_selectedDistrict != null) {
      result = result.where((p) => p.distrito == _selectedDistrict).toList();
    }

    // Ordenar por Precio
    if (_sortBy == 'low_to_high') {
      result.sort((a, b) => a.precioMensual.compareTo(b.precioMensual));
    } else if (_sortBy == 'high_to_low') {
      result.sort((a, b) => b.precioMensual.compareTo(a.precioMensual));
    }

    setState(() => _filteredProperties = result);
  }

  void _solicitarAlquiler(Propiedad propiedad) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Solicitar Alquiler'),
        content: Text(
          '¿Deseas solicitar alquiler de:\n${propiedad.direccion}?',
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
                  content: Text('✅ Solicitud enviada'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viviendas Disponibles'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Colors.indigo.shade800,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                // 1. Filtro Departamento (Compacto y sin errores)
                Flexible(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _selectedDept,
                    hint: const Text(
                      'Depto',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    dropdownColor: Colors.indigo.shade900,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                    isDense: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 0,
                      ),
                      constraints: const BoxConstraints(minHeight: 32),
                    ),
                    items: _salvadorLocations.keys
                        .map<DropdownMenuItem<String>>(
                          (d) => DropdownMenuItem(
                            value: d,
                            child: Text(
                              d,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedDept = val;
                        _selectedDistrict = null;
                      });
                      _applyFilters();
                    },
                  ),
                ),

                const SizedBox(width: 2),

                // 2. Filtro Distrito (Compacto y sin errores)
                Flexible(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _selectedDistrict,
                    hint: const Text(
                      'Dist.',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    dropdownColor: Colors.indigo.shade900,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                    isDense: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 0,
                      ),
                      constraints: const BoxConstraints(minHeight: 32),
                    ),
                    items:
                        (_selectedDept != null
                                ? _salvadorLocations[_selectedDept]
                                : [])
                            ?.map<DropdownMenuItem<String>>(
                              (d) => DropdownMenuItem(
                                value: d,
                                child: Text(
                                  d,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                            )
                            .toList() ??
                        [],
                    onChanged: (val) {
                      setState(() => _selectedDistrict = val);
                      _applyFilters();
                    },
                  ),
                ),

                const SizedBox(width: 2),

                // 3. Botón Ordenar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: IconButton(
                    icon: Icon(
                      _sortBy == 'low_to_high'
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      size: 16,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _sortBy = _sortBy == 'low_to_high'
                            ? 'high_to_low'
                            : 'low_to_high';
                      });
                      _applyFilters();
                    },
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    padding: EdgeInsets.zero,
                    tooltip: 'Ordenar',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade50, Colors.white],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.indigo),
              )
            : _filteredProperties.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'No hay viviendas con estos filtros',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _cargarPropiedades,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredProperties.length,
                  itemBuilder: (context, index) {
                    final p = _filteredProperties[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: Image.network(
                              '${AppConstants.baseUrl}${p.imagenUrl}',
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 180,
                                color: Colors.indigo.shade100,
                                child: const Icon(Icons.home, size: 60),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.direccion,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                // ✅ Mostrar ubicación estructurada
                                Text(
                                  '${p.departamento}, ${p.distrito}',
                                  style: TextStyle(
                                    color: Colors.indigo.shade700,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '\$${p.precioMensual.toStringAsFixed(2)}/mes',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  p.descripcion,
                                  style: TextStyle(color: Colors.grey[600]),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _solicitarAlquiler(p),
                                    icon: const Icon(Icons.handshake),
                                    label: const Text('Solicitar Alquiler'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.indigo.shade700,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
