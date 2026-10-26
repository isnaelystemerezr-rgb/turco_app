import 'enums.dart';

class Cliente {
  final String id;
  final String nombre;
  final String telefono;
  final Genero genero;
  final String? correo;
  final DateTime fechaRegistro;

  const Cliente({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.genero,
    this.correo,
    required this.fechaRegistro,
  });
}