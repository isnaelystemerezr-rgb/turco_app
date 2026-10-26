import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../models/turno.dart';
import 'app_state.dart';

class AgendaViewModel extends ChangeNotifier {
  final AppState appState;

  AgendaViewModel({required this.appState}) {
    _fechaSeleccionada = DateTime.now();
  }

  DateTime _fechaSeleccionada = DateTime.now();
  DateTime get fechaSeleccionada => _fechaSeleccionada;

  String? _estilistaFiltro; // null = Todos
  String? get estilistaFiltro => _estilistaFiltro;

  EstadoTurno? _estadoFiltro; // null = Todos
  EstadoTurno? get estadoFiltro => _estadoFiltro;

  void setFecha(DateTime fecha) {
    _fechaSeleccionada = fecha;
    notifyListeners();
  }

  void setEstilistaFiltro(String? id) {
    _estilistaFiltro = id;
    notifyListeners();
  }

  void setEstadoFiltro(EstadoTurno? estado) {
    _estadoFiltro = estado;
    notifyListeners();
  }

  // --- LISTA DE DÍAS DE LA SEMANA ---
  List<DateTime> get diasDeLaSemana {
    // Encontrar el lunes de la semana de la fecha seleccionada
    final lunes = _fechaSeleccionada.subtract(Duration(days: _fechaSeleccionada.weekday - 1));
    return List.generate(7, (index) => lunes.add(Duration(days: index)));
  }

  void semanaAnterior() {
    _fechaSeleccionada = _fechaSeleccionada.subtract(const Duration(days: 7));
    notifyListeners();
  }

  void semanaSiguiente() {
    _fechaSeleccionada = _fechaSeleccionada.add(const Duration(days: 7));
    notifyListeners();
  }

  // --- TURNOS DEL DÍA FILTRADOS ---
  List<Turno> get turnosDelDia {
    final inicioDia = DateTime(_fechaSeleccionada.year, _fechaSeleccionada.month, _fechaSeleccionada.day);
    final finDia = inicioDia.add(const Duration(days: 1));

    var lista = appState.turnos.where((t) {
      final matchFecha = t.fechaHoraInicio.isAfter(inicioDia.subtract(const Duration(seconds: 1))) && 
                         t.fechaHoraInicio.isBefore(finDia);
      final matchEstilista = _estilistaFiltro == null || t.estilistaId == _estilistaFiltro;
      final matchEstado = _estadoFiltro == null || t.estado == _estadoFiltro;
      return matchFecha && matchEstilista && matchEstado;
    }).toList();

    lista.sort((a, b) => a.fechaHoraInicio.compareTo(b.fechaHoraInicio));
    return lista;
  }

  // --- RESUMEN DEL DÍA (sin filtros de estado/estilista para el resumen general) ---
  int get turnosProgramados {
    return appState.turnos.where((t) {
      final inicioDia = DateTime(_fechaSeleccionada.year, _fechaSeleccionada.month, _fechaSeleccionada.day);
      final finDia = inicioDia.add(const Duration(days: 1));
      return t.fechaHoraInicio.isAfter(inicioDia.subtract(const Duration(seconds: 1))) && 
             t.fechaHoraInicio.isBefore(finDia) && 
             t.estado == EstadoTurno.programado;
    }).length;
  }

  int get turnosCompletados {
    return appState.turnos.where((t) {
      final inicioDia = DateTime(_fechaSeleccionada.year, _fechaSeleccionada.month, _fechaSeleccionada.day);
      final finDia = inicioDia.add(const Duration(days: 1));
      return t.fechaHoraInicio.isAfter(inicioDia.subtract(const Duration(seconds: 1))) && 
             t.fechaHoraInicio.isBefore(finDia) && 
             t.estado == EstadoTurno.completado;
    }).length;
  }

  double get ingresoEstimado {
    return appState.turnos.where((t) {
      final inicioDia = DateTime(_fechaSeleccionada.year, _fechaSeleccionada.month, _fechaSeleccionada.day);
      final finDia = inicioDia.add(const Duration(days: 1));
      return t.fechaHoraInicio.isAfter(inicioDia.subtract(const Duration(seconds: 1))) && 
             t.fechaHoraInicio.isBefore(finDia) && 
             (t.estado == EstadoTurno.programado || t.estado == EstadoTurno.completado);
    }).fold(0.0, (sum, t) => sum + appState.calcularPrecio(t.serviciosIds));
  }
}