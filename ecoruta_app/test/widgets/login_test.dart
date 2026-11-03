import 'package:ecoruta/datos/repositorios.dart';
import 'package:ecoruta/pantallas/pantalla_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../falsos.dart';

void main() {
  late AuthFalso auth;

  setUp(() => auth = AuthFalso());
  tearDown(() => auth.cerrar());

  Future<void> abrir(WidgetTester t) =>
      t.pumpWidget(MaterialApp(home: PantallaLogin(auth: auth)));

  testWidgets('no llama a la nube si el correo es inválido', (t) async {
    await abrir(t);
    await t.enterText(find.byKey(const Key('campoCorreo')), 'correo-malo');
    await t.enterText(find.byKey(const Key('campoContrasena')), 'x');
    await t.tap(find.byKey(const Key('botonEnviar')));
    await t.pump();
    expect(find.text('Correo no válido'), findsOneWidget);
    expect(auth.llamadas, isEmpty);
  });

  testWidgets('inicia sesión con datos válidos', (t) async {
    await abrir(t);
    await t.enterText(find.byKey(const Key('campoCorreo')), 'ana@eco.mx');
    await t.enterText(find.byKey(const Key('campoContrasena')), 'EcoRuta2026');
    await t.tap(find.byKey(const Key('botonEnviar')));
    await t.pump();
    expect(auth.llamadas, ['login:ana@eco.mx']);
  });

  testWidgets('muestra un mensaje genérico si falla', (t) async {
    auth.fallarCon = const ErrorAuth('Correo o contraseña incorrectos.');
    await abrir(t);
    await t.enterText(find.byKey(const Key('campoCorreo')), 'ana@eco.mx');
    await t.enterText(find.byKey(const Key('campoContrasena')), 'Mala1234');
    await t.tap(find.byKey(const Key('botonEnviar')));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('textoError')), findsOneWidget);
  });

  testWidgets('en registro exige contraseña robusta', (t) async {
    await abrir(t);
    await t.tap(find.text('¿No tienes cuenta? Regístrate'));
    await t.pump();
    await t.enterText(find.byKey(const Key('campoCorreo')), 'ana@eco.mx');
    await t.enterText(find.byKey(const Key('campoContrasena')), 'debil');
    await t.tap(find.byKey(const Key('botonEnviar')));
    await t.pump();
    expect(find.text('Mínimo 8 caracteres'), findsOneWidget);
    expect(auth.llamadas, isEmpty);
  });
}
