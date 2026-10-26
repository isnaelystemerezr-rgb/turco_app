import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/enums.dart';
import '../../../models/servicio.dart';
import '../../../models/estilista.dart';
import '../../../models/cliente.dart';
import '../../../models/turno.dart';
import '../../../viewmodels/app_state.dart';
import '../../../viewmodels/turno_form_viewmodel.dart';
import '../../../app_provider.dart';

class TurnoFormPage extends StatefulWidget {
  final TurnoFormViewModel viewModel;

  const TurnoFormPage({super.key, required this.viewModel});

  @override
  State<TurnoFormPage> createState() => _TurnoFormPageState();
}

class _TurnoFormPageState extends State<TurnoFormPage> {
  late TurnoFormViewModel vm;
  final FocusNode _focusNode = FocusNode();
  bool _cambiosSinGuardar = false;

  @override
  void initState() {
    super.initState();
    vm = widget.viewModel;
    vm.addListener(_onVmChanged);
    vm.notasController.addListener(_onNotasChanged);
  }

  void _onVmChanged() {
    if (mounted) setState(() {});
  }

  void _onNotasChanged() {
    if (vm.notasController.text.isNotEmpty) {
      _cambiosSinGuardar = true;
    }
  }

  @override
  void dispose() {
    vm.removeListener(_onVmChanged);
    vm.notasController.removeListener(_onNotasChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = TurcoAppProvider.of(context);
    final colors = Theme.of(context).colorScheme;

    return PopScope(
      canPop: !_cambiosSinGuardar,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final salir = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('¿Descartar los cambios?'),
            content: const Text('Tienes cambios sin guardar en este turno. Si sales ahora se perderán.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Seguir editando')),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: colors.error),
                child: const Text('Descartar'),
              ),
            ],
          ),
        );
        if (salir == true && mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(vm.turnoOriginal == null ? 'Nuevo turno' : 'Editar turno'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (_cambiosSinGuardar) {
                final salir = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('¿Descartar los cambios?'),
                    content: const Text('Tienes cambios sin guardar en este turno. Si sales ahora se perderán.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Seguir editando')),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(foregroundColor: colors.error),
                        child: const Text('Descartar'),
                      ),
                    ],
                  ),
                );
                if (salir == true && context.mounted) {
                  context.pop();
                }
              } else {
                context.pop();
              }
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCliente(context, appState),
                    const SizedBox(height: 16),
                    _buildServicios(context, appState),
                    const SizedBox(height: 16),
                    _buildEstilista(context, appState),
                    const SizedBox(height: 16),
                    _buildFecha(context, appState),
                    const SizedBox(height: 16),
                    _buildHoras(context),
                    const SizedBox(height: 16),
                    _buildNotas(context),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            _buildResumenYBotones(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCliente(BuildContext context, AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cliente', style: TextStyle(color: vm.errorCliente != null ? Theme.of(context).colorScheme.error : null)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final cliente = await showModalBottomSheet<dynamic>(
              context: context,
              builder: (ctx) => _SelectorClienteSheet(appState: appState),
            );
            if (cliente != null) {
              vm.setCliente(cliente);
              _cambiosSinGuardar = true;
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: vm.errorCliente != null ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.person_outline, color: Theme.of(context).colorScheme.outline),
                const SizedBox(width: 12),
                Expanded(child: Text(vm.clienteSeleccionado?.nombre ?? 'Selecciona un cliente')),
                const Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ),
        if (vm.errorCliente != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(vm.errorCliente!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
          ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => _mostrarFormularioClienteNuevo(context, appState),
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('Crear cliente nuevo'),
        ),
      ],
    );
  }

  Widget _buildServicios(BuildContext context, AppState appState) {
    final colors = Theme.of(context).colorScheme;
    final serviciosFiltrados = appState.servicios.where((s) {
      return vm.filtroPublico == null || s.publico == vm.filtroPublico || s.publico == Publico.unisex;
    }).toList();

    final Map<CategoriaServicio, List<Servicio>> agrupados = {};
    for (var s in serviciosFiltrados) {
      agrupados.putIfAbsent(s.categoria, () => []).add(s);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Servicios para', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
        const SizedBox(height: 8),
        SegmentedButton<Publico?>(
          segments: const [
            ButtonSegment(value: null, label: Text('Todos')),
            ButtonSegment(value: Publico.mujeres, label: Text('Mujeres')),
            ButtonSegment(value: Publico.hombres, label: Text('Hombres')),
          ],
          selected: {vm.filtroPublico},
          onSelectionChanged: (val) => vm.setFiltroPublico(val.first),
        ),
        const SizedBox(height: 16),
        Text('Servicios', style: Theme.of(context).textTheme.titleMedium),
        if (vm.errorServicios != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(vm.errorServicios!, style: TextStyle(color: colors.error, fontSize: 12)),
          ),
        const SizedBox(height: 8),
        ...agrupados.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.key.name.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colors.outline)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: entry.value.map((s) {
                    final selected = vm.serviciosSeleccionados.contains(s);
                    return FilterChip(
                      label: Text(s.nombre),
                      selected: selected,
                      onSelected: (_) {
                        vm.toggleServicio(s);
                        _cambiosSinGuardar = true;
                      },
                      selectedColor: colors.primaryContainer,
                      checkmarkColor: colors.primary,
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEstilista(BuildContext context, AppState appState) {
    final colors = Theme.of(context).colorScheme;
    final disponibles = vm.estilistasDisponibles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Estilista', style: TextStyle(color: vm.errorEstilista != null ? colors.error : null)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: vm.errorEstilista != null ? colors.error : colors.outline),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Estilista>(
              value: vm.estilistaSeleccionado,
              isExpanded: true,
              hint: Text(vm.serviciosSeleccionados.isEmpty ? 'Primero elige los servicios' : 'Selecciona un estilista'),
              items: disponibles.map((e) {
                return DropdownMenuItem<Estilista>(
                  value: e,
                  child: Row(
                    children: [
                      const Icon(Icons.content_cut, size: 18),
                      const SizedBox(width: 8),
                      Text(e.nombre),
                    ],
                  ),
                );
              }).toList(),
              onChanged: disponibles.isEmpty ? null : (val) {
                vm.setEstilista(val);
                _cambiosSinGuardar = true;
              },
            ),
          ),
        ),
        if (vm.errorEstilista != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(vm.errorEstilista!, style: TextStyle(color: colors.error, fontSize: 12)),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: colors.outline),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Solo se muestran estilistas que realizan todos los servicios elegidos.',
                style: TextStyle(fontSize: 12, color: colors.outline),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFecha(BuildContext context, AppState appState) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fecha', style: TextStyle(color: vm.errorFecha != null ? colors.error : null)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final now = DateTime.now();
            // Si hoy es domingo, sugerimos el lunes
            final initialDate = now.weekday == DateTime.sunday 
                ? now.add(const Duration(days: 1)) 
                : now;

            final fecha = await showDatePicker(
              context: context,
              initialDate: vm.fechaSeleccionada ?? initialDate,
              firstDate: now,
              lastDate: now.add(const Duration(days: 365)),
              selectableDayPredicate: (day) => day.weekday != DateTime.sunday,
            );
            if (fecha != null) {
              vm.setFecha(fecha);
              _cambiosSinGuardar = true;
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: vm.errorFecha != null ? colors.error : colors.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: colors.outline),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    vm.fechaSeleccionada == null 
                      ? 'Selecciona una fecha' 
                      : '${vm.fechaSeleccionada!.day}/${vm.fechaSeleccionada!.month}/${vm.fechaSeleccionada!.year}',
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ),
        if (vm.errorFecha != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(vm.errorFecha!, style: TextStyle(color: colors.error, fontSize: 12)),
          ),
      ],
    );
  }

  Widget _buildHoras(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final franjas = vm.todasLasFranjas;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hora de inicio', style: TextStyle(color: vm.errorHora != null ? colors.error : null)),
        const SizedBox(height: 8),
        Row(
          children: [
            _leyenda(context, 'Libre', colors.surface, colors.outline),
            const SizedBox(width: 12),
            _leyenda(context, 'No disponible', colors.surfaceContainerHighest, null),
            const SizedBox(width: 12),
            _leyenda(context, 'Elegida', colors.primary, null),
          ],
        ),
        const SizedBox(height: 12),
        if (vm.fechaSeleccionada == null || vm.estilistaSeleccionado == null)
          Text('Selecciona fecha y estilista para ver las horas.', style: TextStyle(color: colors.outline))
        else if (franjas.every((f) => !vm.esFranjaDisponible(f)))
          Text('No hay horas disponibles para este día.', style: TextStyle(color: colors.error))
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.2,
            ),
            itemCount: franjas.length,
            itemBuilder: (context, index) {
              final franja = franjas[index];
              final disponible = vm.esFranjaDisponible(franja);
              final seleccionada = vm.horaSeleccionada == franja;

              return InkWell(
                onTap: disponible ? () {
                  vm.setHora(franja);
                  _cambiosSinGuardar = true;
                } : null,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: seleccionada 
                        ? colors.primary 
                        : (disponible ? colors.surface : colors.surfaceContainerHighest.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: seleccionada 
                          ? colors.primary 
                          : (disponible ? colors.outline : Colors.transparent),
                    ),
                  ),
                  child: Text(
                    '${franja.hour.toString().padLeft(2, '0')}:${franja.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: seleccionada 
                          ? colors.onPrimary 
                          : (disponible ? colors.onSurface : colors.outline.withOpacity(0.5)),
                      fontWeight: seleccionada ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        if (vm.errorHora != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(vm.errorHora!, style: TextStyle(color: colors.error, fontSize: 12)),
          ),
      ],
    );
  }

  Widget _leyenda(BuildContext context, String text, Color color, Color? border) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: border != null ? Border.all(color: border) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _buildNotas(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Notas (opcional)'),
        const SizedBox(height: 8),
        TextField(
          controller: vm.notasController,
          focusNode: _focusNode,
          maxLines: 3,
          maxLength: 500,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _guardarTurno(context),
          decoration: const InputDecoration(
            hintText: 'Ej. Prefiere la máquina en el número 2...',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  void _guardarTurno(BuildContext context) async {
    final turno = vm.guardar();
    if (turno == null) return;

    final appState = TurcoAppProvider.of(context);
    if (vm.turnoOriginal == null) {
      appState.addTurno(turno);
    } else {
      appState.updateTurno(turno);
    }
    if (context.mounted) {
      context.pop(turno);
    }
  }

  Widget _buildResumenYBotones(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final duracion = vm.duracionTotal;
    final fin = vm.horaFin;
    final precio = vm.precioTotal;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(color: colors.shadow.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: colors.primary),
                    const SizedBox(width: 4),
                    Text(duracion > 0 ? '${duracion ~/ 60}h ${duracion % 60}min' : '- h - min', style: TextStyle(color: colors.onPrimaryContainer, fontWeight: FontWeight.w500)),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.flag_outlined, size: 16, color: colors.primary),
                    const SizedBox(width: 4),
                    Text(fin != null ? 'Fin ${fin.format(context)}' : 'Fin --:--', style: TextStyle(color: colors.onPrimaryContainer, fontWeight: FontWeight.w500)),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 16, color: colors.primary),
                    const SizedBox(width: 4),
                    Text('\$${precio.toStringAsFixed(0)}', style: TextStyle(color: colors.onPrimaryContainer, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    if (_cambiosSinGuardar) {
                      final salir = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('¿Descartar los cambios?'),
                          content: const Text('Tienes cambios sin guardar en este turno. Si sales ahora se perderán.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Seguir editando')),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(foregroundColor: colors.error),
                              child: const Text('Descartar'),
                            ),
                          ],
                        ),
                      );
                      if (salir == true && context.mounted) context.pop();
                    } else {
                      context.pop();
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => _guardarTurno(context),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check, size: 18),
                      SizedBox(width: 8),
                      Text('Guardar turno'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _mostrarFormularioClienteNuevo(BuildContext context, AppState appState) {
    final formKey = GlobalKey<FormState>();
    final nombreCtrl = TextEditingController();
    final telCtrl = TextEditingController();
    final correoCtrl = TextEditingController();
    Genero? generoSelected;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nuevo cliente', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nombreCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: (v) => (v == null || v.trim().length < 3) ? 'Mínimo 3 caracteres' : null,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: telCtrl,
                      decoration: const InputDecoration(labelText: 'Teléfono'),
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.length != 8) return 'Debe tener 8 dígitos';
                        if (appState.clientes.any((c) => c.telefono == v)) return 'Teléfono ya registrado';
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Genero>(
                      value: generoSelected,
                      decoration: const InputDecoration(labelText: 'Género'),
                      items: Genero.values.map((g) => DropdownMenuItem(value: g, child: Text(g.name))).toList(),
                      onChanged: (v) => setModalState(() => generoSelected = v),
                      validator: (v) => v == null ? 'Selecciona género' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: correoCtrl,
                      decoration: const InputDecoration(labelText: 'Correo (opcional)'),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar'))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                final nuevo = Cliente(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                  nombre: nombreCtrl.text.trim(),
                                  telefono: telCtrl.text.trim(),
                                  genero: generoSelected!,
                                  correo: correoCtrl.text.trim().isEmpty ? null : correoCtrl.text.trim(),
                                  fechaRegistro: DateTime.now(),
                                );
                                appState.addCliente(nuevo);
                                vm.setCliente(nuevo);
                                Navigator.pop(ctx);
                              }
                            },
                            child: const Text('Guardar'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SelectorClienteSheet extends StatelessWidget {
  final AppState appState;
  const _SelectorClienteSheet({required this.appState});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          const Text('Selecciona un cliente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: appState.clientes.length,
              itemBuilder: (context, index) {
                final c = appState.clientes[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(c.nombre[0])),
                  title: Text(c.nombre),
                  subtitle: Text(c.telefono),
                  onTap: () => Navigator.pop(context, c),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}