import 'dart:convert';

import 'package:ecoruta/datos/api_aire.dart';
import 'package:ecoruta/datos/modelos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('AccionEco calcula puntos y se convierte a mapa y de vuelta', () {
    final a = AccionEco(
        tipo: TipoAccion.reciclaje, cantidad: 3, fecha: DateTime(2026, 11, 3));
    expect(a.puntos, 30);
    final b = AccionEco.desdeMapa('x', a.aMapa());
    expect(b.tipo, TipoAccion.reciclaje);
    expect(b.cantidad, 3);
    expect(b.fecha, DateTime(2026, 11, 3));
    expect(a.aMapa().containsKey('notaCifrada'), isFalse);
  });

  test('tipo desconocido lanza FormatException', () {
    expect(() => TipoAccion.desdeNombre('hackeo'), throwsFormatException);
  });

  test('ApiCalidadAire usa HTTPS y lee la respuesta', () async {
    late Uri pedida;
    final api = ApiCalidadAire(MockClient((req) async {
      pedida = req.url;
      return http.Response(
          jsonEncode({
            'current': {'european_aqi': 45, 'pm2_5': 18.3}
          }),
          200);
    }));
    final r = await api.consultar(19.4326, -99.1332);
    expect(pedida.scheme, 'https');
    expect(r.indice, 45);
    expect(r.nivel, 'Moderada');
  });

  test('ApiCalidadAire falla con error del servidor o datos raros', () async {
    final caido = ApiCalidadAire(MockClient((_) async => http.Response('', 500)));
    await expectLater(
        caido.consultar(0, 0), throwsA(isA<http.ClientException>()));
    final raro = ApiCalidadAire(MockClient((_) async => http.Response('[]', 200)));
    await expectLater(raro.consultar(0, 0), throwsFormatException);
    await expectLater(raro.consultar(100, 0), throwsArgumentError);
  });
}
