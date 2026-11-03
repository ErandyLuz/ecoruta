enum TipoAccion {
  reciclaje('Separé o reciclé residuos', 'kg', 10),
  transporte('Usé bici, caminé o transporte público', 'km', 2),
  agua('Ahorré agua', 'litros', 1),
  energia('Ahorré energía', 'horas', 3),
  reforestacion('Planté un árbol', 'árboles', 50);

  const TipoAccion(this.descripcion, this.unidad, this.puntosPorUnidad);

  final String descripcion;
  final String unidad;
  final int puntosPorUnidad;

  static TipoAccion desdeNombre(String nombre) => TipoAccion.values.firstWhere(
        (t) => t.name == nombre,
        orElse: () => throw FormatException('Tipo de acción desconocido: $nombre'),
      );
}

class AccionEco {
  const AccionEco({
    this.id,
    required this.tipo,
    required this.cantidad,
    required this.fecha,
    this.notaCifrada,
  });

  final String? id;
  final TipoAccion tipo;
  final int cantidad;
  final DateTime fecha;

  /// Solo se guarda cifrada; ver [ServicioCifrado].
  final String? notaCifrada;

  int get puntos => tipo.puntosPorUnidad * cantidad;

  Map<String, Object?> aMapa() => {
        'tipo': tipo.name,
        'cantidad': cantidad,
        'fecha': fecha.millisecondsSinceEpoch,
        if (notaCifrada != null) 'notaCifrada': notaCifrada,
      };

  factory AccionEco.desdeMapa(String id, Map<String, Object?> m) => AccionEco(
        id: id,
        tipo: TipoAccion.desdeNombre(m['tipo'] as String),
        cantidad: (m['cantidad'] as num).toInt(),
        fecha: DateTime.fromMillisecondsSinceEpoch((m['fecha'] as num).toInt()),
        notaCifrada: m['notaCifrada'] as String?,
      );
}

class PuntoReciclaje {
  const PuntoReciclaje({
    required this.nombre,
    required this.direccion,
    required this.acepta,
  });

  final String nombre;
  final String direccion;
  final List<String> acepta;

  factory PuntoReciclaje.desdeMapa(Map<String, Object?> m) => PuntoReciclaje(
        nombre: m['nombre'] as String? ?? '',
        direccion: m['direccion'] as String? ?? '',
        acepta: (m['acepta'] as List<Object?>? ?? const [])
            .whereType<String>()
            .toList(),
      );
}

class CalidadAire {
  const CalidadAire({required this.indice, required this.pm25});

  /// Índice europeo de calidad del aire (0 = muy bueno).
  final int indice;
  final double pm25;

  String get nivel {
    if (indice <= 20) return 'Buena';
    if (indice <= 40) return 'Aceptable';
    if (indice <= 60) return 'Moderada';
    if (indice <= 80) return 'Mala';
    return 'Muy mala';
  }
}
