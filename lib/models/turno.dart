import 'enums.dart';

class Turno {
  final String id;
  final String clienteId;
  final String estilistaId;
  final List<String> serviciosIds;
  final DateTime fechaHoraInicio;
  final String? notas;
  final EstadoTurno estado;
  final DateTime fechaCreacion;
  final DateTime fechaModificacion;

  const Turno({
    required this.id,
    required this.clienteId,
    required this.estilistaId,
    required this.serviciosIds,
    required this.fechaHoraInicio,
    this.notas,
    required this.estado,
    required this.fechaCreacion,
    required this.fechaModificacion,
  });
    Turno copyWith({
    EstadoTurno? estado,
    DateTime? fechaModificacion,
  }) {
    return Turno(
      id: this.id,
      clienteId: this.clienteId,
      estilistaId: this.estilistaId,
      serviciosIds: this.serviciosIds,
      fechaHoraInicio: this.fechaHoraInicio,
      notas: this.notas,
      estado: estado ?? this.estado,
      fechaCreacion: this.fechaCreacion,
      fechaModificacion: fechaModificacion ?? DateTime.now(),
    );
  }
}