import 'package:ecoruta/core/validadores.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('correo', () {
    test('acepta correos válidos', () {
      expect(Validadores.correo('ana.lopez@escuela.edu.mx'), isNull);
    });
    test('rechaza vacíos y mal formados', () {
      expect(Validadores.correo(''), isNotNull);
      expect(Validadores.correo('ana@'), isNotNull);
      expect(Validadores.correo('ana escuela.mx'), isNotNull);
    });
  });

  group('contrasena', () {
    test('exige 8 caracteres, mayúscula, minúscula y número', () {
      expect(Validadores.contrasena('Corta1'), isNotNull);
      expect(Validadores.contrasena('sinmayuscula1'), isNotNull);
      expect(Validadores.contrasena('SINMINUSCULA1'), isNotNull);
      expect(Validadores.contrasena('SinNumeros'), isNotNull);
      expect(Validadores.contrasena('EcoRuta2026'), isNull);
    });
  });

  group('cantidad', () {
    test('solo enteros entre 1 y 1000', () {
      expect(Validadores.cantidad('5'), isNull);
      expect(Validadores.cantidad('0'), isNotNull);
      expect(Validadores.cantidad('1001'), isNotNull);
      expect(Validadores.cantidad('abc'), isNotNull);
    });
  });

  group('limpiarTexto', () {
    test('quita etiquetas HTML y caracteres de control', () {
      expect(Validadores.limpiarTexto(' <script>hola</script>\n'),
          'scripthola/script');
    });
    test('recorta al largo máximo', () {
      expect(Validadores.limpiarTexto('a' * 500).length, Validadores.maxNota);
    });
  });
}
