# 2. Gestión del proceso de desarrollo: pruebas automatizadas y CI/CD

## 2.1 Herramientas elegidas

| Tipo de prueba | Herramienta | Qué cubre | Comando |
|---|---|---|---|
| Análisis estático | `flutter analyze` + `flutter_lints` con reglas estrictas (`analysis_options.yaml`) | Errores de tipos, código muerto, imports sin usar, uso de `BuildContext` tras `await`, flujos sin cerrar | `flutter analyze` |
| Formato | `dart format` | Estilo uniforme (informativo) | `dart format --set-exit-if-changed lib test` |
| Unitarias | `flutter_test` | Validadores, cifrado AES-GCM, modelos, API de calidad del aire con `MockClient` | `flutter test test/unitarias` |
| Widgets (UI) | `flutter_test` + `WidgetTester` | Pantalla de login: validación, llamada a la nube y mensajes de error | `flutter test test/widgets` |
| Integración | `flutter_test` con repositorio en memoria | Validación + limpieza + cifrado + almacenamiento trabajando juntos, aislamiento entre usuarios | `flutter test test/integracion` |
| Cobertura | `flutter test --coverage` | Genera `coverage/lcov.info` (se guarda como artefacto en CI) | |
| Seguridad | `gitleaks` | Busca llaves o contraseñas subidas por error | (en CI) |
| Dependencias | `flutter pub outdated` | Paquetes con versiones viejas o vulnerables | |
| Videojuego | Debugger de Construct + casos de prueba manuales + beta testers | Ver sección 2.4 | |

## 2.2 Pipeline (`.github/workflows/ci.yml`)

```
push / pull request ─► [calidad-app]  pub get → format → analyze → test + cobertura → outdated
                   └─► [secretos]     gitleaks
push a main ───────► [apk-beta]      (necesita calidad-app) → APK release ofuscado → artefacto
                   └─► [publicar-juego] export HTML5 de Construct → GitHub Pages
```

- Un PR **no se puede fusionar** si falla `calidad-app` (actívalo en *Settings → Branches → Branch protection rules → Require status checks*).
- Flujo de ramas: `feature/*` → PR a `develop` → PR a `main` (versión Beta).
- El APK y la cobertura se descargan desde la pestaña **Actions** del repositorio.

## 2.3 Proceso de desarrollo

1. Tarea en el tablero (GitHub Projects: *Por hacer / En curso / En revisión / Hecho*).
2. Rama `feature/nombre`, código + prueba.
3. `flutter analyze` y `flutter test` en local.
4. Pull request → CI → revisión de un compañero → merge.
5. En `main` se generan automáticamente el APK beta y el juego publicado.

## 2.4 Proceso de pruebas enfocado en el videojuego

| Fase | Qué se prueba | Cómo | Criterio de salida |
|---|---|---|---|
| 1. Pruebas de humo | El juego abre, el nivel carga, Brote se mueve | Preview (F5) tras cada cambio | Sin errores en consola |
| 2. Funcionales | Cada mecánica (tabla de casos en el reporte beta) | Debugger de Construct: revisar `Puntos`, `VidasRestantes`, `Restantes`, `llevando` | 100 % de los casos críticos aprobados |
| 3. Jugabilidad | Dificultad, claridad de los mensajes, duración | Jugar el nivel completo 3 veces cronometrando | Se termina en 2–4 min |
| 4. Compatibilidad | Navegadores y celular | Chrome, Firefox, Edge y un Android (export HTML5) | Corre a 60 FPS y los controles responden |
| 5. Beta cerrada | Jugadores externos (5 o más) | Formulario de la sección 3.3 | Sin errores críticos abiertos |
| 6. Regresión | Que lo corregido no rompa otra cosa | Repetir la fase 2 antes de cada export | Todos los casos en verde |

**Severidad de errores:** *Crítico* (no se puede terminar el nivel o se cierra) · *Mayor* (mecánica falla pero hay forma de seguir) · *Menor* (visual o de texto).
