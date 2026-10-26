import '../models/enums.dart';
import '../models/servicio.dart';
import '../models/estilista.dart';
import '../models/cliente.dart';
import '../models/turno.dart';

class MockData {
  static final DateTime now = DateTime.now();
  
  // Función auxiliar para crear fechas relativas a hoy a las 09:00 AM
  static DateTime _date(int daysOffset, int hour, int minute) {
    return DateTime(now.year, now.month, now.day + daysOffset, hour, minute);
  }

  static final List<Servicio> servicios = [
    // CORTE (4)
    const Servicio(id: 's1', nombre: 'Corte caballero', categoria: CategoriaServicio.corte, duracionMinutos: 45, precio: 25.0, publico: Publico.hombres),
    const Servicio(id: 's2', nombre: 'Corte mujer', categoria: CategoriaServicio.corte, duracionMinutos: 60, precio: 30.0, publico: Publico.mujeres),
    const Servicio(id: 's3', nombre: 'Corte clásico', categoria: CategoriaServicio.corte, duracionMinutos: 45, precio: 20.0, publico: Publico.unisex),
    const Servicio(id: 's4', nombre: 'Corte niño', categoria: CategoriaServicio.corte, duracionMinutos: 30, precio: 15.0, publico: Publico.unisex),
    
    // COLOR (3)
    const Servicio(id: 's5', nombre: 'Color completo', categoria: CategoriaServicio.color, duracionMinutos: 120, precio: 70.0, publico: Publico.mujeres),
    const Servicio(id: 's6', nombre: 'Mechas', categoria: CategoriaServicio.color, duracionMinutos: 90, precio: 50.0, publico: Publico.mujeres),
    const Servicio(id: 's7', nombre: 'Tinte barba', categoria: CategoriaServicio.color, duracionMinutos: 30, precio: 20.0, publico: Publico.hombres),
    
    // BARBA (2)
    const Servicio(id: 's8', nombre: 'Barba', categoria: CategoriaServicio.barba, duracionMinutos: 45, precio: 20.0, publico: Publico.hombres),
    const Servicio(id: 's9', nombre: 'Afeitado', categoria: CategoriaServicio.barba, duracionMinutos: 30, precio: 15.0, publico: Publico.hombres),
    
    // PEINADO (2)
    const Servicio(id: 's10', nombre: 'Peinado evento', categoria: CategoriaServicio.peinado, duracionMinutos: 60, precio: 40.0, publico: Publico.mujeres),
    const Servicio(id: 's11', nombre: 'Peinado casual', categoria: CategoriaServicio.peinado, duracionMinutos: 30, precio: 25.0, publico: Publico.unisex),
    
    // TRATAMIENTO (2)
    const Servicio(id: 's12', nombre: 'Hidratación', categoria: CategoriaServicio.tratamiento, duracionMinutos: 45, precio: 28.0, publico: Publico.unisex),
    const Servicio(id: 's13', nombre: 'Keratin', categoria: CategoriaServicio.tratamiento, duracionMinutos: 90, precio: 60.0, publico: Publico.mujeres),
  ];

  static final List<Estilista> estilistas = [
    // Solo mujeres
    const Estilista(id: 'e1', nombre: 'Marta', rutaAvatar: 'assets/images/marta.png', serviciosIds: ['s2', 's5', 's6', 's10', 's11', 's12', 's13']),
    // Solo hombres
    const Estilista(id: 'e2', nombre: 'Pedro', rutaAvatar: 'assets/images/pedro.png', serviciosIds: ['s1', 's3', 's4', 's7', 's8', 's9', 's12']),
    // Ambos
    const Estilista(id: 'e3', nombre: 'Lucía', rutaAvatar: 'assets/images/lucia.png', serviciosIds: ['s2', 's3', 's4', 's5', 's6', 's10', 's11', 's12', 's13']),
    // Generalista
    const Estilista(id: 'e4', nombre: 'Raúl', rutaAvatar: 'assets/images/raul.png', serviciosIds: ['s1', 's2', 's3', 's4', 's8', 's9', 's11', 's12']),
    // Solo hombres
    const Estilista(id: 'e5', nombre: 'Sergio', rutaAvatar: 'assets/images/sergio.png', serviciosIds: ['s1', 's3', 's4', 's7', 's8', 's9']),
  ];

