import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../views/agenda/agenda_page.dart';
import '../views/clientes/clientes_page.dart';
import '../views/servicios/servicios_page.dart';
import '../views/estilistas/estilistas_page.dart';
import '../views/turnos/turno_form/turno_form_page.dart';
import '../views/turnos/turno_detalle/turno_detalle_page.dart';
import '../viewmodels/app_state.dart';
import '../viewmodels/turno_form_viewmodel.dart';
import '../app_provider.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.calendar_today), label: 'Agenda'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Clientes'),
          NavigationDestination(icon: Icon(Icons.content_cut), label: 'Servicios'),
          NavigationDestination(icon: Icon(Icons.badge), label: 'Estilistas'),
        ],
      ),
    );
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/agenda',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/agenda',
              builder: (context, state) {
                final estilistaId = state.uri.queryParameters['estilista'];
                return AgendaPage(estilistaQueryParam: estilistaId);
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/clientes',
              builder: (context, state) => const ClientesPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/servicios',
              builder: (context, state) => const ServiciosPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/estilistas',
              builder: (context, state) => const EstilistasPage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/turno/nuevo',
      builder: (context, state) {
        return Builder(
          builder: (context) {
            final appState = TurcoAppProvider.of(context);
            return TurnoFormPage(
              viewModel: TurnoFormViewModel(appState: appState),
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/turno/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return TurnoDetallePage(turnoId: id);
      },
    ),
    GoRoute(
      path: '/turno/:id/editar',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return Builder(
          builder: (context) {
            final appState = TurcoAppProvider.of(context);
            final turno = appState.turnos.firstWhere((t) => t.id == id);
            return TurnoFormPage(
              viewModel: TurnoFormViewModel(appState: appState, turnoOriginal: turno),
            );
          },
        );
      },
    ),
  ],
);