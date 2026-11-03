import 'package:cryptography/cryptography.dart';
import 'package:ecoruta/core/cifrado.dart';
import 'package:flutter_test/flutter_test.dart';

import '../falsos.dart';

void main() {
  test('cifra y descifra la misma nota', () async {
    final s = ServicioCifrado(AlmacenLlaveMemoria());
    final c = await s.cifrar('Llevé 3 kg de PET al centro de acopio');
    expect(c, isNot(contains('PET')));
    expect(await s.descifrar(c), 'Llevé 3 kg de PET al centro de acopio');
  });

  test('cada cifrado usa un nonce distinto', () async {
    final s = ServicioCifrado(AlmacenLlaveMemoria());
    expect(await s.cifrar('hola'), isNot(await s.cifrar('hola')));
  });

  test('guarda la llave y la reutiliza', () async {
    final almacen = AlmacenLlaveMemoria();
    final c = await ServicioCifrado(almacen).cifrar('secreto');
    expect(almacen.llave, hasLength(32));
    expect(await ServicioCifrado(almacen).descifrar(c), 'secreto');
  });

  test('detecta texto alterado', () async {
    final s = ServicioCifrado(AlmacenLlaveMemoria());
    final c = await s.cifrar('original');
    final alterado = '${c.substring(0, c.length - 4)}AAAA';
    await expectLater(s.descifrar(alterado),
        throwsA(isA<SecretBoxAuthenticationError>()));
  });
}