  static final List<Cliente> clientes = [
    Cliente(id: 'c1', nombre: 'Laura Gómez', telefono: '52111222', genero: Genero.mujer, correo: 'laura@mail.com', fechaRegistro: _date(-30, 9, 0)),
    Cliente(id: 'c2', nombre: 'Carlos Ruiz', telefono: '52345678', genero: Genero.hombre, correo: 'carlos@mail.com', fechaRegistro: _date(-25, 10, 0)),
    Cliente(id: 'c3', nombre: 'Ana Martín', telefono: '53220140', genero: Genero.mujer, fechaRegistro: _date(-20, 11, 0)),
    Cliente(id: 'c4', nombre: 'Diego Pérez', telefono: '55908771', genero: Genero.hombre, fechaRegistro: _date(-15, 12, 0)),
    Cliente(id: 'c5', nombre: 'Sofía Díaz', telefono: '54667310', genero: Genero.mujer, fechaRegistro: _date(-10, 13, 0)),
    Cliente(id: 'c6', nombre: 'Javier Soto', telefono: '52774009', genero: Genero.hombre, fechaRegistro: _date(-5, 14, 0)), // Sin turnos
    Cliente(id: 'c7', nombre: 'Marta Peña', telefono: '53441902', genero: Genero.mujer, fechaRegistro: _date(-2, 15, 0)),
    Cliente(id: 'c8', nombre: 'Luis Fernández', telefono: '58123456', genero: Genero.hombre, fechaRegistro: _date(-40, 9, 0)),
    Cliente(id: 'c9', nombre: 'Elena Rodríguez', telefono: '58987654', genero: Genero.mujer, fechaRegistro: _date(-35, 9, 0)),
    Cliente(id: 'c10', nombre: 'Miguel Ángel', telefono: '56123456', genero: Genero.hombre, fechaRegistro: _date(-50, 9, 0)),
  ];

