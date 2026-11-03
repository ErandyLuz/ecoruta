import 'dart:convert';

import 'package:http/http.dart' as http;

import 'modelos.dart';

/// API de terceros: Open-Meteo Air Quality (gratuita, sin llave, solo HTTPS).
class ApiCalidadAire {
  ApiCalidadAire([http.Client? cliente]) : _cliente = cliente ?? http.Client();

  final http.Client _cliente;
  static const _host = 'air-quality-api.open-meteo.com';

  Future<CalidadAire> consultar(double latitud, double longitud) async {
    if (latitud.abs() > 90 || longitud.abs() > 180) {
      throw ArgumentError('Coordenadas fuera de rango');
    }
    final uri = Uri.https(_host, '/v1/air-quality', {
      'latitude': latitud.toStringAsFixed(4),
      'longitude': longitud.toStringAsFixed(4),
      'current': 'european_aqi,pm2_5',
    });
    final r = await _cliente.get(uri).timeout(const Duration(seconds: 10));
    if (r.statusCode != 200) {
      throw http.ClientException('Servicio no disponible (${r.statusCode})');
    }
    final cuerpo = jsonDecode(r.body);
    if (cuerpo is! Map<String, dynamic> ||
        cuerpo['current'] is! Map<String, dynamic>) {
      throw const FormatException('Respuesta inesperada');
    }
    final actual = cuerpo['current'] as Map<String, dynamic>;
    return CalidadAire(
      indice: (actual['european_aqi'] as num? ?? 0).round(),
      pm25: (actual['pm2_5'] as num? ?? 0).toDouble(),
    );
  }
}
