# EcoRuta & EcoGame

Proyecto integral (10° IDGS): plataforma de concientización ambiental.

| Carpeta | Contenido | Materia |
|---|---|---|
| `ecoruta_app/` | App móvil Flutter + Firebase (auth, Firestore, cifrado AES-GCM, API Open-Meteo) y sus pruebas | Desarrollo Móvil Integral |
| `ecogame/` | Videojuego 2D en Construct 3: guía, sprites, sonidos y exportación HTML5 (`web/`) | Creación de Videojuegos |
| `.github/workflows/ci.yml` | CI/CD: análisis estático, pruebas, gitleaks, APK beta, GitHub Pages | Gestión del Proceso |
| `docs/` | Arquitectura y seguridad, proceso de pruebas, reporte beta, manual de usuario | Todas |

## Puesta en marcha de la app

Requisitos: [Flutter SDK](https://docs.flutter.dev/get-started/install/windows) (estable) y Android Studio.

```bash
cd ecoruta_app
flutter create --platforms android,ios --org mx.ecoruta .   # genera android/ e ios/ sin tocar lib/
flutter pub get
dart pub global activate flutterfire_cli
flutterfire configure                                        # reemplaza lib/firebase_options.dart
flutter analyze
flutter test
flutter run
```

En la consola de Firebase:
1. **Authentication → Sign-in method →** habilita *Correo electrónico/contraseña*.
2. **Firestore Database →** crea la base en modo producción y pega `ecoruta_app/firestore.rules` en la pestaña *Reglas* (o `firebase deploy --only firestore:rules`).
3. En la colección `puntos_reciclaje` agrega documentos con `nombre`, `direccion` y `acepta` (arreglo de textos).
4. En `android/app/build.gradle` deja `minSdk` en **23** o más (lo pide Firebase Auth).

## Videojuego

Sigue [`ecogame/GUIA_CONSTRUCT.md`](ecogame/GUIA_CONSTRUCT.md). Los recursos están en `ecogame/recursos/`.

## Entregables

- Código fuente: este repositorio.
- Versión Beta: APK (artefacto de Actions) + juego publicado en GitHub Pages.
- [Arquitectura y seguridad](docs/01_arquitectura_y_seguridad.md)
- [Proceso de pruebas y CI/CD](docs/02_proceso_de_pruebas_y_ci.md)
- [Reporte de beta testing](docs/03_reporte_beta_testing.md)
- [Manual de usuario](docs/04_manual_de_usuario.md)
