import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app.dart';
import '../datos/modelos.dart';
import '../datos/servicio_acciones.dart';
import 'pantalla_aire.dart';
import 'pantalla_nueva_accion.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key, required this.uid, required this.deps});

  final String uid;
  final Dependencias deps;

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  int _pestana = 0;

  Future<void> _abrirJuego() async {
    final url = widget.deps.urlJuego;
    // Solo se abren direcciones seguras
    if (url.scheme != 'https' ||
        !await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir EcoGame')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final paginas = [
      _ListaAcciones(uid: widget.uid, servicio: widget.deps.acciones),
      PantallaAire(api: widget.deps.aire),
      _ListaPuntos(servicio: widget.deps.acciones),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoRuta'),
        actions: [
          IconButton(
            tooltip: 'Jugar EcoGame',
            icon: const Icon(Icons.sports_esports),
            onPressed: _abrirJuego,
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: widget.deps.auth.cerrarSesion,
          ),
        ],
      ),
      body: paginas[_pestana],
      floatingActionButton: _pestana == 0
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Registrar acción'),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => PantallaNuevaAccion(
                    uid: widget.uid, servicio: widget.deps.acciones),
              )),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pestana,
        onDestinationSelected: (i) => setState(() => _pestana = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.eco), label: 'Mis acciones'),
          NavigationDestination(icon: Icon(Icons.air), label: 'Aire'),
          NavigationDestination(icon: Icon(Icons.recycling), label: 'Reciclaje'),
        ],
      ),
    );
  }
}

class _ListaAcciones extends StatelessWidget {
  const _ListaAcciones({required this.uid, required this.servicio});

  final String uid;
  final ServicioAcciones servicio;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AccionEco>>(
      stream: servicio.observar(uid),
      builder: (context, snap) {
        if (snap.hasError) {
          return const Center(child: Text('No se pudieron cargar tus acciones'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final acciones = snap.data!;
        return Column(
          children: [
            Card(
              margin: const EdgeInsets.all(16),
              child: ListTile(
                leading: const Icon(Icons.emoji_events, color: Colors.amber),
                title: Text('${ServicioAcciones.totalPuntos(acciones)} EcoPuntos'),
                subtitle: Text('${acciones.length} acciones registradas'),
              ),
            ),
            Expanded(
              child: acciones.isEmpty
                  ? const Center(child: Text('Registra tu primera acción ecológica'))
                  : ListView.builder(
                      itemCount: acciones.length,
                      itemBuilder: (_, i) {
                        final a = acciones[i];
                        return Dismissible(
                          key: ValueKey(a.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) => servicio.eliminar(uid, a.id!),
                          child: ListTile(
                            title: Text(a.tipo.descripcion),
                            subtitle: FutureBuilder<String?>(
                              future: servicio.leerNota(a),
                              builder: (_, n) => Text([
                                '${a.cantidad} ${a.tipo.unidad}',
                                _fecha(a.fecha),
                                if (n.data != null) n.data!,
                              ].join(' · ')),
                            ),
                            trailing: Text('+${a.puntos}'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  static String _fecha(DateTime f) =>
      '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';
}

class _ListaPuntos extends StatelessWidget {
  const _ListaPuntos({required this.servicio});

  final ServicioAcciones servicio;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PuntoReciclaje>>(
      stream: servicio.puntosReciclaje(),
      builder: (context, snap) {
        if (snap.hasError) {
          return const Center(child: Text('No se pudieron cargar los puntos'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final puntos = snap.data!;
        if (puntos.isEmpty) {
          return const Center(child: Text('Aún no hay puntos de reciclaje'));
        }
        return ListView(
          children: [
            for (final p in puntos)
              ListTile(
                leading: const Icon(Icons.place, color: Color(0xFF2E7D32)),
                title: Text(p.nombre),
                subtitle: Text('${p.direccion}\nAcepta: ${p.acepta.join(', ')}'),
                isThreeLine: true,
              ),
          ],
        );
      },
    );
  }
}
