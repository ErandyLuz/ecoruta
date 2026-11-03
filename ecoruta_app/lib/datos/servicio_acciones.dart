import '../core/cifrado.dart';
import '../core/validadores.dart';
import 'modelos.dart';
import 'repositorios.dart';

/// Une validación, cifrado y nube: es la única puerta para registrar acciones.
class ServicioAcciones {
  ServicioAcciones(this._repo, this._cifrado);

  final RepositorioAcciones _repo;
  final ServicioCifrado _cifrado;

  Stream<List<AccionEco>> observar(String uid) => _repo.observar(uid);

  Stream<List<PuntoReciclaje>> puntosReciclaje() => _repo.puntosReciclaje();

  Future<void> eliminar(String uid, String id) => _repo.eliminar(uid, id);

  Future<void> registrar({
    required String uid,
    required TipoAccion tipo,
    required int cantidad,
    String nota = '',
    DateTime? fecha,
  }) async {
    if (cantidad < 1 || cantidad > Validadores.maxCantidad) {
      throw RangeError.range(cantidad, 1, Validadores.maxCantidad, 'cantidad');
    }
    final limpia = Validadores.limpiarTexto(nota);
    await _repo.agregar(
      uid,
      AccionEco(
        tipo: tipo,
        cantidad: cantidad,
        fecha: fecha ?? DateTime.now(),
        notaCifrada: limpia.isEmpty ? null : await _cifrado.cifrar(limpia),
      ),
    );
  }

  Future<String?> leerNota(AccionEco accion) async {
    final c = accion.notaCifrada;
    if (c == null) return null;
    try {
      return await _cifrado.descifrar(c);
    } catch (_) {
      // Nota de otro dispositivo o alterada: no se muestra.
      return null;
    }
  }

  static int totalPuntos(List<AccionEco> acciones) =>
      acciones.fold(0, (s, a) => s + a.puntos);
}
