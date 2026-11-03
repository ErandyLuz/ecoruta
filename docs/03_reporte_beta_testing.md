# 3. Reporte de Beta Testing: EcoGame v0.9 (Beta) y EcoRuta v0.9.0

> **Plantilla.** Llena las columnas *Resultado* y *Observaciones* con lo que pase **de verdad** al probar. No inventes resultados.

**Equipo:** ______________________ **Fecha(s) de prueba:** ____________
**Versión probada:** EcoGame Beta (HTML5) · EcoRuta APK `ecoruta-beta-apk` (build de CI n.º ____)
**Dispositivos / navegadores:** ______________________________________

## 3.1 Casos de prueba del videojuego

| ID | Caso | Pasos | Resultado esperado | Resultado (✅/❌) | Observaciones |
|---|---|---|---|---|---|
| J01 | Inicio del nivel | Abrir el juego | Música suena, HUD muestra Puntos 0, Basura 9, Tiempo 120, 3 corazones | | |
| J02 | Movimiento | Flechas izquierda/derecha | Brote corre y voltea hacia donde va | | |
| J03 | Salto | Flecha arriba | Salta con sonido; puede subir a plataformas de madera desde abajo | | |
| J04 | Recoger | Pararse sobre la botella y pulsar E | La botella queda sobre la cabeza y aparece «Llevas: botella» | | |
| J05 | Solo uno a la vez | Llevar un residuo y pulsar E sobre otro | No recoge el segundo | | |
| J06 | Acierto | Llevar la botella al contenedor azul y pulsar E | +10 puntos, Basura −1, destello, sonido y dato ecológico | | |
| J07 | Error | Llevar el plátano al contenedor azul | −1 vida, mensaje de pista, el plátano vuelve a su lugar | | |
| J08 | Smog | Tocar la nube de smog | −1 vida, parpadeo, rebote; no vuelve a dañar mientras parpadea | | |
| J09 | Hueco | Caer en un hueco | −1 vida y reaparece al inicio | | |
| J10 | Meta incompleta | Llegar a la bandera con basura pendiente | Mensaje «Aún quedan N residuos» | | |
| J11 | Victoria | Separar los 9 residuos y tocar la bandera | Sonido de victoria, bono de tiempo, puntaje final | | |
| J12 | Derrota | Perder las 3 vidas | Mensaje y el nivel se reinicia con valores iniciales | | |
| J13 | Tiempo | Esperar a que el tiempo llegue a 0 | Igual que J12 | | |
| J14 | Pausa | Pulsar P dos veces | Pausa y continúa | | |
| J15 | Celular | Abrir la URL desde EcoRuta (botón 🎮) en Android | El juego carga y se adapta a la pantalla | | |

## 3.2 Casos de prueba de la app EcoRuta

| ID | Caso | Resultado esperado | Resultado (✅/❌) | Observaciones |
|---|---|---|---|---|
| A01 | Registro con contraseña débil | Se rechaza sin llamar al servidor | | |
| A02 | Registro válido | Cuenta creada y llega el correo de verificación | | |
| A03 | Login con contraseña incorrecta | Mensaje genérico «Correo o contraseña incorrectos» | | |
| A04 | Registrar acción con nota | Aparece en la lista con sus puntos; en la consola de Firestore la nota se ve **cifrada** | | |
| A05 | Cantidad 0 o 5000 | El formulario la rechaza | | |
| A06 | Borrar acción (deslizar) | Desaparece de la lista y de Firestore | | |
| A07 | Calidad del aire | Muestra índice y PM2.5 de la ciudad elegida | | |
| A08 | Sin internet | Mensajes de error claros, la app no se cierra | | |
| A09 | Otro usuario | Un segundo usuario no ve las acciones del primero | | |
| A10 | Cerrar sesión | Regresa al login | | |

## 3.3 Encuesta a beta testers (escala 1–5)

| Pregunta | T1 | T2 | T3 | T4 | T5 | Promedio |
|---|---|---|---|---|---|---|
| ¿Entendiste qué hacer sin ayuda? | | | | | | |
| ¿Los controles responden bien? | | | | | | |
| ¿Aprendiste dónde va cada residuo? | | | | | | |
| ¿La dificultad fue adecuada? | | | | | | |
| ¿Volverías a jugar? | | | | | | |

Comentarios abiertos: _____________________________________________

## 3.4 Errores encontrados

| ID | Descripción | Severidad (Crítico/Mayor/Menor) | Pasos para reproducir | Estado (Abierto/Corregido) | Corregido en |
|---|---|---|---|---|---|
| B01 | | | | | |

## 3.5 Resultados del CI (anexar captura de la pestaña Actions)

| Job | Resultado | Pruebas aprobadas | Cobertura |
|---|---|---|---|
| calidad-app | | ___ / ___ | ___ % |
| secretos | | | |
| apk-beta | | | |
| publicar-juego | | | |

## 3.6 Conclusión

_______________________________________________________________
