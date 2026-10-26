import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/cliente.dart';
import '../../models/enums.dart';
import '../../viewmodels/app_state.dart';
import '../../viewmodels/clientes_viewmodel.dart';
import '../../app_provider.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  late ClientesViewModel vm;
  final TextEditingController _searchController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appState = TurcoAppProvider.of(context);
    vm = ClientesViewModel(appState: appState);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = TurcoAppProvider.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([appState, vm]),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Clientes'),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add_alt_1),
                tooltip: 'Nuevo cliente',
                onPressed: () => _abrirFormularioCliente(context, appState),
              ),
            ],
          ),
          body: Column(
            children: [
              // --- BUSCADOR ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: vm.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o teléfono',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty 
                      ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); vm.setSearchQuery(''); }) 
                      : null,
                  ),
                ),
              ),

              // --- FILTRO GÉNERO ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SegmentedButton<Genero?>(
                  segments: const [
                    ButtonSegment(value: null, label: Text('Todos')),
                    ButtonSegment(value: Genero.mujer, label: Text('Mujeres')),
                    ButtonSegment(value: Genero.hombre, label: Text('Hombres')),
                  ],
                  selected: {vm.filtroGenero},
                  onSelectionChanged: (val) => vm.setFiltroGenero(val.first),
                ),
              ),

              const SizedBox(height: 16),

              // --- CONTADOR ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${vm.totalClientes} clientes · ${vm.totalMujeres} mujeres · ${vm.totalHombres} hombres',
                    style: TextStyle(color: Theme.of(context).colorScheme.outline),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // --- LISTA ---
              Expanded(
                child: vm.clientesFiltrados.isEmpty
                    ? _buildEstadoVacio(context)
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: vm.clientesFiltrados.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final c = vm.clientesFiltrados[index];
                          final turnosCount = vm.getTurnosCount(c.id);
                          
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: c.genero == Genero.mujer ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.tertiaryContainer,
                              child: Text(c.nombre[0], style: TextStyle(fontWeight: FontWeight.bold, color: c.genero == Genero.mujer ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.tertiary)),
                            ),
                            title: Text(c.nombre, style: const TextStyle(fontWeight: FontWeight.w500)),
                            subtitle: Text('${c.telefono} · ${c.genero.name[0].toUpperCase() + c.genero.name.substring(1)}'),
                            trailing: Text('$turnosCount turnos', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline)),
                            onTap: () => _abrirDetalleCliente(context, appState, c),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _abrirFormularioCliente(context, appState),
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Nuevo cliente'),
          ),
        );
      },
    );
  }

  Widget _buildEstadoVacio(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text('No se encontraron clientes', style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }

  // --- HOJA 1: DETALLE DEL CLIENTE ---
  void _abrirDetalleCliente(BuildContext context, AppState appState, Cliente cliente) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final turnosCliente = appState.turnos.where((t) => t.clienteId == cliente.id).toList();
        final tieneProgramados = appState.clienteTieneTurnosProgramados(cliente.id);

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(radius: 30, child: Text(cliente.nombre[0], style: const TextStyle(fontSize: 24))),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cliente.nombre, style: Theme.of(context).textTheme.titleLarge),
                            Row(children: [const Icon(Icons.phone, size: 14), const SizedBox(width: 4), Text(cliente.telefono)]),
                            if (cliente.correo != null) Row(children: [const Icon(Icons.email, size: 14), const SizedBox(width: 4), Text(cliente.correo!)]),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Historial de turnos · ${turnosCliente.length}', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (turnosCliente.isEmpty)
                    const Text('Este cliente no tiene turnos aún.')
                  else
                    ...turnosCliente.map((t) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.calendar_today, size: 16, color: Theme.of(context).colorScheme.outline),
                      title: Text('${t.fechaHoraInicio.day}/${t.fechaHoraInicio.month} · ${appState.servicios.firstWhere((s) => s.id == t.serviciosIds.first).nombre}'),
                      trailing: Text(t.estado.name, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary)),
                    )),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            context.push('/turno/nuevo', extra: cliente); // TODO: Pasar cliente
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Nuevo turno'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _abrirFormularioCliente(context, appState, cliente: cliente);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar'),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _intentarEliminar(context, appState, cliente, tieneProgramados),
                        icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                        style: IconButton.styleFrom(side: BorderSide(color: Theme.of(context).colorScheme.outline)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- HOJA 2: FORMULARIO CREAR/EDITAR ---
  void _abrirFormularioCliente(BuildContext context, AppState appState, {Cliente? cliente}) {
    final formKey = GlobalKey<FormState>();
    final nombreCtrl = TextEditingController(text: cliente?.nombre);
    final telCtrl = TextEditingController(text: cliente?.telefono);
    final correoCtrl = TextEditingController(text: cliente?.correo);
    Genero? generoSelected = cliente?.genero;

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
                    Text(cliente == null ? 'Nuevo cliente' : 'Editar cliente', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nombreCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: vm.validarNombre,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: telCtrl,
                      decoration: const InputDecoration(labelText: 'Teléfono'),
                      keyboardType: TextInputType.phone,
                      validator: (v) => vm.validarTelefono(v, idExcluir: cliente?.id),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Genero>(
                      value: generoSelected,
                      decoration: const InputDecoration(labelText: 'Género'),
                      items: Genero.values.map((g) => DropdownMenuItem(value: g, child: Text(g.name[0].toUpperCase() + g.name.substring(1)))).toList(),
                      onChanged: (v) => setModalState(() => generoSelected = v),
                      validator: (v) => v == null ? 'Selecciona un género' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: correoCtrl,
                      decoration: const InputDecoration(labelText: 'Correo (opcional)'),
                      validator: vm.validarCorreo,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                final nuevo = Cliente(
                                  id: cliente?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                                  nombre: nombreCtrl.text.trim(),
                                  telefono: telCtrl.text.trim(),
                                  genero: generoSelected!,
                                  correo: correoCtrl.text.trim().isEmpty ? null : correoCtrl.text.trim(),
                                  fechaRegistro: cliente?.fechaRegistro ?? DateTime.now(),
                                );
                                if (cliente == null) {
                                  appState.addCliente(nuevo);
                                } else {
                                  appState.updateCliente(nuevo);
                                }
                                Navigator.pop(ctx);
                              }
                            },
                            child: const Text('Guardar cliente'),
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

  void _intentarEliminar(BuildContext context, AppState appState, Cliente cliente, bool tieneProgramados) {
    if (tieneProgramados) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se puede eliminar: ${cliente.nombre} tiene turnos programados.')),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('¿Eliminar a ${cliente.nombre}?'),
        content: const Text('Se eliminará el cliente junto con su historial de turnos completados y cancelados.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              appState.deleteCliente(cliente.id);
              Navigator.pop(ctx); // Cierra diálogo
              Navigator.pop(context); // Cierra bottom sheet
            }, 
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Eliminar')
          ),
        ],
      ),
    );
  }
}