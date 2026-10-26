import 'package:flutter/material.dart';
import '../models/cliente.dart';
import '../models/enums.dart';
import 'app_state.dart';

class ClientesViewModel extends ChangeNotifier {
  final AppState appState;

  ClientesViewModel({required this.appState});

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  Genero? _filtroGenero;
  Genero? get filtroGenero => _filtroGenero;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFiltroGenero(Genero? genero) {
    _filtroGenero = genero;
    notifyListeners();
  }

  // Función para quitar acentos y pasar a minúsculas
  String _normalizar(String texto) {
    texto = texto.toLowerCase();
    const conAcentos = 'áéíóúüñ';
    const sinAcentos = 'aeiouun';
    for (int i = 0; i < conAcentos.length; i++) {
      texto = texto.replaceAll(conAcentos[i], sinAcentos[i]);
    }
    return texto;
  }

  List<Cliente> get clientesFiltrados {
    return appState.clientes.where((c) {
      final matchGenero = _filtroGenero == null || c.genero == _filtroGenero;
      
      final nombreNorm = _normalizar(c.nombre);
      final telefonoNorm = c.telefono;
      final queryNorm = _normalizar(_searchQuery);
      
      final matchSearch = queryNorm.isEmpty || nombreNorm.contains(queryNorm) || telefonoNorm.contains(queryNorm);
      
      return matchGenero && matchSearch;
    }).toList();
  }

  int get totalClientes => appState.clientes.length;
  int get totalMujeres => appState.clientes.where((c) => c.genero == Genero.mujer).length;
  int get totalHombres => appState.clientes.where((c) => c.genero == Genero.hombre).length;

  int getTurnosCount(String clienteId) {
    return appState.turnos.where((t) => t.clienteId == clienteId).length;
  }

  // --- VALIDACIONES PARA EL FORMULARIO ---
  String? validarNombre(String? value) {
    if (value == null || value.trim().length < 3 || value.trim().length > 60) {
      return 'Escribe entre 3 y 60 caracteres';
    }
    return null;
  }

  String? validarTelefono(String? value, {String? idExcluir}) {
    if (value == null || value.length != 8 || int.tryParse(value) == null) {
      return 'Debe tener exactamente 8 dígitos';
    }
    final existe = appState.clientes.any((c) => c.telefono == value && c.id != idExcluir);
    if (existe) return 'Este teléfono ya está registrado';
    return null;
  }

  String? validarCorreo(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Opcional
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) return 'Escribe un correo válido';
    return null;
  }
}