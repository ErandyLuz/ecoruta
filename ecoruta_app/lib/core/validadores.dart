/// Validación y limpieza de toda entrada del usuario antes de usarla o
/// enviarla a la nube (mitiga inyección y datos basura).
class Validadores {
  Validadores._();

  static final RegExp _correo =
      RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
  static final RegExp _controles = RegExp(r'[\x00-\x1F\x7F]');
  static final RegExp _etiquetas = RegExp(r'[<>]');

  static const int maxNota = 280;
  static const int maxCantidad = 1000;

  static String? correo(String? valor) {
    final v = (valor ?? '').trim();
    if (v.isEmpty) return 'Escribe tu correo';
    if (v.length > 254 || !_correo.hasMatch(v)) return 'Correo no válido';
    return null;
  }

  /// Contraseña robusta: 8+ caracteres, mayúscula, minúscula y número.
  static String? contrasena(String? valor) {
    final v = valor ?? '';
    if (v.length < 8) return 'Mínimo 8 caracteres';
    if (v.length > 128) return 'Máximo 128 caracteres';
    if (!v.contains(RegExp(r'[A-Z]'))) return 'Incluye una mayúscula';
    if (!v.contains(RegExp(r'[a-z]'))) return 'Incluye una minúscula';
    if (!v.contains(RegExp(r'[0-9]'))) return 'Incluye un número';
    return null;
  }

  static String? cantidad(String? valor) {
    final n = int.tryParse((valor ?? '').trim());
    if (n == null) return 'Escribe un número';
    if (n < 1 || n > maxCantidad) return 'Entre 1 y $maxCantidad';
    return null;
  }

  /// Quita caracteres de control y de etiquetas HTML y recorta el largo.
  static String limpiarTexto(String valor, {int max = maxNota}) {
    var v = valor.replaceAll(_controles, ' ').replaceAll(_etiquetas, '').trim();
    if (v.length > max) v = v.substring(0, max);
    return v;
  }
}
