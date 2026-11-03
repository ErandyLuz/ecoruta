# 1. Arquitectura y seguridad: EcoRuta & EcoGame

## 1.1 Componentes

```
┌──────────────────────┐      HTTPS / TLS       ┌─────────────────────────────┐
│  App móvil EcoRuta   │ ─────────────────────► │ Firebase Authentication     │
│  (Flutter)           │                        │ (correo + contraseña)       │
│                      │ ─────────────────────► │ Cloud Firestore             │
│  pantallas/          │   reglas de seguridad  │  usuarios/{uid}/acciones    │
│  datos/ (repos)      │                        │  puntos_reciclaje           │
│  core/ (cifrado,     │ ─────────────────────► │ Open-Meteo (API de terceros)│
│   validación)        │                        │  calidad del aire           │
│                      │ ── abre en navegador ─►│ EcoGame HTML5 (Construct)   │
└──────────────────────┘                        │  en GitHub Pages            │
          ▲                                     └─────────────────────────────┘
          │ push / PR
┌──────────────────────┐
│ GitHub Actions CI/CD │  analyze → test → gitleaks → APK beta → Pages
└──────────────────────┘
```

**Capas de la app** (`ecoruta_app/lib/`):

| Capa | Archivos | Responsabilidad |
|---|---|---|
| Presentación | `pantallas/*.dart`, `app.dart` | Login/registro, lista de acciones, nueva acción, calidad del aire, puntos de reciclaje |
| Servicio | `datos/servicio_acciones.dart` | Única puerta para registrar: valida, limpia y cifra antes de la nube |
| Datos | `datos/repositorios*.dart`, `datos/api_aire.dart` | Contratos (interfaces) e implementaciones Firebase / HTTP |
| Núcleo | `core/validadores.dart`, `core/cifrado.dart` | Validación de entradas y AES-256-GCM |

Las dependencias se **inyectan** (`Dependencias` en `app.dart`), así las pruebas usan repositorios falsos sin tocar la nube.

## 1.2 Codificación segura (OWASP Mobile Top 10)

| Riesgo | Medida aplicada | Dónde |
|---|---|---|
| M1 Uso indebido de credenciales | No hay llaves secretas en el código; la config de Firebase es pública por diseño y la protegen las reglas. `gitleaks` en CI busca secretos filtrados | `.gitleaks.toml`, `ci.yml` |
| M3 Autenticación insegura | Firebase Auth, contraseña robusta (8+, mayúscula, minúscula, número), verificación por correo, bloqueo por intentos (`too-many-requests`), mensajes genéricos que no revelan si un correo existe | `validadores.dart`, `repositorios_firebase.dart` |
| M4 Validación insuficiente de entradas | Validación en cliente **y** en servidor (reglas Firestore: campos permitidos, tipos y rangos). Limpieza de etiquetas HTML y caracteres de control | `validadores.dart`, `firestore.rules` |
| M5 Comunicación insegura | Solo HTTPS (`Uri.https`), la app solo abre URLs `https`, Android bloquea tráfico en claro por defecto (API 28+) | `api_aire.dart`, `pantalla_inicio.dart` |
| M6 Privacidad | Datos mínimos: correo y acciones. Sin permiso de ubicación (ciudades fijas). Las notas personales se cifran **en el dispositivo** | `pantalla_aire.dart`, `cifrado.dart` |
| M8 Autorización | Cada usuario solo lee/escribe `usuarios/{suUid}`; catálogo de solo lectura; todo lo demás cerrado | `firestore.rules` |
| M9 Almacenamiento inseguro | Llave AES guardada en **Android Keystore / iOS Keychain** (`flutter_secure_storage`), nunca en texto plano | `cifrado.dart` |
| M7 Ingeniería inversa | APK de release con `--obfuscate --split-debug-info` | `ci.yml` |

### Cifrado del intercambio de información

1. **En tránsito:** TLS (HTTPS) en todas las llamadas a Firebase y Open-Meteo.
2. **De extremo a extremo (notas):** `ServicioCifrado` cifra con **AES-256-GCM** (nonce aleatorio de 12 bytes y etiqueta de autenticación de 16 bytes). Firestore solo guarda `base64(nonce‖cifrado‖mac)`. Si alguien altera el dato, el descifrado falla (`SecretBoxAuthenticationError`) y la nota no se muestra.
3. **En reposo (servidor):** Firestore cifra sus discos por defecto.

## 1.3 Modelo de datos (Firestore)

```
usuarios/{uid}/acciones/{id}
    tipo:        "reciclaje" | "transporte" | "agua" | "energia" | "reforestacion"
    cantidad:    int (1–1000)
    fecha:       int (milisegundos)
    notaCifrada: string base64 (opcional, ≤ 1024)

puntos_reciclaje/{id}       (solo lectura, se llena desde la consola)
    nombre: string, direccion: string, acepta: [string]
```
