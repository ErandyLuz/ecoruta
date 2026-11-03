import 'package:flutter/material.dart';

import 'datos/api_aire.dart';
import 'datos/repositorios.dart';
import 'datos/servicio_acciones.dart';
import 'pantallas/pantalla_inicio.dart';
import 'pantallas/pantalla_login.dart';

/// Dependencias de la app. Se inyectan para poder probar con versiones falsas.
class Dependencias {
  const Dependencias({
    required this.auth,
    required this.acciones,
    required this.aire,
    required this.urlJuego,
  });

  final RepositorioAuth auth;
  final ServicioAcciones acciones;
  final ApiCalidadAire aire;

  /// Dirección del EcoGame exportado a HTML5 (GitHub Pages).
  final Uri urlJuego;
}

class EcoRutaApp extends StatelessWidget {
  const EcoRutaApp({super.key, required this.deps});

  final Dependencias deps;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoRuta',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF2E7D32),
        useMaterial3: true,
      ),
      home: StreamBuilder<String?>(
        stream: deps.auth.cambiosDeSesion(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
          final uid = snap.data;
          return uid == null
              ? PantallaLogin(auth: deps.auth)
              : PantallaInicio(uid: uid, deps: deps);
        },
      ),
    );
  }
}
