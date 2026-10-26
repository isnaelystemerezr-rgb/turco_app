import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/enums.dart';
import '../../models/turno.dart';
import '../../viewmodels/app_state.dart';
import '../../viewmodels/agenda_viewmodel.dart';
import '../../app_provider.dart';

class AgendaPage extends StatefulWidget {
  final String? estilistaQueryParam;
  const AgendaPage({super.key, this.estilistaQueryParam});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  late AgendaViewModel vm;

  @override
  void initState() {
    super.initState();
    // Se inicializa en didChangeDependencies para tener acceso al AppState
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!mounted) return;
    final appState = TurcoAppProvider.of(context);
    
    // Inicializar VM solo una vez o si cambia el query param
    if (widget.estilistaQueryParam != null) {
       // Si venimos de Estilistas con un filtro, aplicarlo
       vm = AgendaViewModel(appState: appState);
       vm.setEstilistaFiltro(widget.estilistaQueryParam);
    } else {
       vm = AgendaViewModel(appState: appState);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = TurcoAppProvider.of(context);
    final colors = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: Listenable.merge([appState, vm]),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.content_cut, color: colors.onPrimary, size: 20),
                ),
                const SizedBox(width: 8),
                Text('Turco', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.lightbulb_outline),
                onPressed: () => _mostrarMenuTema(context, appState),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildTiraDias(context),
              _buildResumen(context),
              _buildFiltroEstilistas(context, appState),
              _buildFiltroEstados(context),
              const SizedBox(height: 8),
              Expanded(
                child: vm.turnosDelDia.isEmpty
                    ? _buildEstadoVacio(context)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: vm.turnosDelDia.length,
                        itemBuilder: (context, index) {
                          return _buildTurnoCard(context, appState, vm.turnosDelDia[index]);
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final result = await context.push('/turno/nuevo');
              if (result != null && result is Turno) {
                vm.setFecha(result.fechaHoraInicio);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Turno guardado para el ${result.fechaHoraInicio.day}/${result.fechaHoraInicio.month}')),
                  );
                }
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Nuevo turno'),
          ),
        );
      },
    );
  }

  void _mostrarMenuTema(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.settings_system_daydream), title: const Text('Sistema'), trailing: appState.themeModeIndex == 0 ? const Icon(Icons.check) : null, onTap: () { appState.setThemeMode(0); Navigator.pop(context); }),
            ListTile(leading: const Icon(Icons.light_mode), title: const Text('Claro'), trailing: appState.themeModeIndex == 1 ? const Icon(Icons.check) : null, onTap: () { appState.setThemeMode(1); Navigator.pop(context); }),
            ListTile(leading: const Icon(Icons.dark_mode), title: const Text('Oscuro'), trailing: appState.themeModeIndex == 2 ? const Icon(Icons.check) : null, onTap: () { appState.setThemeMode(2); Navigator.pop(context); }),
          ],
        ),
      ),
    );
  }

  Widget _buildTiraDias(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dias = vm.diasDeLaSemana;
    final meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.chevron_left), onPressed: vm.semanaAnterior),
              Text('${meses[vm.fechaSeleccionada.month - 1]} ${vm.fechaSeleccionada.year}', style: Theme.of(context).textTheme.titleMedium),
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.chevron_right), onPressed: vm.semanaSiguiente),
                  TextButton.icon(
                    onPressed: () async {
                      final f = await showDatePicker(
                        context: context, initialDate: vm.fechaSeleccionada, firstDate: DateTime(2020), lastDate: DateTime(2030),
                        selectableDayPredicate: (d) => d.weekday != DateTime.sunday,
                      );
                      if (f != null) vm.setFecha(f);
                    },
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: const Text('Elegir fecha', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: dias.length,
            itemBuilder: (context, index) {
              final dia = dias[index];
              final isSelected = dia.day == vm.fechaSeleccionada.day && dia.month == vm.fechaSeleccionada.month;
              final isDomingo = dia.weekday == DateTime.sunday;
              final diasSemana = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

              return GestureDetector(
                onTap: isDomingo ? null : () => vm.setFecha(dia),
                child: Container(
                  width: 50,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? colors.primary : (isDomingo ? Colors.transparent : colors.surface),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(diasSemana[index], style: TextStyle(fontSize: 11, color: isSelected ? colors.onPrimary : colors.outline)),
                      const SizedBox(height: 4),
                      Text('${dia.day}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? colors.onPrimary : (isDomingo ? colors.outline.withOpacity(0.4) : colors.onSurface))),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildResumen(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildResumenCard(context, '${vm.turnosProgramados}', 'Programados'),
          const SizedBox(width: 8),
          _buildResumenCard(context, '${vm.turnosCompletados}', 'Completados'),
          const SizedBox(width: 8),
          _buildResumenCard(context, '\$${vm.ingresoEstimado.toStringAsFixed(0)}', 'Ingreso est.'),
        ],
      ),
    );
  }

  Widget _buildResumenCard(BuildContext context, String value, String label) {
    final colors = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: colors.surfaceContainer, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: colors.primary)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, color: colors.outline)),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltroEstilistas(BuildContext context, AppState appState) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          FilterChip(label: const Text('Todos'), selected: vm.estilistaFiltro == null, onSelected: (_) => vm.setEstilistaFiltro(null)),
          const SizedBox(width: 8),
          ...appState.estilistas.map((e) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(label: Text(e.nombre), selected: vm.estilistaFiltro == e.id, onSelected: (_) => vm.setEstilistaFiltro(e.id)),
          )),
        ],
      ),
    );
  }

  Widget _buildFiltroEstados(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SegmentedButton<EstadoTurno?>(
        segments: const [
          ButtonSegment(value: null, label: Text('Todos')),
          ButtonSegment(value: EstadoTurno.programado, label: Text('Program.')),
          ButtonSegment(value: EstadoTurno.completado, label: Text('Complet.')),
          ButtonSegment(value: EstadoTurno.cancelado, label: Text('Cancel.')),
        ],
        selected: {vm.estadoFiltro},
        onSelectionChanged: (val) => vm.setEstadoFiltro(val.first),
      ),
    );
  }

  Widget _buildTurnoCard(BuildContext context, AppState appState, Turno turno) {
    final colors = Theme.of(context).colorScheme;
    final cliente = appState.clientes.firstWhere((c) => c.id == turno.clienteId);
    final estilista = appState.estilistas.firstWhere((e) => e.id == turno.estilistaId);
    final serviciosNombres = turno.serviciosIds.map((id) => appState.servicios.firstWhere((s) => s.id == id).nombre).join(' + ');
    final fin = appState.calcularHoraFin(turno.fechaHoraInicio, turno.serviciosIds);

    Color estadoColor;
    switch (turno.estado) {
      case EstadoTurno.programado: estadoColor = colors.primaryContainer;
      case EstadoTurno.completado: estadoColor = colors.tertiaryContainer;
      case EstadoTurno.cancelado: estadoColor = colors.errorContainer;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/turno/${turno.id}'),
        onLongPress: turno.estado == EstadoTurno.programado ? () => _menuAccionesRapidas(context, appState, turno) : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 4, height: 60, decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('${turno.fechaHoraInicio.hour.toString().padLeft(2, '0')}:${turno.fechaHoraInicio.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(' - ${fin.hour.toString().padLeft(2, '0')}:${fin.minute.toString().padLeft(2, '0')}', style: TextStyle(color: colors.outline, fontSize: 12)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: estadoColor, borderRadius: BorderRadius.circular(8)),
                          child: Text(turno.estado.name[0].toUpperCase() + turno.estado.name.substring(1), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colors.onSurface)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(cliente.nombre, style: Theme.of(context).textTheme.titleMedium),
                    Text(serviciosNombres, style: TextStyle(fontSize: 12, color: colors.outline)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 14, color: colors.outline),
                        const SizedBox(width: 4),
                        Text(estilista.nombre, style: TextStyle(fontSize: 12, color: colors.outline)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoVacio(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: colors.primaryContainer.withOpacity(0.5), shape: BoxShape.circle),
            child: Icon(Icons.event_busy, size: 48, color: colors.primary),
          ),
          const SizedBox(height: 16),
          Text('No hay turnos para este día', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Crea el primer turno con el botón de abajo o cambia los filtros.', textAlign: TextAlign.center, style: TextStyle(color: colors.outline)),
        ],
      ),
    );
  }

  void _menuAccionesRapidas(BuildContext context, AppState appState, Turno turno) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('Marcar como completado'),
              onTap: () async {
                final confirm = await _confirmar(context, '¿Marcar como completado?', 'El turno pasará a estado completado.');
                if (confirm == true) {
                  appState.updateTurno(turno.copyWith(estado: EstadoTurno.completado));
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.cancel_outlined, color: Theme.of(context).colorScheme.error),
              title: Text('Cancelar turno', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onTap: () async {
                final confirm = await _confirmar(context, '¿Cancelar este turno?', 'El horario quedará libre. Esta acción no se puede deshacer.');
                if (confirm == true) {
                  appState.updateTurno(turno.copyWith(estado: EstadoTurno.cancelado));
                  if (context.mounted) Navigator.pop(context);
                }
              },
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
        title: Row(children: [Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error), const SizedBox(width: 8), Text(title)]),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Volver')),
          TextButton(onPressed: () => Navigator.pop(context, true), style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error), child: const Text('Confirmar')),
        ],
      ),
    );
  }
}