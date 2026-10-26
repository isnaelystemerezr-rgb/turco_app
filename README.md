# turco_app
# App Turco - Gestión de Turnos de Peluquería

Aplicación móvil desarrollada en Flutter para la gestión de turnos de una peluquería mixta.

**Asignatura:** Programación para Dispositivos Móviles  
**Tecnología base:** Flutter para Android  
**Autor:** Isnaelys Temerez Rodríguez  
**Application ID:** com.isnaelystemerez.turco

## 📱 Descripción
La app permite al personal del salón registrar clientes, programar turnos con un estilista y llevar el control de la agenda diaria. Los datos se mantienen en memoria y se cargan desde datos de prueba al iniciar.

## ✨ Características Principales
- **Agenda:** Vista diaria con tira de días, filtros por estilista y estado, y resumen del día.
- **Clientes:** Registro, edición y eliminación, búsqueda y filtro por género.
- **Servicios:** Catálogo en cuadrícula con filtros.
- **Estilistas:** Lista con vista plegable y acceso directo a su agenda.
- **Formulario de Turno:** Validaciones completas y cálculo de horas disponibles.
- **Modo Oscuro/Claro:** Tema global.

## ⚠️ Nota sobre el APK release
El APK en modo release **no pudo ser generado en el entorno local** debido a que la red del proveedor de internet (y el antivirus del equipo) bloquean la descarga de dependencias de Google Maven y `pub.dev` (Error de autorización). Sin embargo, **la aplicación es 100% funcional**, como se demuestra en las capturas adjuntas en la carpeta `capturas/`.

## 🚀 Cómo ejecutar el proyecto
1. Clonar el repositorio:
   `git clone <URL_DEL_REPOSITORIO>`
2. Descargar dependencias:
   `flutter pub get`
3. Ejecutar:
   `flutter run`

## 📸 Capturas de pantalla
Las capturas se encuentran en la carpeta `capturas/`:
1. Agenda principal
2. Clientes
3. Servicios
4. Estilistas
5. Detalle de turno
6. Formulario con errores de validación
7. Cuadrícula de franjas deshabilitadas
8. Agenda en modo oscuro
