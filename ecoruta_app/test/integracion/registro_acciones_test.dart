// Prueba de integración: validación + cifrado + repositorio trabajando juntos.
import 'package:ecoruta/core/cifrado.dart';
import 'package:ecoruta/datos/modelos.dart';
import 'package:ecoruta/datos/servicio_acciones.dart';
import 'package:flutter_test/flutter_test.dart';

import '../falsos.dart';

void main() {
  late AccionesEnMemoria nube;
  late ServicioAcciones servicio;

  setUp(() {
    nube = AccionesEnMemoria();
    servicio = ServicioAcciones(nube, ServicioCifrado(AlmacenLlaveMemoria()));
  });

  test('la nota llega cifrada a la nube y se lee descifrada', () async {
    await servicio.registrar(
        uid: 'u1', tipo: TipoAccion.agua, cantidad: 20, nota: 'Cerré la llave');
    final guardado = nube.datos['u1']!.values.single;
    expect(guardado['notaCifrada'], isNot(contains('llave')));

    final acciones = await servicio.observar('u1').first;
    expect(await servicio.leerNota(acciones.single), 'Cerré la llave');
    expect(ServicioAcciones.totalPuntos(acciones), 20);
  });

  test('limpia la nota antes de cifrarla', () async {
    await servicio.registrar(
        uid: 'u1', tipo: TipoAccion.energia, cantidad: 1, nota: '<b>apagué</b>');
    final a = (await servicio.observar('u1').first).single;
    expect(await servicio.leerNota(a), 'bapagué/b');
  });

  test('nota vacía no se guarda', () async {
    await servicio.registrar(uid: 'u1', tipo: TipoAccion.energia, cantidad: 2);
    expect(nube.datos['u1']!.values.single.containsKey('notaCifrada'), isFalse);
  });

  test('rechaza cantidades fuera de rango sin tocar la nube', () async {
    await expectLater(
        servicio.registrar(
            uid: 'u1', tipo: TipoAccion.reciclaje, cantidad: 5000),
        throwsRangeError);
    expect(nube.datos, isEmpty);
  });

  test('cada usuario solo ve sus acciones', () async {
    await servicio.registrar(uid: 'u1', tipo: TipoAccion.reciclaje, cantidad: 1);
    expect(await servicio.observar('u2').first, isEmpty);
  });
}
