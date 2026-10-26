import 'package:flutter/material.dart';
import '../models/cliente.dart';
import '../models/estilista.dart';
import '../models/servicio.dart';
import '../models/turno.dart';
import '../models/enums.dart';
import '../data/mock_data.dart';

class AppState extends ChangeNotifier {
  final List<Servicio> servicios = MockData.servicios;
  final List<Estilista> estilistas = MockData.estilistas;
  final List<Cliente> clientes = List.from(MockData.clientes);
  final List<Turno> turnos = List.from(MockData.turnos);

  int _themeModeIndex = 0;
  int get themeModeIndex => _themeModeIndex;
  ThemeMode get themeMode => ThemeMode.values[_themeModeIndex];

  void setThemeMode(int index) {
    _themeModeIndex = index;
    notifyListeners();
  }

  void addCliente(Cliente c) {
    clientes.add(c);
    notifyListeners();
  }

  void updateCliente(Cliente c) {
    final index = clientes.indexWhere((e) => e.id == c.id);
    if (index != -1) {
      clientes[index] = c;
      notifyListeners();
    }
  }

  void deleteCliente(String id) {
    clientes.removeWhere((c) => c.id == id);
    turnos.removeWhere((t) => t.clienteId == id);
    notifyListeners();
  }

  void addTurno(Turno t) {
    turnos.add(t);
    notifyListeners();
  }

  void updateTurno(Turno t) {
    final index = turnos.indexWhere((e) => e.id == t.id);
    if (index != -1) {
      turnos[index] = t;
      notifyListeners();
    }
  }

  bool clienteTieneTurnosProgramados(String clienteId) {
    return turnos.any((t) => t.clienteId == clienteId && t.estado == EstadoTurno.programado);
  }

  int calcularDuracion(List<String> serviciosIds) {
    int total = 0;
    for (var id in serviciosIds) {
      final s = servicios.firstWhere((e) => e.id == id);
      total += s.duracionMinutos;
    }
    return total;
  }

  double calcularPrecio(List<String> serviciosIds) {
    double total = 0;
    for (var id in serviciosIds) {
      final s = servicios.firstWhere((e) => e.id == id);
      total += s.precio;
    }
    return total;
  }

  DateTime calcularHoraFin(DateTime inicio, List<String> serviciosIds) {
    final duracion = calcularDuracion(serviciosIds);
    return inicio.add(Duration(minutes: duracion));
  }

  bool haySolapeEstilista(String estilistaId, DateTime inicio, DateTime fin, {String? turnoIdExcluir}) {
    for (final t in turnos) {
      if (t.estado != EstadoTurno.programado) continue;
      if (t.estilistaId != estilistaId) continue;
      if (turnoIdExcluir != null && t.id == turnoIdExcluir) continue;

      final tFin = calcularHoraFin(t.fechaHoraInicio, t.serviciosIds);
      if (inicio.isBefore(tFin) && fin.isAfter(t.fechaHoraInicio)) return true;
    }
    return false;
  }

  bool haySolapeCliente(String clienteId, DateTime inicio, DateTime fin, {String? turnoIdExcluir}) {
    for (final t in turnos) {
      if (t.estado != EstadoTurno.programado) continue;
      if (t.clienteId != clienteId) continue;
      if (turnoIdExcluir != null && t.id == turnoIdExcluir) continue;

      final tFin = calcularHoraFin(t.fechaHoraInicio, t.serviciosIds);
      if (inicio.isBefore(tFin) && fin.isAfter(t.fechaHoraInicio)) return true;
    }
    return false;
  }

  String? validarHorarioGeneral(DateTime inicio, DateTime fin) {
    final now = DateTime.now();
    if (inicio.isBefore(now)) return 'No se pueden agendar turnos en el pasado.';
    if (inicio.weekday == DateTime.sunday) return 'El salón está cerrado los domingos.';
    
    final horaCierre = DateTime(inicio.year, inicio.month, inicio.day, 19, 0);
    if (fin.isAfter(horaCierre)) return 'El turno debe terminar a las 19:00 como máximo.';

    final horaApertura = DateTime(inicio.year, inicio.month, inicio.day, 9, 0);
    if (inicio.isBefore(horaApertura)) return 'El salón abre a las 9:00.';

    return null;
  }
}