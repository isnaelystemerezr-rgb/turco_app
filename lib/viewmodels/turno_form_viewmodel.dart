import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../models/cliente.dart';
import '../models/estilista.dart';
import '../models/servicio.dart';
import '../models/turno.dart';
import 'app_state.dart';

class TurnoFormViewModel extends ChangeNotifier {
  final AppState appState;
  final Turno? turnoOriginal; // Si es null, es un turno nuevo. Si tiene valor, estamos editando.

  TurnoFormViewModel({required this.appState, this.turnoOriginal}) {
    if (turnoOriginal != null) {
      // Cargar datos si estamos editando
      _clienteSeleccionado = appState.clientes.firstWhere((c) => c.id == turnoOriginal!.clienteId);
      _serviciosSeleccionados = appState.servicios.where((s) => turnoOriginal!.serviciosIds.contains(s.id)).toSet();
      _estilistaSeleccionado = appState.estilistas.firstWhere((e) => e.id == turnoOriginal!.estilistaId);
      _fechaSeleccionada = turnoOriginal!.fechaHoraInicio;
      _horaSeleccionada = TimeOfDay.fromDateTime(turnoOriginal!.fechaHoraInicio);
      _notasController.text = turnoOriginal!.notas ?? '';
    }
  }

  // --- ESTADO DEL FORMULARIO ---
  Cliente? _clienteSeleccionado;
  Cliente? get clienteSeleccionado => _clienteSeleccionado;

  Set<Servicio> _serviciosSeleccionados = {};
  Set<Servicio> get serviciosSeleccionados => _serviciosSeleccionados;

  Estilista? _estilistaSeleccionado;
  Estilista? get estilistaSeleccionado => _estilistaSeleccionado;

  DateTime? _fechaSeleccionada;
  DateTime? get fechaSeleccionada => _fechaSeleccionada;

  TimeOfDay? _horaSeleccionada;
  TimeOfDay? get horaSeleccionada => _horaSeleccionada;

  final TextEditingController _notasController = TextEditingController();
  TextEditingController get notasController => _notasController;

  Publico? _filtroPublico;
  Publico? get filtroPublico => _filtroPublico;

  // Errores de validación
  String? _errorCliente;
  String? _errorServicios;
  String? _errorEstilista;
  String? _errorFecha;
  String? _errorHora;

  String? get errorCliente => _errorCliente;
  String? get errorServicios => _errorServicios;
  String? get errorEstilista => _errorEstilista;
  String? get errorFecha => _errorFecha;
  String? get errorHora => _errorHora;

  // --- MÉTODOS DE SELECCIÓN ---

  void setCliente(Cliente? c) {
    _clienteSeleccionado = c;
    _errorCliente = null;
    // Regla del PDF: Al elegir cliente, el filtro de público se ajusta a su género por defecto
    if (c != null) {
      _filtroPublico = c.genero == Genero.mujer ? Publico.mujeres : Publico.hombres;
      // Si hay servicios seleccionados que no son para su género, los limpiamos
      _serviciosSeleccionados.removeWhere((s) => s.publico != Publico.unisex && s.publico != _filtroPublico);
    }
    _validarEstilista(); // Recalcular estilistas válidos
    notifyListeners();
  }

  void setFiltroPublico(Publico? p) {
    _filtroPublico = p;
    notifyListeners();
  }

  void toggleServicio(Servicio s) {
    if (_serviciosSeleccionados.contains(s)) {
      _serviciosSeleccionados.remove(s);
    } else {
      _serviciosSeleccionados.add(s);
    }
    _errorServicios = null;
    _validarEstilista(); // El estilista puede dejar de ser válido si cambian los servicios
    _horaSeleccionada = null; // Las horas se recalculan
    notifyListeners();
  }

  void setEstilista(Estilista? e) {
    _estilistaSeleccionado = e;
    _errorEstilista = null;
    _horaSeleccionada = null; // Las horas se recalculan
    notifyListeners();
  }

  void setFecha(DateTime? d) {
    _fechaSeleccionada = d;
    _errorFecha = null;
    _horaSeleccionada = null; // Las horas se recalculan
    notifyListeners();
  }

  void setHora(TimeOfDay? h) {
    _horaSeleccionada = h;
    _errorHora = null;
    notifyListeners();
  }

  // --- LÓGICA DE ESTILISTAS VÁLIDOS ---

  /// Filtra los estilistas que realizan TODOS los servicios seleccionados
  List<Estilista> get estilistasDisponibles {
    if (_serviciosSeleccionados.isEmpty) return appState.estilistas;
    
    final idsServicios = _serviciosSeleccionados.map((s) => s.id).toList();
    return appState.estilistas.where((e) {
      return idsServicios.every((id) => e.serviciosIds.contains(id));
    }).toList();
  }

