import '../models/dia.dart';
import '../models/categoria.dart';

class ServicioEstadisticas {
  /// Devuelve el porcentaje medio de desviación (real vs estimado) de las
  /// tareas completadas de [categoriaId] en todos los días, o null si aún
  /// no hay suficientes datos (menos de 2 tareas con tiempo real registrado).
  ///
  /// Un resultado de 20.0 significa "suelen tardar un 20% más de lo estimado".
  /// Un resultado de -15.0 significa "suelen tardar un 15% menos".
  static double? desviacionPromedioPorCategoria(String categoriaId, List<Dia> todosLosDias) {
    final desviaciones = _desviacionesPorCategoria(categoriaId, todosLosDias);
    if (desviaciones.length < 2) return null;
    return desviaciones.reduce((a, b) => a + b) / desviaciones.length;
  }

  static List<double> _desviacionesPorCategoria(String categoriaId, List<Dia> todosLosDias) {
    final desviaciones = <double>[];
    for (final dia in todosLosDias) {
      for (final tarea in dia.tareas) {
        if (tarea.categoriaId != categoriaId) continue;
        if (tarea.sesiones.isEmpty) continue;
        if (tarea.duracionMinutos <= 0) continue;
        desviaciones.add(
          ((tarea.tiempoRealMinutos - tarea.duracionMinutos) / tarea.duracionMinutos) * 100,
        );
      }
    }
    return desviaciones;
  }

  /// Suma de minutos de todas las sesiones (de todas las tareas) cuyo
  /// [SesionTiempo.inicio] cae dentro de [inicio, fin] (ambos inclusive).
  static int tiempoTrabajadoEnRango(List<Dia> dias, DateTime inicio, DateTime fin) {
    int total = 0;
    for (final dia in dias) {
      for (final tarea in dia.tareas) {
        for (final s in tarea.sesiones) {
          if (!s.inicio.isBefore(inicio) && !s.inicio.isAfter(fin)) {
            total += s.minutos;
          }
        }
      }
    }
    return total;
  }

  /// Cuenta tareas completadas cuyo día cae dentro del rango (se usa la
  /// fecha del día como aproximación de cuándo se completó la tarea).
  static int tareasCompletadasEnRango(List<Dia> dias, DateTime inicio, DateTime fin) {
    int total = 0;
    for (final dia in dias) {
      if (dia.fecha.isBefore(_soloFecha(inicio)) || dia.fecha.isAfter(_soloFecha(fin))) continue;
      total += dia.tareas.where((t) => t.completada).length;
    }
    return total;
  }

