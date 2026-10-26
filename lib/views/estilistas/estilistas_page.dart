import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/enums.dart';
import '../../models/estilista.dart';
import '../../viewmodels/app_state.dart';
import '../../app_provider.dart';

class EstilistasPage extends StatelessWidget {
  const EstilistasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = TurcoAppProvider.of(context);
    final colors = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: appState,
      builder: (context, child) {
        // Contar turnos programados HOY
        final hoy = DateTime.now();
        int totalTurnosHoy = appState.turnos.where((t) {
          return t.fechaHoraInicio.year == hoy.year &&
                 t.fechaHoraInicio.month == hoy.month &&
                 t.fechaHoraInicio.day == hoy.day &&
                 t.estado == EstadoTurno.programado;
        }).length;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // --- SLIVER APP BAR PLEGABLE ---
              SliverAppBar(
                pinned: true,
                expandedHeight: 180.0,
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
                  title: const Text('Estilistas', style: TextStyle(fontWeight: FontWeight.bold)),
                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.badge_outlined, size: 40, color: colors.onPrimary),
                          const SizedBox(height: 8),
                          Text(
                            '${appState.estilistas.length} profesionales · $totalTurnosHoy turnos programados hoy',
                            style: TextStyle(color: colors.onPrimary.withOpacity(0.8), fontSize: 14),
                          ),
                          const SizedBox(height: 40), // Espacio para que no choque con el título plegable
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // --- LISTA DE ESTILISTAS ---
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final estilista = appState.estilistas[index];
                      return _buildEstilistaCard(context, appState, estilista);
                    },
                    childCount: appState.estilistas.length,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEstilistaCard(BuildContext context, AppState appState, Estilista estilista) {
    final colors = Theme.of(context).colorScheme;

    // Calcular turnos de hoy para este estilista
    final hoy = DateTime.now();
    final turnosHoy = appState.turnos.where((t) {
      return t.estilistaId == estilista.id &&
             t.fechaHoraInicio.year == hoy.year &&
             t.fechaHoraInicio.month == hoy.month &&
             t.fechaHoraInicio.day == hoy.day &&
             t.estado == EstadoTurno.programado;
    }).length;

    // Agrupar servicios por categoría
    final Map<CategoriaServicio, List<String>> serviciosAgrupados = {};
    for (var id in estilista.serviciosIds) {
      final servicio = appState.servicios.firstWhere((s) => s.id == id);
      serviciosAgrupados.putIfAbsent(servicio.categoria, () => []).add(servicio.nombre);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/agenda?estilista=${estilista.id}'), // Navegar a Agenda con query param
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: colors.primaryContainer,
                    child: Text(
                      estilista.nombre[0], 
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.primary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Nombre y turnos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(estilista.nombre, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(
                          turnosHoy == 0 ? 'Sin turnos hoy' : '$turnosHoy turno${turnosHoy > 1 ? 's' : ''} hoy',
                          style: TextStyle(
                            color: turnosHoy == 0 ? colors.outline : colors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: colors.outline),
                ],
              ),
              const SizedBox(height: 12),
              // Servicios agrupados con Wrap
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: serviciosAgrupados.entries.map((entry) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key.name.toUpperCase(),
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: colors.outline),
                        ),
                        Text(
                          entry.value.join(', '),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}