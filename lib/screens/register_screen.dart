import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/usuario_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  RolUsuario _rolSeleccionado = RolUsuario.visitante; // ✅ Rol por defecto
  bool _isLoading = false;

  // Regex exacto de tu API FastAPI
  final RegExp _phoneRegex = RegExp(r'^\d{4,5}-\d{4}$');

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final result = await context.read<AuthProvider>().register(
            _nombreCtrl.text,
            _emailCtrl.text,
            _telefonoCtrl.text,
            _passwordCtrl.text,
            _rolSeleccionado.toString().split('.').last, // ✅ Enviar el rol seleccionado
          );
      
      setState(() => _isLoading = false);

      if (result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registro exitoso. Ahora inicia sesión.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Información Personal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Nombre
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  hintText: 'Ej: Juan Pérez',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa tu nombre';
                  if (v.length < 3) return 'Mínimo 3 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Email
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  hintText: 'ejemplo@correo.com',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa tu email';
                  if (!v.contains('@')) return 'Email inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Teléfono
              TextFormField(
                controller: _telefonoCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  hintText: 'Ej: 2222-3333 o 22222-3333',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa tu teléfono';
                  if (!_phoneRegex.hasMatch(v)) {
                    return 'Formato inválido. Use 0000-0000 o 00000-0000';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Contraseña
              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  hintText: 'Mínimo 6 caracteres',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa una contraseña';
                  if (v.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // ✅ Selector de Rol
              const Text(
                'Tipo de Usuario',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Selecciona el rol que describe mejor tu situación:',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 12),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonFormField<RolUsuario>(
                  value: _rolSeleccionado,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Rol de usuario',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: RolUsuario.visitante,
                      child: Row(
                        children: [
                          Icon(Icons.visibility, color: Colors.grey),
                          SizedBox(width: 8),
                          Text('Visitante - Solo quiero ver propiedades'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: RolUsuario.inquilino,
                      child: Row(
                        children: [
                          Icon(Icons.home_work, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Inquilino - Ya alquilo o voy a alquilar'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: RolUsuario.propietario,
                      child: Row(
                        children: [
                          Icon(Icons.business, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Propietario - Tengo propiedades para alquilar'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (RolUsuario? nuevoRol) {
                    if (nuevoRol != null) {
                      setState(() {
                        _rolSeleccionado = nuevoRol;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),
              
              // Botón de registro
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _handleRegister,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        'Registrarme',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('¿Ya tienes cuenta? Inicia sesión aquí'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}