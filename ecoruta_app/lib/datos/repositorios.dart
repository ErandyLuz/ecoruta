import 'modelos.dart';

/// Contratos de acceso a la nube. La app usa las versiones de Firebase
/// (repositorios_firebase.dart); las pruebas usan versiones falsas.
abstract class RepositorioAuth {
  /// Emite el uid del usuario con sesión, o null si no hay sesión.
  Stream<String?> cambiosDeSesion();
  Future<void> iniciarSesion(String correo, String contrasena);
  Future<void> registrar(String correo, String contrasena);
  Future<void> cerrarSesion();
}

abstract class RepositorioAcciones {
  Stream<List<AccionEco>> observar(String uid);
  Future<void> agregar(String uid, AccionEco accion);
  Future<void> eliminar(String uid, String idAccion);
  Stream<List<PuntoReciclaje>> puntosReciclaje();
}

/// Error mostrado al usuario. El mensaje es genérico a propósito: no revela
/// si un correo existe ni detalles internos del servidor.
class ErrorAuth implements Exception {
  const ErrorAuth(this.mensaje);
  final String mensaje;

  @override
  String toString() => mensaje;
}
