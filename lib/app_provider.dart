import 'package:flutter/material.dart';
import 'viewmodels/app_state.dart'; 

class TurcoAppProvider extends InheritedNotifier<AppState> {
  const TurcoAppProvider({
    super.key,
    required AppState notifier,
    required super.child,
  }) : super(notifier: notifier);

  static AppState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TurcoAppProvider>()!.notifier!;
  }
}