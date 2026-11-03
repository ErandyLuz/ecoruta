# EcoGame: «Brote y el Parque Limpio». Guía para armarlo en Construct 3

**Concepto:** el parque de la ciudad está lleno de basura y una nube de smog lo recorre. **Brote**, un niño-semilla, debe **recoger cada residuo y llevarlo al contenedor correcto** (orgánico, reciclable o no reciclable). Cada acierto suma puntos y muestra un dato ecológico. Cada error o golpe del smog quita una vida. El nivel se gana al limpiar todo el parque y llegar a la bandera antes de que se acabe el tiempo.

> Esta guía cabe en la **edición gratuita** de Construct 3: usa **2 capas** por layout y unos **30 eventos**. Los límites reportados para la versión gratuita son de unos 50 eventos y 2 capas; revisa los actuales en construct.net.

---

## 0. Recursos (ya generados)

Todos están en `ecogame/recursos/`. Si los quieres regenerar: `python herramientas/generar_recursos.py`.

| Archivo | Uso |
|---|---|
| `sprites/brote_reposo1-2, brote_correr1-4, brote_salto.png` | Jugador (32×48) |
| `sprites/residuo_*.png` (7) | Botella, lata, papel, plátano, manzana, vaso de unicel, frituras (32×32) |
| `sprites/contenedor_organico / reciclable / no_reciclable.png` | Contenedores (48×56) |
| `sprites/tile_pasto, tile_tierra, tile_madera.png` | Suelo y plataformas (32×32) |
| `sprites/fondo_parque.png` | Fondo (640×360) |
| `sprites/smog_1-2.png` | Enemigo (44×32) |
| `sprites/corazon_lleno.png` | Vidas en el HUD (27×24) |
| `sprites/meta_bandera.png`, `destello.png` | Meta y efecto de acierto |
| `sonidos/*.wav` | salto, recoger, correcto, incorrecto, daño, victoria, música en bucle |

---

## 1. Crear el proyecto

1. Abre <https://editor.construct.net> → **New project**.
2. Name: `EcoGame`. Viewport size: **640 × 360**. Preset: *Landscape*.
3. En **Project Properties**: *Sampling* = **Nearest** y *Pixel rounding* = **On** (pixel-art nítido). *Fullscreen mode* = **Letterbox scale** (se adapta al celular).
4. Renombra `Layout 1` → **Nivel1** y `Event sheet 1` → **EventosNivel1**.
5. Propiedades de **Nivel1**: *Size* = **2560 × 360**.
6. Capas (panel *Layers*):
   - `Juego` (la que ya existe).
   - Agrega `HUD` encima, con **Parallax 0, 0** (no se mueve con la cámara).