  static DateTime _soloFecha(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Total de minutos reales invertidos, agrupado por categoriaId
  /// (la clave 'sin_categoria' agrupa las tareas sin categoría asignada).
  static Map<String, int> tiempoPorCategoria(List<Dia> dias) {
    final mapa = <String, int>{};
    for (final dia in dias) {
      for (final tarea in dia.tareas) {
        if (tarea.tiempoRealMinutos == 0) continue;
        final clave = tarea.categoriaId ?? 'sin_categoria';
        mapa[clave] = (mapa[clave] ?? 0) + tarea.tiempoRealMinutos;
      }
    }
    return mapa;
  }

  /// (estimado total, real total) de todas las tareas con tiempo registrado.
  static (int, int) estimadoVsRealTotal(List<Dia> dias) {
    int estimado = 0;
    int real = 0;
    for (final dia in dias) {
      for (final tarea in dia.tareas) {
        if (tarea.sesiones.isEmpty) continue;
        estimado += tarea.duracionMinutos;
        real += tarea.tiempoRealMinutos;
      }
    }
    return (estimado, real);
  }

  /// Hora del día (0-23) donde más minutos reales se han invertido en total,
  /// o null si no hay datos suficientes. Usa la hora en la que de verdad se
  /// trabajó (el inicio de cada sesión), no la hora prevista de la tarea.
  static int? franjaMasProductiva(List<Dia> dias) {
    final porHora = <int, int>{};
    for (final dia in dias) {
      for (final tarea in dia.tareas) {
        for (final s in tarea.sesiones) {
          if (s.minutos <= 0) continue;
          final hora = s.inicio.hour;
          porHora[hora] = (porHora[hora] ?? 0) + s.minutos;
        }
      }
    }
    if (porHora.isEmpty) return null;
    return porHora.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  /// % de tareas (con tiempo registrado) cuya desviación está dentro de
  /// un margen razonable (±20% del tiempo estimado).
  static double? tasaAciertoEstimaciones(List<Dia> dias) {
    int total = 0;
    int aciertos = 0;
    for (final dia in dias) {
      for (final tarea in dia.tareas) {
        if (tarea.sesiones.isEmpty || tarea.duracionMinutos <= 0) continue;
        total++;
        final margen = tarea.duracionMinutos * 0.2;
        if (tarea.diferenciaMinutos.abs() <= margen) aciertos++;
      }
    }
    if (total == 0) return null;
    return (aciertos / total) * 100;
  }

  /// Categoría cuya desviación media es mayor (la que más se retrasa),
  /// o null si no hay categorías con datos suficientes.
  static (Categoria, double)? categoriaConMasRetraso(
    List<Categoria> categorias,
    List<Dia> dias,
  ) {
    Categoria? mejor;
    double mejorValor = double.negativeInfinity;
    for (final categoria in categorias) {
      final desviacion = desviacionPromedioPorCategoria(categoria.id, dias);
      if (desviacion != null && desviacion > mejorValor) {
        mejorValor = desviacion;
        mejor = categoria;
      }
    }
    if (mejor == null) return null;
    return (mejor, mejorValor);
  }

  /// Racha de días consecutivos en los que se completó al menos una tarea.
  /// Cuenta hacia atrás desde hoy (o desde ayer, si hoy aún no has
  /// completado nada): si dejas pasar un día entero sin completar tareas,
  /// la racha vuelve a 0.
  static int rachaDiasConTareasCompletadas(List<Dia> dias) {
    final hoy = _soloFecha(DateTime.now());
    final ayer = hoy.subtract(const Duration(days: 1));
    // Solo cuentan los días hasta hoy (los planificados a futuro no).
    final diasOrdenados = dias.where((d) => !_soloFecha(d.fecha).isAfter(hoy)).toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
    int racha = 0;
    DateTime? esperado;
    for (final dia in diasOrdenados) {
      final tieneCompletadas = dia.tareas.any((t) => t.completada);
      if (!tieneCompletadas) {
        if (racha == 0) continue; // aún no hemos empezado a contar
        break;
      }
      final fecha = _soloFecha(dia.fecha);
      // El primer día con tareas completadas debe ser hoy o ayer.
      if (esperado == null && fecha != hoy && fecha != ayer) return 0;
      if (esperado == null || fecha == esperado) {
        racha++;
        esperado = fecha.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return racha;
  }

  /// Minutos reales trabajados cada uno de los últimos 7 días (incluye hoy),
  /// en orden cronológico (el último elemento es hoy). Útil para un gráfico simple.
  static List<int> tendenciaUltimos7Dias(List<Dia> dias) {
    final hoy = _soloFecha(DateTime.now());
    final resultado = <int>[];
    for (int i = 6; i >= 0; i--) {
      final fecha = hoy.subtract(Duration(days: i));
      final diaCoincidente = dias.where((d) => d.esMismaFecha(fecha)).toList();
      if (diaCoincidente.isEmpty) {
        resultado.add(0);
      } else {
        int minutos = 0;
        for (final tarea in diaCoincidente.first.tareas) {
          minutos += tarea.tiempoRealMinutos;
        }
        resultado.add(minutos);
      }
    }
    return resultado;
  }

  static int pomodorosEnRango(List<DateTime> pomodoros, DateTime inicio, DateTime fin) {
    return pomodoros.where((p) => !p.isBefore(inicio) && !p.isAfter(fin)).length;
  }
}
