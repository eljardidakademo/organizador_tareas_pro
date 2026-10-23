import 'tarea.dart';
import '../i18n/traducciones.dart';

class Dia {
  String id;
  DateTime fecha; // solo importa año/mes/día
  DateTime horaInicio;
  DateTime? horaFinDia; // null = sin aviso de huecos libres para este día
  List<Tarea> tareas;

  Dia({
    required this.id,
    required this.fecha,
    required this.horaInicio,
    this.horaFinDia,
    required this.tareas,
  });

  int get tareasCompletadas => tareas.where((t) => t.completada).length;

  double get progreso =>
      tareas.isEmpty ? 0 : tareasCompletadas / tareas.length;

  bool esMismaFecha(DateTime otra) =>
      fecha.year == otra.year && fecha.month == otra.month && fecha.day == otra.day;

  /// Minutos libres entre el final de la última tarea (o la hora de inicio,
  /// si no hay tareas) y la hora de fin de jornada. Negativo si te pasas.
  /// Null si este día no tiene activado el aviso de huecos libres.
  int? get minutosLibres {
    if (horaFinDia == null) return null;
    final finOcupado = tareas.isEmpty
        ? horaInicio
        : tareas.last.horaInicio.add(Duration(minutes: tareas.last.duracionMinutos));
    return horaFinDia!.difference(finOcupado).inMinutes;
  }

  String fechaFormateada(Idioma idioma) {
    final diaSemana = Traducciones.diaSemana(idioma, fecha.weekday);
    final nombreMes = Traducciones.mes(idioma, fecha.month);
    return '$diaSemana, ${fecha.day} $nombreMes';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'fecha': fecha.toIso8601String(),
        'horaInicio': horaInicio.toIso8601String(),
        'horaFinDia': horaFinDia?.toIso8601String(),
        'tareas': tareas.map((t) => t.toMap()).toList(),
      };

  factory Dia.fromMap(Map<String, dynamic> map) => Dia(
        id: map['id'],
        fecha: DateTime.parse(map['fecha']),
        horaInicio: DateTime.parse(map['horaInicio']),
        horaFinDia: map['horaFinDia'] != null ? DateTime.parse(map['horaFinDia']) : null,
        tareas: (map['tareas'] as List).map((t) => Tarea.fromMap(t)).toList(),
      );
}
