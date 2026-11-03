import 'package:flutter/material.dart';

import '../datos/api_aire.dart';
import '../datos/modelos.dart';

class PantallaAire extends StatefulWidget {
  const PantallaAire({super.key, required this.api});

  final ApiCalidadAire api;

  @override
  State<PantallaAire> createState() => _PantallaAireState();
}

class _PantallaAireState extends State<PantallaAire> {
  // Ciudades fijas: evita pedir el permiso de ubicación (menos datos personales).
  static const _ciudades = {
    'Ciudad de México': (19.4326, -99.1332),
    'Guadalajara': (20.6597, -103.3496),
    'Monterrey': (25.6866, -100.3161),
    'Puebla': (19.0414, -98.2063),
  };

  String _ciudad = _ciudades.keys.first;
  late Future<CalidadAire> _consulta = _consultar();

  Future<CalidadAire> _consultar() {
    final (lat, lon) = _ciudades[_ciudad]!;
    return widget.api.consultar(lat, lon);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<String>(
          value: _ciudad,
          decoration: const InputDecoration(labelText: 'Ciudad'),
          items: [
            for (final c in _ciudades.keys)
              DropdownMenuItem(value: c, child: Text(c)),
          ],
          onChanged: (c) => setState(() {
            _ciudad = c ?? _ciudad;
            _consulta = _consultar();
          }),
        ),
        const SizedBox(height: 24),
        FutureBuilder<CalidadAire>(
          future: _consulta,
          builder: (context, snap) {
            if (snap.hasError) {
              return const Text('No se pudo consultar la calidad del aire.');
            }
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final a = snap.data!;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text('Calidad del aire: ${a.nivel}',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('Índice: ${a.indice} · PM2.5: ${a.pm25.toStringAsFixed(1)} µg/m³'),
                    const SizedBox(height: 16),
                    Text(a.indice > 40
                        ? 'Hoy conviene caminar o usar transporte público para no aumentar la contaminación.'
                        : 'Buen día para moverte en bici o caminando.'),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        const Text('Datos: Open-Meteo (open-meteo.com)',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
