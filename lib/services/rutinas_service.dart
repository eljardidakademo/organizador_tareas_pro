import '../models/dia.dart';
import '../models/rutina.dart';
import '../models/tarea.dart';
import 'planificador.dart';

class ServicioRutinas {
  /// Añade al final de [dia] las tareas de todas las rutinas activas cuyo
  /// conjunto de días de la semana incluya el día de la semana de [dia].
  /// Devuelve cuántas tareas se añadieron.
  static int aplicarRutinasCoincidentes(Dia dia, List<Rutina> rutinas) {
    final rutinasCoincidentes =
        rutinas.where((r) => r.activa && r.diasSemana.contains(dia.fecha.weekday));

    int anadidas = 0;
    for (final rutina in rutinasCoincidentes) {
      for (final plantilla in rutina.tareas) {
        dia.tareas.add(
          Tarea(
            id: '${DateTime.now().millisecondsSinceEpoch}_${dia.tareas.length}_$anadidas',
            nombre: plantilla.nombre,
            horaInicio: dia.horaInicio,
            duracionMinutos: plantilla.duracionMinutos,
            prioridadAlta: plantilla.prioridadAlta,
            categoriaId: plantilla.categoriaId,
            orden: dia.tareas.length,
          ),
        );
        anadidas++;
      }
    }
    if (anadidas > 0) {
      dia.tareas = Planificador.recalcular(tareas: dia.tareas, horaInicioDia: dia.horaInicio);
    }
    return anadidas;
  }
}
