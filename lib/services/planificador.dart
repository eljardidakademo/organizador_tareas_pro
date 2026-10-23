import '../models/tarea.dart';

/// Reordena y recalcula las horas de inicio de todas las tareas del día,
/// encadenándolas una tras otra a partir de [horaInicioDia]. Las tareas con
/// [Tarea.horaFija] = true son anclas inamovibles: conservan siempre su
/// horaInicio tal cual, y el resto de tareas se reencadena alrededor de ellas.
class Planificador {
  static List<Tarea> recalcular({
    required List<Tarea> tareas,
    required DateTime horaInicioDia,
  }) {
    // Aseguramos el orden por el campo `orden`
    tareas.sort((a, b) => a.orden.compareTo(b.orden));

    DateTime horaActual = horaInicioDia;
    for (var tarea in tareas) {
      if (tarea.horaFija) {
        // Inamovible: no se toca su horaInicio, pero el cursor salta a
        // partir de su hora + duración para las tareas siguientes.
        horaActual = tarea.horaInicio.add(Duration(minutes: tarea.duracionMinutos));
      } else {
        tarea.horaInicio = horaActual;
        horaActual = horaActual.add(Duration(minutes: tarea.duracionMinutos));
      }
    }
    return tareas;
  }

  /// Añade una tarea nueva y recalcula. Si la tarea es de hora fija, se
  /// inserta en la posición cronológica que le corresponde según su hora
  /// (para que la lista se siga mostrando en orden de horario); si no,
  /// se añade al final como siempre.
  static List<Tarea> anadirTarea({
    required List<Tarea> tareas,
    required Tarea nuevaTarea,
    required DateTime horaInicioDia,
  }) {
    if (nuevaTarea.horaFija) {
      int indice = tareas.indexWhere((t) => t.horaInicio.isAfter(nuevaTarea.horaInicio));
      if (indice == -1) indice = tareas.length;
      tareas.insert(indice, nuevaTarea);
    } else {
      tareas.add(nuevaTarea);
    }
    for (int i = 0; i < tareas.length; i++) {
      tareas[i].orden = i;
    }
    return recalcular(tareas: tareas, horaInicioDia: horaInicioDia);
  }

  /// Marca una tarea como retrasada (duración real distinta a la prevista)
  /// y recalcula en cascada el resto de tareas del día.
  static List<Tarea> ajustarDuracionReal({
    required List<Tarea> tareas,
    required String tareaId,
    required int nuevaDuracionMinutos,
    required DateTime horaInicioDia,
  }) {
    final tarea = tareas.firstWhere((t) => t.id == tareaId);
    tarea.duracionMinutos = nuevaDuracionMinutos;
    return recalcular(tareas: tareas, horaInicioDia: horaInicioDia);
  }

  /// Reordena manualmente (arrastrar y soltar) y recalcula.
  static List<Tarea> reordenar({
    required List<Tarea> tareas,
    required int desdeIndex,
    required int haciaIndex,
    required DateTime horaInicioDia,
  }) {
    tareas.sort((a, b) => a.orden.compareTo(b.orden));
    final tarea = tareas.removeAt(desdeIndex);
    tareas.insert(haciaIndex, tarea);
    for (int i = 0; i < tareas.length; i++) {
      tareas[i].orden = i;
    }
    return recalcular(tareas: tareas, horaInicioDia: horaInicioDia);
  }

  /// Recalcula las horas de las tareas PENDIENTES a partir del momento
  /// actual, dejando intactas las tareas ya completadas (conservan la hora
  /// que tenían prevista) y las de hora fija (siempre inamovibles). Se usa
  /// solo bajo demanda, con el botón "Reajustar horas" — el horario normal
  /// se mantiene siempre fijo, no se recalcula automáticamente al marcar
  /// tareas. [fechaDelDia] es la fecha del propio día (para que la hora
  /// ancla use esa fecha, no la de hoy, si se está viendo otro día).
  static List<Tarea> reajustarHorasPendientes({
    required List<Tarea> tareas,
    required DateTime fechaDelDia,
  }) {
    tareas.sort((a, b) => a.orden.compareTo(b.orden));

    final ahora = DateTime.now();
    DateTime ancla = DateTime(
      fechaDelDia.year,
      fechaDelDia.month,
      fechaDelDia.day,
      ahora.hour,
      ahora.minute,
    );

    for (final tarea in tareas) {
      if (tarea.horaFija) {
        // Inamovible pase lo que pase; las siguientes tareas continúan
        // encadenadas a partir de su hora + duración.
        ancla = tarea.horaInicio.add(Duration(minutes: tarea.duracionMinutos));
        continue;
      }
      if (tarea.completada) continue; // conserva su hora ya prevista
      tarea.horaInicio = ancla;
      ancla = ancla.add(Duration(minutes: tarea.duracionMinutos));
    }
    return tareas;
  }
}
