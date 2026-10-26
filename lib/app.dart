import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'viewmodels/app_state.dart';
import 'router/app_router.dart';
import 'app_provider.dart'; // <-- Importamos el nuevo archivo en vez de main.dart

class TurcoApp extends StatelessWidget {
  const TurcoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = TurcoAppProvider.of(context);

    return ListenableBuilder(
      listenable: appState,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Turco',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: appState.themeMode,
          routerConfig: appRouter,
        );
      },
    );
  }
}