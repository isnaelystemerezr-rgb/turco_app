import 'package:flutter/material.dart';
import 'app.dart';
import 'app_provider.dart'; 
import 'viewmodels/app_state.dart';

void main() {
  runApp(
    TurcoAppProvider(
      notifier: AppState(),
      child: const TurcoApp(),
    ),
  );
}