7. Clic derecho en el panel *Project* → *Sounds*/*Music* → **Import**: los sonidos a *Sounds* y `musica_parque.wav` a *Music*.
8. Inserta los objetos de sistema: **Keyboard**, **Audio** y **Touch** (si harás controles táctiles, sección 7).

## 2. Objetos (doble clic en el layout → Insert new object)

| Objeto (nombre exacto) | Tipo | Capa | Configuración |
|---|---|---|---|
| **Fondo** | Sprite (`fondo_parque.png`) | Juego (al fondo, *Send to back*) | Origen arriba-izquierda; posición 0,0 |
| **Suelo** | Tiled Background (`tile_pasto`) | Juego | Behavior **Solid**. Alto 32, en Y=328 |
| **Plataforma** | Tiled Background (`tile_madera`) | Juego | Behavior **Jump-thru**. Alto 16 |
| **Brote** | Sprite | Juego | Behaviors: **Platform**, **Scroll To**, **Bound to layout**, **Flash**. Variables de instancia: `llevando` (texto, vacío) |
| **Residuo** | Sprite | Juego | Behaviors: **Sine** (*Movement*: Vertical, *Magnitude* 4, *Period* 1.5) y **Pin**. Variables: `tipo` (texto), `dato` (texto), `cargado` (booleano), `inicioX`, `inicioY` (número) |
| **Contenedor** | Sprite | Juego | Variable: `tipo` (texto) |
| **Smog** | Sprite (2 frames) | Juego | Dos behaviors **Sine**: Horizontal (Magnitude 120, Period 4) y Vertical (Magnitude 20, Period 2) |
| **Meta** | Sprite (`meta_bandera`) | Juego | Ninguno |
| **Destello** | Sprite (`destello`) | Juego | Behavior **Fade** (Fade out 0.6 s, *Destroy* = yes). Ponlo fuera del layout |
| **TextoHUD** | Text | HUD | Arriba-izquierda (8, 8), tamaño 14, blanco con sombra |
| **TextoMensaje** | Text | HUD | Centrado (320, 300), 640 de ancho, tamaño 16, alineado al centro |
| **Vidas** | Tiled Background (`corazon_lleno`) | HUD | En (560, 8), alto 24, ancho 81 (3 corazones) |

### Animaciones

- **Brote**: `Reposo` (reposo1-2, velocidad 3, loop), `Correr` (correr1-4, velocidad 10, loop), `Salto` (salto). Origen abajo-centro. Collision polygon: ajústalo al cuerpo (sin el retoño).
- **Residuo**: una animación por residuo, con el **mismo nombre** que el archivo: `botella`, `lata`, `papel`, `platano`, `manzana`, `vaso_unicel`, `frituras`.
- **Contenedor**: animaciones `organico`, `reciclable`, `no_reciclable`.
- **Smog**: `Default` con smog_1 y smog_2, velocidad 4, loop.

### Configuración del Platform (Brote)

Max speed **220**, Acceleration **1500**, Deceleration **1800**, Jump strength **560**, Gravity **1500**, Max fall speed **900**. *Default controls* = **Yes** (flechas para moverse, flecha arriba para saltar).

## 3. Armado del nivel (Nivel1, 2560 × 360)

El suelo tiene **2 huecos** que hay que saltar. Coordenadas aproximadas (el suelo está en Y=328):

| Zona | X | Qué colocar |
|---|---|---|
| Inicio | 0–700 | Suelo 0→700. **Brote** en (80, 300). Residuos: *botella* (250, 300), *platano* (420, 300), *papel* sobre Plataforma (560, 230) |
| Hueco 1 | 700–800 | Sin suelo |
| Punto limpio 1 | 800–1300 | Suelo 800→1600. **Contenedores** en (950, 300) organico, (1010, 300) reciclable, (1070, 300) no_reciclable. Residuo *vaso_unicel* (1200, 300) |
| Zona del smog | 1300–1700 | **Smog** en (1450, 250). Plataformas en (1350, 240) y (1550, 200). Residuos *lata* (1560, 170) y *manzana* (1650, 300) |
| Hueco 2 | 1600–1700 | Sin suelo |
| Punto limpio 2 | 1700–2300 | Suelo 1700→2560. **Contenedores** otra vez (los 3) en (2000-2120, 300). Residuos *frituras* (1850, 300), *botella* (2250, 230, sobre una plataforma) y *platano* (2320, 300). En total son **9 residuos** |
| Meta | 2400 | **Meta** en (2450, 328) |

Para **cada Residuo** llena sus variables en el panel *Properties*:

| Animación | `tipo` | `dato` |
|---|---|---|
| botella | reciclable | Una botella de PET puede tardar cientos de años en degradarse. |
| lata | reciclable | El aluminio se puede reciclar una y otra vez. |
| papel | reciclable | Reciclar papel ayuda a salvar árboles. |
| platano | organico | Las cáscaras se vuelven composta para las plantas. |
| manzana | organico | Los restos de comida son orgánicos: ¡a la composta! |
| vaso_unicel | no_reciclable | El unicel casi no se recicla: mejor usa tu propio vaso. |
| frituras | no_reciclable | Las bolsas metalizadas de frituras no se reciclan. |

Y para cada **Contenedor**, `tipo` = el nombre de su animación.

> Cuando te pregunte por la **capa inicial** del Fondo: déjalo en `Juego` y mándalo al fondo de la capa (*Z order → Send to bottom*).

## 4. Variables globales (EventosNivel1)

Clic derecho en la hoja → *Add global variable*:

| Nombre | Tipo | Valor inicial |
|---|---|---|
| `Puntos` | Number | 0 |
| `VidasRestantes` | Number | 3 |
| `Restantes` | Number | 0 |
| `Tiempo` | Number | 120 |
| `Terminado` | Number | 0 |

## 5. Hoja de eventos (EventosNivel1)

Copia cada evento tal cual. **Cond.** = condiciones; **Acc.** = acciones. `↳` = sub-evento (se agrega con clic derecho → *Add sub-event*).

### Inicio y HUD

**E1.** Cond.: *System → On start of layout*
Acc.:
- System → **Reset global variables** (para reiniciar al perder)
- System → Set `Restantes` to `Residuo.Count`
- Audio → Play `musica_parque` **looping**, volume -10 dB, tag "musica"
- TextoMensaje → Set text `"Lleva cada residuo a su contenedor (tecla E)."`
- System → Wait 4 seconds
- TextoMensaje → Set text `""`

↳ **E2.** (sub-evento de E1, guarda dónde empezó cada residuo) Cond.: *System → For each Residuo* · Acc.: Residuo → Set `inicioX` to `Self.X`; Residuo → Set `inicioY` to `Self.Y`

**E3.** Cond.: *System → Every tick*
Acc.:
- Fondo → Set X to `ViewportLeft("Juego") * 0.7` (efecto parallax con una sola capa)
- Vidas → Set width to `VidasRestantes * 27`
- TextoHUD → Set text `"Puntos: " & Puntos & "   Basura: " & Restantes & "   Tiempo: " & ceil(Tiempo)`

**E4.** Cond.: *System → Compare variable* `Terminado = 0` · Acc.: System → Subtract `dt` from `Tiempo`

### Animaciones y control

**E5.** Cond.: *Brote → Platform: Is jumping* **OR** *Brote → Platform: Is falling* (clic derecho al evento → *Make 'Or' block*) · Acc.: Brote → Set animation `"Salto"`
**E6.** Cond.: *System → Else* + *Brote → Platform: Is moving* · Acc.: Brote → Set animation `"Correr"` (from current frame)
**E7.** Cond.: *System → Else* · Acc.: Brote → Set animation `"Reposo"`
**E8.** Cond.: *Keyboard → Key is down: Left arrow* · Acc.: Brote → Set mirrored
**E9.** Cond.: *Keyboard → Key is down: Right arrow* · Acc.: Brote → Set not mirrored
**E10.** Cond.: *Brote → Platform: On jump* · Acc.: Audio → Play `salto`

### Recoger residuo (mecánica principal)

**E11.** Cond.:
- *Keyboard → On key pressed: E*
- *Brote → Compare instance variable* `llevando = ""`
- *Brote → Is overlapping another object: Residuo*
- *System → Pick nearest/furthest:* Residuo, nearest to `Brote.X`, `Brote.Y`

Acc.:
- Residuo → Set position to (`Brote.X`, `Brote.BBoxTop - 14`)
- Residuo → Sine: Set active **No**
- Residuo → Pin: **Pin to Brote** (Position only)
- Residuo → Set `cargado` to **True**
- Brote → Set `llevando` to `Residuo.tipo`
- Audio → Play `recoger`
- TextoMensaje → Set text `"Llevas: " & Residuo.AnimationName & ". ¿En qué contenedor va?"`

### Soltar en un contenedor

**E12.** Cond.:
- *Keyboard → On key pressed: E*
- *Brote → Compare instance variable* `llevando ≠ ""`
- *Brote → Is overlapping another object: Contenedor*
- *Residuo → Is boolean instance variable set: cargado*

↳ **E13.** Cond.: *Contenedor → Compare instance variable* `tipo = Brote.llevando` (**acierto**)
Acc.:
- System → Add 10 to `Puntos`
- System → Subtract 1 from `Restantes`
- System → Create object `Destello` on layer "Juego" at (`Contenedor.X`, `Contenedor.BBoxTop`)
- Audio → Play `correcto`
- TextoMensaje → Set text `"¡Muy bien! " & Residuo.dato`
- Residuo → Destroy
- Brote → Set `llevando` to `""`

↳ **E14.** Cond.: *System → Else* (**error**)
Acc.:
- System → Subtract 1 from `VidasRestantes`
- Audio → Play `incorrecto`
- TextoMensaje → Set text `"¡Ups! " & Residuo.AnimationName & " no va en " & Contenedor.tipo & ". Inténtalo de nuevo."`
- Residuo → Pin: Unpin
- Residuo → Set position to (`Residuo.inicioX`, `Residuo.inicioY`) (regresa a su lugar)
- Residuo → Sine: Set active **Yes**
- Residuo → Set `cargado` to **False**
- Brote → Set `llevando` to `""`

### Peligros

**E15.** Cond.: *Brote → On collision with another object: Smog* + *Brote → Flash: **Invert** Is flashing*
Acc.:
- System → Subtract 1 from `VidasRestantes`
- Brote → Flash: on 0.1, off 0.1, for 1.5 s
- Brote → Platform: Set vector Y to -400 (rebote)
- Audio → Play `dano`

**E16.** Cond.: *Brote → Compare Y > 380* (se cayó a un hueco)
Acc.:
- System → Subtract 1 from `VidasRestantes`
- Brote → Set position to (80, 300)
- Audio → Play `dano`

### Ganar y perder

**E17.** Cond.: *System → Compare variable* `VidasRestantes ≤ 0` **OR** `Tiempo ≤ 0` (bloque OR) + *System → Trigger once*
Acc.:
- System → Set `Terminado` to 1
- Brote → Platform: Set enabled **No**
- Audio → Stop "musica"
- TextoMensaje → Set text `"¡El smog ganó esta vez! Reintentando..."`
- System → Wait 3 seconds
- System → Restart layout

**E18.** Cond.: *Brote → Is overlapping Meta* + *System → Compare variable* `Restantes = 0` + *System → Trigger once*
Acc.:
- System → Set `Terminado` to 1
- System → Add `ceil(Tiempo) * 2` to `Puntos` (bono por tiempo)
- Brote → Platform: Set enabled **No**
- Audio → Stop "musica" · Audio → Play `victoria`
- TextoMensaje → Set text `"¡Parque limpio! Puntaje final: " & Puntos`

**E19.** Cond.: *Brote → Is overlapping Meta* + *System → Compare variable* `Restantes > 0` + *System → Trigger once*
Acc.: TextoMensaje → Set text `"Aún quedan " & Restantes & " residuos en el parque."`

**E20.** (pausa, opcional) Cond.: *Keyboard → On key pressed: P*
↳ Cond.: *System → Compare time scale = 1* · Acc.: System → Set time scale 0; TextoMensaje "Pausa"
↳ Cond.: *Else* · Acc.: System → Set time scale 1; TextoMensaje ""

Total: **unos 24 eventos** contando los sub-eventos y las variables globales.

## 6. Probar

- **F5** (*Preview*). Revisa la lista de pruebas en `docs/03_reporte_beta_testing.md` y anota los resultados ahí.
- Usa el **Debugger** (*Preview → Debug layout*) para ver `Puntos`, `Restantes` y las variables de cada Residuo en vivo.

## 7. Controles táctiles para celular (opcional, +6 eventos)

Agrega 4 Sprites en la capa HUD: `BotonIzq`, `BotonDer`, `BotonSaltar`, `BotonE` (círculos semitransparentes abajo).

- *Touch → Is touching BotonIzq* → Brote → Platform: **Simulate control Left**; Set mirrored
- *Touch → Is touching BotonDer* → Simulate control Right; Set not mirrored
- *Touch → On touched BotonSaltar* → Simulate control Jump
- Para `BotonE`: copia las condiciones de E11 y E12 cambiando *On key pressed: E* por *Touch → On touched BotonE* (o usa un bloque OR con las dos condiciones).

## 8. Exportar la versión Beta (HTML5)

1. *Menu → Project → Export* → **Web (HTML5)** → minify: *Simple*.
2. Descomprime el zip en `ecogame/web/` del repositorio (ahí debe quedar `index.html`).
3. En GitHub: *Settings → Pages → Source: GitHub Actions* y *Settings → Secrets and variables → Actions → Variables* → crea `PUBLICAR_JUEGO` = `si`.
4. Haz push a `main`: el pipeline publica el juego en `https://TU-USUARIO.github.io/TU-REPO/` y la app EcoRuta lo abre con el botón 🎮.
5. Guarda también el proyecto (*Save as → Download a copy*) como `ecogame/EcoGame.c3p` en el repositorio.
