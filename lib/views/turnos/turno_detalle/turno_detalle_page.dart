import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/enums.dart';
import '../../../models/turno.dart';
import '../../../viewmodels/app_state.dart';
import '../../../app_provider.dart';

class TurnoDetallePage extends StatelessWidget {
  final String turnoId;

  const TurnoDetallePage({super.key, required this.turnoId});

  @override
  Widget build(BuildContext context) {
    final appState = TurcoAppProvider.of(context);

    return ListenableBuilder(
      listenable: appState,
      builder: (context, child) {
        final turnoIndex = appState.turnos.indexWhere((t) => t.id == turnoId);
        
        if (turnoIndex == -1) {
          return _buildErrorNoEncontrado(context);
        }

        final turno = appState.turnos[turnoIndex];
        return _buildDetalle(context, appState, turno);
      },
    );
  }

  Widget _buildErrorNoEncontrado(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del turno')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.search_off, size: 64, color: colors.error),
              ),
              const SizedBox(height: 24),
              Text(
                'No encontramos este turno',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'El turno no existe o ya no está disponible.',
                style: TextStyle(color: colors.outline),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.go('/agenda'),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver a la agenda'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetalle(BuildContext context, AppState appState, Turno turno) {
    final colors = Theme.of(context).colorScheme;
    final cliente = appState.clientes.firstWhere((c) => c.id == turno.clienteId);
    final estilista = appState.estilistas.firstWhere((e) => e.id == turno.estilistaId);
    
    final servicios = turno.serviciosIds.map((id) => appState.servicios.firstWhere((s) => s.id == id)).toList();
    final duracionTotal = appState.calcularDuracion(turno.serviciosIds);
    final precioTotal = appState.calcularPrecio(turno.serviciosIds);
    final horaFin = appState.calcularHoraFin(turno.fechaHoraInicio, turno.serviciosIds);

    final meses = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
    final dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    final fechaStr = '${dias[turno.fechaHoraInicio.weekday - 1]} ${turno.fechaHoraInicio.day} de ${meses[turno.fechaHoraInicio.month - 1]} de ${turno.fechaHoraInicio.year}';
    final horaInicioStr = '${turno.fechaHoraInicio.hour.toString().padLeft(2, '0')}:${turno.fechaHoraInicio.minute.toString().padLeft(2, '0')}';
    final horaFinStr = '${horaFin.hour.toString().padLeft(2, '0')}:${horaFin.minute.toString().padLeft(2, '0')}';
    
    final creacionStr = '${turno.fechaCreacion.day}/${turno.fechaCreacion.month}/${turno.fechaCreacion.year}';
    final modStr = '${turno.fechaModificacion.day}/${turno.fechaModificacion.month}/${turno.fechaModificacion.year}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del turno'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: colors.primaryContainer,
                          child: Text(cliente.nombre[0], style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 20)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cliente.nombre, style: Theme.of(context).textTheme.titleLarge),
                              Text(cliente.telefono, style: TextStyle(color: colors.outline)),
                            ],
                          ),
                        ),
                        _buildEstadoChip(context, turno.estado),
                      ],
                    ),
                    const Divider(height: 32),
                    _buildInfoRow(context, Icons.calendar_today, 'Fecha', fechaStr),
                    const SizedBox(height: 12),
                    _buildInfoRow(context, Icons.access_time, 'Hora', '$horaInicioStr a $horaFinStr (${duracionTotal ~/ 60} h ${duracionTotal % 60} min)'),
                    const SizedBox(height: 12),
                    _buildInfoRow(context, Icons.person_outline, 'Estilista', estilista.nombre),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Servicios', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    ...servicios.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.nombre, style: const TextStyle(fontWeight: FontWeight.w500)),
                                Text('${s.duracionMinutos} min', style: TextStyle(color: colors.outline, fontSize: 12)),
                              ],
                            ),
                          ),
                          Text('\$ ${s.precio.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    )),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: Theme.of(context).textTheme.titleMedium),
                        Text('\$ ${precioTotal.toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: colors.primary)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notas', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 150),
                      child: SingleChildScrollView(
                        child: Text(
                          turno.notas ?? 'Sin notas.',
                          style: TextStyle(color: turno.notas == null ? colors.outline : null),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            
            Text('Creado el $creacionStr · Modificado el $modStr', style: TextStyle(color: colors.outline, fontSize: 12)),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButtons(context, appState, turno),
    );
  }

  Widget _buildEstadoChip(BuildContext context, EstadoTurno estado) {
    final colors = Theme.of(context).colorScheme;
    Color bg;
    switch (estado) {
      case EstadoTurno.programado: bg = colors.primaryContainer;
      case EstadoTurno.completado: bg = colors.tertiaryContainer;
      case EstadoTurno.cancelado: bg = colors.errorContainer;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(estado.name[0].toUpperCase() + estado.name.substring(1), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: colors.outline),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: colors.outline)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons(BuildContext context, AppState appState, Turno turno) {
    final colors = Theme.of(context).colorScheme;

    if (turno.estado != EstadoTurno.programado) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: colors.surfaceContainer),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 18, color: colors.outline),
            const SizedBox(width: 8),
            Text('Turno ${turno.estado.name}: solo lectura', style: TextStyle(color: colors.outline)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [BoxShadow(color: colors.shadow.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))], // <-- CORREGIDO AQUÍ
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final result = await context.push('/turno/${turno.id}/editar');
                  if (result != null && context.mounted) {
                    context.pop(result); 
                  }
                },
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Editar'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: () async {
                  final confirm = await _confirmar(context, '¿Marcar como completado?', 'El turno pasará a estado completado.');
                  if (confirm == true) {
                    appState.updateTurno(turno.copyWith(estado: EstadoTurno.completado));
                    if (context.mounted) context.pop(); 
                  }
                },
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Completar'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: colors.secondaryContainer,
                  foregroundColor: colors.onSecondaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () async {
                final confirm = await _confirmar(context, '¿Cancelar este turno?', 'El horario quedará libre. Esta acción no se puede deshacer.');
                if (confirm == true) {
                  appState.updateTurno(turno.copyWith(estado: EstadoTurno.cancelado));
                  if (context.mounted) context.pop();
                }
              },
              icon: Icon(Icons.cancel_outlined, color: colors.error),
              tooltip: 'Cancelar turno',
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(12),
                side: BorderSide(color: colors.outline),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmar(BuildContext context, String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(children: [Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error), const SizedBox(width: 8), Expanded(child: Text(title))]),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Volver')),
          TextButton(onPressed: () => Navigator.pop(context, true), style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error), child: const Text('Confirmar')),
        ],
      ),
    );
  }
}