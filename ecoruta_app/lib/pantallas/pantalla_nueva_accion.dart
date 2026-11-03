import 'package:flutter/material.dart';

import '../core/validadores.dart';
import '../datos/modelos.dart';
import '../datos/servicio_acciones.dart';

class PantallaNuevaAccion extends StatefulWidget {
  const PantallaNuevaAccion(
      {super.key, required this.uid, required this.servicio});

  final String uid;
  final ServicioAcciones servicio;

  @override
  State<PantallaNuevaAccion> createState() => _PantallaNuevaAccionState();
}

class _PantallaNuevaAccionState extends State<PantallaNuevaAccion> {
  final _form = GlobalKey<FormState>();
  final _cantidad = TextEditingController(text: '1');
  final _nota = TextEditingController();
  TipoAccion _tipo = TipoAccion.reciclaje;
  bool _guardando = false;

  @override
  void dispose() {
    _cantidad.dispose();
    _nota.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      await widget.servicio.registrar(
        uid: widget.uid,
        tipo: _tipo,
        cantidad: int.parse(_cantidad.text.trim()),
        nota: _nota.text,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo guardar. Revisa tu conexión.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva acción ecológica')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<TipoAccion>(
              value: _tipo,
              decoration: const InputDecoration(labelText: '¿Qué hiciste?'),
              items: [
                for (final t in TipoAccion.values)
                  DropdownMenuItem(value: t, child: Text(t.descripcion)),
              ],
              onChanged: (t) => setState(() => _tipo = t ?? _tipo),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cantidad,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Cantidad (${_tipo.unidad})'),
              validator: Validadores.cantidad,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nota,
              maxLength: Validadores.maxNota,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Nota personal (se guarda cifrada)',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.save),
              label: Text('Guardar (+${_tipo.puntosPorUnidad * (int.tryParse(_cantidad.text) ?? 0)} pts)'),
              onPressed: _guardando ? null : _guardar,
            ),
          ],
        ),
      ),
    );
  }
}
