import 'package:flutter/material.dart';
import '../models/propiedad_model.dart';
import '../services/propiedad_service.dart';
import 'property_detail_screen.dart';

class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({super.key});

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  final PropiedadService _service = PropiedadService();
  List<Propiedad> _propiedades = [];
  List<Propiedad> _propiedadesFiltradas = [];
  bool _isLoading = true;
  
  String _busqueda = '';
  double? _precioMax;
  String _estadoFiltro = 'TODOS';

  @override
  void initState() {
    super.initState();
    _cargarPropiedades();
  }

  Future<void> _cargarPropiedades() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.obtenerDisponibles();
      setState(() {
        _propiedades = data;
        _aplicarFiltros();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _aplicarFiltros() {
    setState(() {
      _propiedadesFiltradas = _propiedades.where((prop) {
        final coincideBusqueda = _busqueda.isEmpty || 
            prop.direccion.toLowerCase().contains(_busqueda.toLowerCase()) ||
            prop.descripcion.toLowerCase().contains(_busqueda.toLowerCase());
        
        final coincidePrecio = _precioMax == null || prop.precioMensual <= _precioMax!;
        final coincideEstado = _estadoFiltro == 'TODOS' || prop.estado == _estadoFiltro;
        
        return coincideBusqueda && coincidePrecio && coincideEstado;
      }).toList();
    });
  }

  void _mostrarFiltros() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Filtros de Búsqueda',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              decoration: InputDecoration(
                labelText: 'Buscar por ubicación',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                _busqueda = value;
                _aplicarFiltros();
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _estadoFiltro,
              decoration: InputDecoration(
                labelText: 'Estado',
                prefixIcon: Icon(Icons.filter_list),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: const [
                DropdownMenuItem(value: 'TODOS', child: Text('Todos')),
                DropdownMenuItem(value: 'DISPONIBLE', child: Text('Disponible')),
                DropdownMenuItem(value: 'ALQUILADA', child: Text('Alquilada')),
              ],
              onChanged: (value) {
                if (value != null) {
                  _estadoFiltro = value;
                  _aplicarFiltros();
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Precio máximo: ', style: TextStyle(fontWeight: FontWeight.w500)),
                Expanded(
                  child: Slider(
                    value: _precioMax ?? 1000,
                    min: 0,
                    max: 2000,
                    divisions: 20,
                    label: '\$${(_precioMax ?? 1000).toStringAsFixed(0)}',
                    activeColor: Colors.indigo,
                    onChanged: (value) {
                      _precioMax = value;
                      _aplicarFiltros();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Aplicar filtros'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.indigo,
        ),
      );
    }

    return Column(
      children: [
        // Barra de búsqueda moderna
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar por ubicación...',
                      prefixIcon: const Icon(Icons.search, color: Colors.indigo),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      _busqueda = value;
                      _aplicarFiltros();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.indigo.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.indigo),
                  onPressed: _mostrarFiltros,
                ),
              ),
            ],
          ),
        ),

        // Lista de propiedades
        Expanded(
          child: _propiedadesFiltradas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home_outlined, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No se encontraron propiedades',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargarPropiedades,
                  color: Colors.indigo,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _propiedadesFiltradas.length,
                    itemBuilder: (context, index) {
                      final prop = _propiedadesFiltradas[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PropertyDetailScreen(propiedad: prop)),
                          ),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Imagen
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                    child: prop.imagenUrl?.isNotEmpty == true
                                      ? Image.network(
                                        prop.imagenUrl!,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            width: 80,
                                            height: 80,
                                            color: Colors.indigo.shade100,
                                            child: Icon(Icons.home, color: Colors.indigo.shade700),
                                          ),
                                        )
                                      : Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.indigo.shade100,
                                          child: Icon(Icons.home, color: Colors.indigo.shade700),
                                        ),
                                ),
                                const SizedBox(width: 16),
                                
                                // Información
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        prop.direccion,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        prop.descripcion,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.attach_money,
                                            size: 16,
                                            color: Colors.green.shade700,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '\$${prop.precioMensual.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: Colors.green.shade700,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: prop.estado == 'DISPONIBLE' 
                                                  ? Colors.green.shade100 
                                                  : Colors.orange.shade100,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              prop.estado,
                                              style: TextStyle(
                                                color: prop.estado == 'DISPONIBLE' 
                                                    ? Colors.green.shade700 
                                                    : Colors.orange.shade700,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}