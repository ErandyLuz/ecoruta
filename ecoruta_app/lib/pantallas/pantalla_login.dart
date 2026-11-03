import 'package:flutter/material.dart';

import '../core/validadores.dart';
import '../datos/repositorios.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key, required this.auth});

  final RepositorioAuth auth;

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final _form = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  bool _registro = false;
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      if (_registro) {
        await widget.auth.registrar(_correo.text, _contrasena.text);
      } else {
        await widget.auth.iniciarSesion(_correo.text, _contrasena.text);
      }
    } on ErrorAuth catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } catch (_) {
      if (mounted) setState(() => _error = 'Ocurrió un error. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.eco, size: 72, color: Color(0xFF2E7D32)),
                  const SizedBox(height: 8),
                  Text('EcoRuta',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 24),
                  TextFormField(
                    key: const Key('campoCorreo'),
                    controller: _correo,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(labelText: 'Correo'),
                    validator: Validadores.correo,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('campoContrasena'),
                    controller: _contrasena,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                    validator: _registro
                        ? Validadores.contrasena
                        : (v) => (v ?? '').isEmpty ? 'Escribe tu contraseña' : null,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!,
                        key: const Key('textoError'),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    key: const Key('botonEnviar'),
                    onPressed: _cargando ? null : _enviar,
                    child: Text(_registro ? 'Crear cuenta' : 'Entrar'),
                  ),
                  TextButton(
                    onPressed: _cargando
                        ? null
                        : () => setState(() {
                              _registro = !_registro;
                              _error = null;
                            }),
                    child: Text(_registro
                        ? 'Ya tengo cuenta'
                        : '¿No tienes cuenta? Regístrate'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
