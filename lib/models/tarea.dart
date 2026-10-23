/// Una sesión de tiempo real invertido en una tarea (registrada a mano o
/// automáticamente al completar un Pomodoro sobre esa tarea).
class SesionTiempo {
  DateTime inicio;
  int minutos;
  String origen; // 'manual' o 'pomodoro'

  SesionTiempo({required this.inicio, required this.minutos, required this.origen});

  Map<String, dynamic> toMap() => {
        'inicio': inicio.toIso8601String(),
        'minutos': minutos,
        'origen': origen,
      };

  factory SesionTiempo.fromMap(Map<String, dynamic> map) => SesionTiempo(
        inicio: DateTime.parse(map['inicio']),
        minutos: map['minutos'],
        origen: map['origen'] ?? 'manual',
      );
}

class Tarea {
  String id;
  String nombre;
  DateTime horaInicio; // calculada según el orden en el día (o fija, si horaFija=true)
  int duracionMinutos; // tiempo ESTIMADO
  bool prioridadAlta;
  bool horaFija; // si es true, horaInicio es inamovible y el resto se adapta a ella
  bool completada;
  String? listaOrigenId; // null si se creó manualmente
  String? categoriaId; // null si no se asignó categoría
  int orden; // posición dentro del día, permite reordenar a mano
  List<SesionTiempo> sesiones; // historial de tiempo real invertido

  Tarea({
    required this.id,
    required this.nombre,
    required this.horaInicio,
    required this.duracionMinutos,
    this.prioridadAlta = false,
    this.horaFija = false,
    this.completada = false,
    this.listaOrigenId,
    this.categoriaId,
    required this.orden,
    List<SesionTiempo>? sesiones,
  }) : sesiones = sesiones ?? [];

  DateTime get horaFin => horaInicio.add(Duration(minutes: duracionMinutos));

  /// Suma de todas las sesiones registradas: el tiempo REAL invertido.
  int get tiempoRealMinutos => sesiones.fold(0, (total, s) => total + s.minutos);

  /// Diferencia real - estimado. Positivo = se pasó, negativo = fue más rápido.
  int get diferenciaMinutos => tiempoRealMinutos - duracionMinutos;

  /// Progreso del tiempo real respecto al estimado (para la barra y el aviso del 80%).
  double get progresoTiempo =>
      duracionMinutos == 0 ? 0 : (tiempoRealMinutos / duracionMinutos).clamp(0, 999) as double;

  void registrarSesion(int minutos, {String origen = 'manual'}) {
    sesiones.add(SesionTiempo(inicio: DateTime.now(), minutos: minutos, origen: origen));
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'horaInicio': horaInicio.toIso8601String(),
        'duracionMinutos': duracionMinutos,
        'prioridadAlta': prioridadAlta,
        'horaFija': horaFija,
        'completada': completada,
        'listaOrigenId': listaOrigenId,
        'categoriaId': categoriaId,
        'orden': orden,
        'sesiones': sesiones.map((s) => s.toMap()).toList(),
      };

  factory Tarea.fromMap(Map<String, dynamic> map) => Tarea(
        id: map['id'],
        nombre: map['nombre'],
        horaInicio: DateTime.parse(map['horaInicio']),
        duracionMinutos: map['duracionMinutos'],
        prioridadAlta: map['prioridadAlta'] ?? false,
        horaFija: map['horaFija'] ?? false,
        completada: map['completada'] ?? false,
        listaOrigenId: map['listaOrigenId'],
        categoriaId: map['categoriaId'],
        orden: map['orden'],
        sesiones: map['sesiones'] == null
            ? []
            : (map['sesiones'] as List).map((s) => SesionTiempo.fromMap(s)).toList(),
      );
}