  void _validarEstilista() {
    if (_estilistaSeleccionado != null && !estilistasDisponibles.contains(_estilistaSeleccionado)) {
      _estilistaSeleccionado = null;
      _errorEstilista = 'El estilista anterior no realiza todos los servicios. Elige otro.';
    }
  }

  // --- LÓGICA DE HORAS DISPONIBLES (LA MÁS COMPLEJA) ---

  /// Devuelve una lista de TimeOfDay con las franjas de 30 min de 9:00 a 18:30
  List<TimeOfDay> get todasLasFranjas {
    final franjas = <TimeOfDay>[];
    for (int h = 9; h < 19; h++) {
      franjas.add(TimeOfDay(hour: h, minute: 0));
      franjas.add(TimeOfDay(hour: h, minute: 30));
    }
    return franjas;
  }

  /// Devuelve true si una franja está disponible
  bool esFranjaDisponible(TimeOfDay franja) {
    if (_fechaSeleccionada == null || _estilistaSeleccionado == null || _serviciosSeleccionados.isEmpty) {
      return false;
    }

    final inicio = DateTime(
      _fechaSeleccionada!.year,
      _fechaSeleccionada!.month,
      _fechaSeleccionada!.day,
      franja.hour,
      franja.minute,
    );

    // 1. Verificar reglas generales (pasado, domingo, cierre)
    final fin = appState.calcularHoraFin(inicio, _serviciosSeleccionados.map((s) => s.id).toList());
    if (appState.validarHorarioGeneral(inicio, fin) != null) return false;

    // 2. Verificar solape con estilista
    if (appState.haySolapeEstilista(_estilistaSeleccionado!.id, inicio, fin, turnoIdExcluir: turnoOriginal?.id)) {
      return false;
    }

    // 3. Verificar solape con cliente
    if (_clienteSeleccionado != null) {
      if (appState.haySolapeCliente(_clienteSeleccionado!.id, inicio, fin, turnoIdExcluir: turnoOriginal?.id)) {
        return false;
      }
    }

    return true;
  }

  // --- CÁLCULOS PARA EL RESUMEN ---

  int get duracionTotal => appState.calcularDuracion(_serviciosSeleccionados.map((s) => s.id).toList());
  
  double get precioTotal => appState.calcularPrecio(_serviciosSeleccionados.map((s) => s.id).toList());

  TimeOfDay? get horaFin {
    if (_horaSeleccionada == null) return null;
    final inicio = DateTime(2000, 1, 1, _horaSeleccionada!.hour, _horaSeleccionada!.minute);
    final fin = inicio.add(Duration(minutes: duracionTotal));
    return TimeOfDay.fromDateTime(fin);
  }

  // --- GUARDAR ---

  Turno? guardar() {
    // Validar todo
    _errorCliente = _clienteSeleccionado == null ? 'Selecciona un cliente' : null;
    _errorServicios = _serviciosSeleccionados.isEmpty ? 'Elige al menos un servicio' : null;
    _errorEstilista = _estilistaSeleccionado == null ? 'Selecciona un estilista' : null;
    _errorFecha = _fechaSeleccionada == null ? 'Elige una fecha válida (no domingos)' : null;
    _errorHora = _horaSeleccionada == null ? 'Elige una hora para el turno' : null;

    if (_errorCliente != null || _errorServicios != null || _errorEstilista != null || _errorFecha != null || _errorHora != null) {
      notifyListeners();
      return null;
    }

    // Crear el turno
    final inicio = DateTime(
      _fechaSeleccionada!.year,
      _fechaSeleccionada!.month,
      _fechaSeleccionada!.day,
      _horaSeleccionada!.hour,
      _horaSeleccionada!.minute,
    );

    final nuevoTurno = Turno(
      id: turnoOriginal?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      clienteId: _clienteSeleccionado!.id,
      estilistaId: _estilistaSeleccionado!.id,
      serviciosIds: _serviciosSeleccionados.map((s) => s.id).toList(),
      fechaHoraInicio: inicio,
      notas: _notasController.text.trim().isEmpty ? null : _notasController.text.trim(),
      estado: turnoOriginal?.estado ?? EstadoTurno.programado,
      fechaCreacion: turnoOriginal?.fechaCreacion ?? DateTime.now(),
      fechaModificacion: DateTime.now(),
    );

    return nuevoTurno;
  }

  @override
  void dispose() {
    _notasController.dispose();
    super.dispose();
  }
}