  static final List<Turno> turnos = [
    // HOY (Día 0)
    Turno(id: 't1', clienteId: 'c1', estilistaId: 'e1', serviciosIds: ['s2'], fechaHoraInicio: _date(0, 9, 0), estado: EstadoTurno.completado, fechaCreacion: _date(-1, 9, 0), fechaModificacion: _date(0, 10, 0)),
    Turno(id: 't2', clienteId: 'c2', estilistaId: 'e2', serviciosIds: ['s1', 's8'], fechaHoraInicio: _date(0, 10, 0), estado: EstadoTurno.programado, fechaCreacion: _date(-1, 10, 0), fechaModificacion: _date(-1, 10, 0)),
    Turno(id: 't3', clienteId: 'c3', estilistaId: 'e1', serviciosIds: ['s5', 's10'], fechaHoraInicio: _date(0, 10, 30), estado: EstadoTurno.programado, notas: 'Prefiere la máquina en el número 2 a los lados.', fechaCreacion: _date(-1, 11, 0), fechaModificacion: _date(-1, 11, 0)),
    Turno(id: 't4', clienteId: 'c4', estilistaId: 'e2', serviciosIds: ['s9'], fechaHoraInicio: _date(0, 12, 0), estado: EstadoTurno.programado, fechaCreacion: _date(-1, 12, 0), fechaModificacion: _date(-1, 12, 0)),
    
    // MAÑANA (Día 1)
    Turno(id: 't5', clienteId: 'c5', estilistaId: 'e3', serviciosIds: ['s5', 's10'], fechaHoraInicio: _date(1, 9, 0), estado: EstadoTurno.programado, fechaCreacion: _date(-2, 9, 0), fechaModificacion: _date(-2, 9, 0)),
    Turno(id: 't6', clienteId: 'c7', estilistaId: 'e1', serviciosIds: ['s2', 's6'], fechaHoraInicio: _date(1, 11, 0), estado: EstadoTurno.programado, fechaCreacion: _date(-2, 10, 0), fechaModificacion: _date(-2, 10, 0)),
    Turno(id: 't7', clienteId: 'c8', estilistaId: 'e2', serviciosIds: ['s1'], fechaHoraInicio: _date(1, 15, 0), estado: EstadoTurno.programado, fechaCreacion: _date(-2, 11, 0), fechaModificacion: _date(-2, 11, 0)),

    // PASADO (Días negativos)
    Turno(id: 't8', clienteId: 'c1', estilistaId: 'e1', serviciosIds: ['s2'], fechaHoraInicio: _date(-2, 9, 0), estado: EstadoTurno.completado, fechaCreacion: _date(-3, 9, 0), fechaModificacion: _date(-2, 10, 0)),
    Turno(id: 't9', clienteId: 'c2', estilistaId: 'e2', serviciosIds: ['s8'], fechaHoraInicio: _date(-3, 10, 0), estado: EstadoTurno.cancelado, fechaCreacion: _date(-4, 9, 0), fechaModificacion: _date(-3, 9, 0)),
    Turno(id: 't10', clienteId: 'c3', estilistaId: 'e1', serviciosIds: ['s13'], fechaHoraInicio: _date(-5, 14, 0), estado: EstadoTurno.completado, notas: 'Alergia a algunos químicos. Usar productos hipoalergénicos. Llegó con el cabello muy dañado por lo que se aplicó una mascarilla extra antes del tratamiento principal. Se recomienda volver en un mes para evaluación. La clienta quedó muy satisfecha con el resultado y pidió cita para el próximo mes.', fechaCreacion: _date(-6, 9, 0), fechaModificacion: _date(-5, 16, 0)),
    Turno(id: 't11', clienteId: 'c4', estilistaId: 'e2', serviciosIds: ['s9'], fechaHoraInicio: _date(-7, 11, 0), estado: EstadoTurno.completado, fechaCreacion: _date(-8, 9, 0), fechaModificacion: _date(-7, 12, 0)),

    // FUTURO (Días positivos)
    Turno(id: 't12', clienteId: 'c5', estilistaId: 'e3', serviciosIds: ['s5', 's10', 's12'], fechaHoraInicio: _date(2, 10, 0), estado: EstadoTurno.programado, notas: 'Cliente frecuente.', fechaCreacion: _date(-1, 15, 0), fechaModificacion: _date(-1, 15, 0)), // 3 servicios
    Turno(id: 't13', clienteId: 'c7', estilistaId: 'e1', serviciosIds: ['s2'], fechaHoraInicio: _date(3, 16, 0), estado: EstadoTurno.programado, fechaCreacion: _date(-1, 16, 0), fechaModificacion: _date(-1, 16, 0)),
    Turno(id: 't14', clienteId: 'c8', estilistaId: 'e2', serviciosIds: ['s1', 's8'], fechaHoraInicio: _date(4, 17, 30), estado: EstadoTurno.programado, fechaCreacion: _date(-1, 17, 0), fechaModificacion: _date(-1, 17, 0)), // Termina 19:00
    Turno(id: 't15', clienteId: 'c9', estilistaId: 'e3', serviciosIds: ['s2', 's11'], fechaHoraInicio: _date(5, 9, 0), estado: EstadoTurno.programado, fechaCreacion: _date(-1, 18, 0), fechaModificacion: _date(-1, 18, 0)),
    Turno(id: 't16', clienteId: 'c10', estilistaId: 'e2', serviciosIds: ['s3', 's8'], fechaHoraInicio: _date(6, 11, 0), estado: EstadoTurno.programado, fechaCreacion: _date(-1, 19, 0), fechaModificacion: _date(-1, 19, 0)),
  ];
}