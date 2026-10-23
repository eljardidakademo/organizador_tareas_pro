/// Una tarea plantilla dentro de una rutina (no es una Tarea real todavía,
/// se convierte en una al aplicar la rutina a un día concreto).
class TareaRutina {
  String nombre;
  int duracionMinutos;
  bool prioridadAlta;
  String? categoriaId;

  TareaRutina({
    required this.nombre,
    required this.duracionMinutos,
    this.prioridadAlta = false,
    this.categoriaId,
  });

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'duracionMinutos': duracionMinutos,
        'prioridadAlta': prioridadAlta,
        'categoriaId': categoriaId,
      };

  factory TareaRutina.fromMap(Map<String, dynamic> map) => TareaRutina(
        nombre: map['nombre'],
        duracionMinutos: map['duracionMinutos'],
        prioridadAlta: map['prioridadAlta'] ?? false,
        categoriaId: map['categoriaId'],
      );
}

/// Rutina semanal: un conjunto de tareas que se repiten en los días de la
/// semana marcados (1 = lunes ... 7 = domingo, igual que DateTime.weekday).
class Rutina {
  String id;
  String nombre;
  Set<int> diasSemana;
  bool activa;
  List<TareaRutina> tareas;

  Rutina({
    required this.id,
    required this.nombre,
    required this.diasSemana,
    this.activa = true,
    List<TareaRutina>? tareas,
  }) : tareas = tareas ?? [];

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'diasSemana': diasSemana.toList(),
        'activa': activa,
        'tareas': tareas.map((t) => t.toMap()).toList(),
      };

  factory Rutina.fromMap(Map<String, dynamic> map) => Rutina(
        id: map['id'],
        nombre: map['nombre'],
        diasSemana: (map['diasSemana'] as List).map((d) => d as int).toSet(),
        activa: map['activa'] ?? true,
        tareas: (map['tareas'] as List).map((t) => TareaRutina.fromMap(t)).toList(),
      );
}
