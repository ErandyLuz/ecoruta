// Ocupa el nombre que `flutter create` usa para su prueba de ejemplo,
// así no la genera (esa prueba busca un contador que esta app no tiene).
import 'package:ecoruta/datos/modelos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('todas las acciones dan puntos', () {
    for (final t in TipoAccion.values) {
      expect(t.puntosPorUnidad, greaterThan(0));
    }
  });
}
