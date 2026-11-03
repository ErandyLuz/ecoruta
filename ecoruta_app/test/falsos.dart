import 'dart:async';

import 'package:ecoruta/core/cifrado.dart';
import 'package:ecoruta/datos/modelos.dart';
import 'package:ecoruta/datos/repositorios.dart';

class AlmacenLlaveMemoria implements AlmacenLlave {
  List<int>? llave;

  @override
  Future<List<int>?> leer() async => llave;

  @override
  Future<void> guardar(List<int> l) async {
    llave = l;
  }
}

class AuthFalso implements RepositorioAuth {
  final _sesion = StreamController<String?>.broadcast();
  final llamadas = <String>[];
  ErrorAuth? fallarCon;

  @override
  Stream<String?> cambiosDeSesion() => _sesion.stream;

  @override
  Future<void> iniciarSesion(String correo, String contrasena) async {
    llamadas.add('login:$correo');
    if (fallarCon != null) throw fallarCon!;
    _sesion.add('uid-prueba');
  }

  @override
  Future<void> registrar(String correo, String contrasena) async {
    llamadas.add('registro:$correo');
    if (fallarCon != null) throw fallarCon!;
  }

  @override
  Future<void> cerrarSesion() async => _sesion.add(null);

  Future<void> cerrar() => _sesion.close();
}

/// Imita a Firestore guardando los mapas tal como se mandarían a la nube.
class AccionesEnMemoria implements RepositorioAcciones {
  final datos = <String, Map<String, Map<String, Object?>>>{};
  int _siguiente = 0;

  @override
  Future<void> agregar(String uid, AccionEco accion) async {
    datos.putIfAbsent(uid, () => {})['a${_siguiente++}'] = accion.aMapa();
  }

  @override
  Future<void> eliminar(String uid, String idAccion) async {
    datos[uid]?.remove(idAccion);
  }

  @override
  Stream<List<AccionEco>> observar(String uid) => Stream.value([
        for (final e in (datos[uid] ?? {}).entries)
          AccionEco.desdeMapa(e.key, e.value),
      ]);

  @override
  Stream<List<PuntoReciclaje>> puntosReciclaje() => Stream.value(const []);
}
