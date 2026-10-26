import 'package:flutter/material.dart';
import '../../models/enums.dart';
import '../../models/servicio.dart';
import '../../viewmodels/app_state.dart';
import '../../app_provider.dart'; 
import 'package:go_router/go_router.dart';

class ServiciosPage extends StatefulWidget {
  const ServiciosPage({super.key});

  @override
  State<ServiciosPage> createState() => _ServiciosPageState();
}

class _ServiciosPageState extends State<ServiciosPage> {
  CategoriaServicio? _categoriaSeleccionada;
  Publico? _publicoSeleccionado;

  @override
  Widget build(BuildContext context) {
    final appState = TurcoAppProvider.of(context);

    return ListenableBuilder(
      listenable: appState,
      builder: (context, child) {
        // Filtrar servicios
        final serviciosFiltrados = appState.servicios.where((s) {
          final matchCat = _categoriaSeleccionada == null || s.categoria == _categoriaSeleccionada;
          final matchPub = _publicoSeleccionado == null || s.publico == _publicoSeleccionado;
          return matchCat && matchPub;
        }).toList();

            return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Servicios', style: Theme.of(context).textTheme.headlineSmall),
            Text(
              'Toca un servicio para reservar',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
        actions: [
          // Botón para cambiar el tema (RF1 y Criterios de aceptación)
          PopupMenuButton<int>(
            icon: const Icon(Icons.lightbulb_outline),
            tooltip: 'Cambiar tema',
            onSelected: (int index) {
              appState.setThemeMode(index);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              const PopupMenuItem<int>(
                value: 0,
                child: Row(
                  children: [
                    Icon(Icons.settings_system_daydream),
                    SizedBox(width: 8),
                    Text('Sistema'),
                  ],
                ),
              ),
              const PopupMenuItem<int>(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.light_mode),
                    SizedBox(width: 8),
                    Text('Claro'),
                  ],
                ),
              ),
              const PopupMenuItem<int>(
                value: 2,
                child: Row(
                  children: [
                    Icon(Icons.dark_mode),
                    SizedBox(width: 8),
                    Text('Oscuro'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16), // Espacio para no pegar los chips al AppBar
            
            // Filtro por categoría (Chips horizontales)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildChipCategoria(null, 'Todas'),
                  ...CategoriaServicio.values.map((cat) => _buildChipCategoria(cat, cat.name.toUpperCase())),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Filtro por público (SegmentedButton)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SegmentedButton<Publico?>(
                segments: const [
                  ButtonSegment(value: null, label: Text('Todos')),
                  ButtonSegment(value: Publico.mujeres, label: Text('Mujeres')),
                  ButtonSegment(value: Publico.hombres, label: Text('Hombres')),
                ],
                selected: {_publicoSeleccionado},
                onSelectionChanged: (Set<Publico?> newSelection) {
                  setState(() => _publicoSeleccionado = newSelection.first);
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Grid de Servicios
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 2;
                  if (constraints.maxWidth > 840) crossAxisCount = 4;
                  else if (constraints.maxWidth >= 600) crossAxisCount = 3;

                  if (serviciosFiltrados.isEmpty) {
                    return const Center(child: Text('No hay servicios para estos filtros'));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: serviciosFiltrados.length,
                    itemBuilder: (context, index) {
                      final servicio = serviciosFiltrados[index];
                      return _buildTarjetaServicio(context, servicio);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

      },
    );
  }

  Widget _buildChipCategoria(CategoriaServicio? cat, String label) {
    final isSelected = _categoriaSeleccionada == cat;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) => setState(() => _categoriaSeleccionada = cat),
      ),
    );
  }

   Widget _buildTarjetaServicio(BuildContext context, Servicio servicio) {
    final colors = Theme.of(context).colorScheme;

    // Mapeo de iconos según categoría
    IconData icono;
    switch (servicio.categoria) {
      case CategoriaServicio.corte: icono = Icons.content_cut;
      case CategoriaServicio.color: icono = Icons.palette_outlined;
      case CategoriaServicio.barba: icono = Icons.face_retouching_natural;
      case CategoriaServicio.peinado: icono = Icons.auto_awesome;
      case CategoriaServicio.tratamiento: icono = Icons.water_drop_outlined;
    }

    return Card(
      clipBehavior: Clip.antiAlias, // Para que el InkWell respete el borde redondeado
      child: InkWell(
        onTap: () {
          // Navegamos al formulario de turno pasando el servicio como extra
          // NOTA: Esta ruta la crearemos en el Paso 6. Por ahora solo navega a un placeholder.
          context.push('/turno/nuevo', extra: servicio);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen / Icono superior
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icono, size: 48, color: colors.primary),
                ),
              ),
              const SizedBox(height: 12),
              // Nombre
              Text(servicio.nombre, style: Theme.of(context).textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              // Duración y Precio
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: colors.outline),
                      const SizedBox(width: 4),
                      Text('${servicio.duracionMinutos} min', style: TextStyle(fontSize: 12, color: colors.outline)),
                    ],
                  ),
                  Text('\$${servicio.precio.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, color: colors.primary)),
                ],
              ),
              const SizedBox(height: 8),
              // Público
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  servicio.publico.name[0].toUpperCase() + servicio.publico.name.substring(1),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colors.onSecondaryContainer),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
