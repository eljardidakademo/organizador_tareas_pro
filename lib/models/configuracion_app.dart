import 'package:flutter/material.dart';
import '../i18n/traducciones.dart';

enum ModoTema { claro, oscuro, sistema }

enum FormaTarjeta { cuadrada, redondeada, muyRedondeada }

extension FormaTarjetaRadio on FormaTarjeta {
  double get radio {
    switch (this) {
      case FormaTarjeta.cuadrada:
        return 0;
      case FormaTarjeta.redondeada:
        return 12;
      case FormaTarjeta.muyRedondeada:
        return 24;
    }
  }
}

/// Fuentes disponibles para elegir en Ajustes (todas de Google Fonts).
const List<String> fuentesDisponibles = [
  'Roboto',
  'Poppins',
  'Nunito',
  'Merriweather',
  'Montserrat',
];

/// Paleta de colores de fondo disponibles (null = color por defecto del tema).
const List<int?> paletaColoresFondo = [
  null, // por defecto
  0xFFFFFFFF, // blanco
  0xFFF5F5F0, // crema
  0xFFF0F4F8, // azul muy claro
  0xFFF6F0FA, // lila muy claro
  0xFF1A1A1A, // gris oscuro (útil en modo oscuro)
];

/// Configuración global de la app (en memoria por ahora; cuando conectemos
/// Firebase esto pasará a guardarse también en la nube).
class ConfiguracionApp extends ChangeNotifier {
  TimeOfDay horaInicioDefecto;
  TimeOfDay horaFinDefecto;
  bool avisoHuecosActivado;

  ModoTema modoTema;
  int? colorFondo; // null = color por defecto
  String fuente;
  double escalaTexto; // 0.9 = pequeño, 1.0 = normal, 1.15 = grande, 1.3 = muy grande
  FormaTarjeta formaTarjeta;
  Idioma idioma;

  /// Si es false (por defecto) se ocultan el registro de tiempo real de las
  /// tareas, la comparativa real/estimado y las estadísticas. Los datos que
  /// ya hubiera no se borran: vuelven a verse al activarlo.
  bool seguimientoTiempo;

  // --- Pomodoro ---
  int pomodoroTrabajoMin;
  int pomodoroDescansoCortoMin;
  int pomodoroDescansoLargoMin;
  int pomodoroCiclosParaDescansoLargo;
  int pomodoroObjetivoDiario;

  ConfiguracionApp({
    this.horaInicioDefecto = const TimeOfDay(hour: 8, minute: 0),
    this.horaFinDefecto = const TimeOfDay(hour: 22, minute: 0),
    this.avisoHuecosActivado = false,
    this.modoTema = ModoTema.sistema,
    this.colorFondo,
    this.fuente = 'Roboto',
    this.escalaTexto = 1.0,
    this.formaTarjeta = FormaTarjeta.redondeada,
    this.idioma = Idioma.castellano,
    this.seguimientoTiempo = false,
    this.pomodoroTrabajoMin = 25,
    this.pomodoroDescansoCortoMin = 5,
    this.pomodoroDescansoLargoMin = 15,
    this.pomodoroCiclosParaDescansoLargo = 4,
    this.pomodoroObjetivoDiario = 8,
  });

  /// Atajo para traducir cualquier texto de la app según el idioma elegido.
  String t(String clave) => Traducciones.t(idioma, clave);

  /// Convierte la configuración en un mapa para guardarla (en el móvil o en
  /// la copia de seguridad). Las claves no deben cambiar: así se siguen
  /// leyendo bien los datos guardados con versiones anteriores.
  Map<String, dynamic> toMap() => {
        'horaInicioHora': horaInicioDefecto.hour,
        'horaInicioMinuto': horaInicioDefecto.minute,
        'horaFinHora': horaFinDefecto.hour,
        'horaFinMinuto': horaFinDefecto.minute,
        'avisoHuecosActivado': avisoHuecosActivado,
        'modoTema': modoTema.index,
        'colorFondo': colorFondo,
        'fuente': fuente,
        'escalaTexto': escalaTexto,
        'formaTarjeta': formaTarjeta.index,
        'idioma': idioma.index,
        'seguimientoTiempo': seguimientoTiempo,
        'pomodoroTrabajoMin': pomodoroTrabajoMin,
        'pomodoroDescansoCortoMin': pomodoroDescansoCortoMin,
        'pomodoroDescansoLargoMin': pomodoroDescansoLargoMin,
        'pomodoroCiclosParaDescansoLargo': pomodoroCiclosParaDescansoLargo,
        'pomodoroObjetivoDiario': pomodoroObjetivoDiario,
      };

  /// Aplica sobre esta misma instancia los valores de un mapa creado con
  /// [toMap] (sin reemplazarla, para no perder sus listeners). Si falta
  /// algún valor, se usa el de por defecto.
  void aplicarMap(Map<String, dynamic> m) {
    horaInicioDefecto =
        TimeOfDay(hour: m['horaInicioHora'] ?? 8, minute: m['horaInicioMinuto'] ?? 0);
    horaFinDefecto = TimeOfDay(hour: m['horaFinHora'] ?? 22, minute: m['horaFinMinuto'] ?? 0);
    avisoHuecosActivado = m['avisoHuecosActivado'] ?? false;
    modoTema = ModoTema.values[m['modoTema'] ?? ModoTema.sistema.index];
    colorFondo = m['colorFondo'];
    fuente = m['fuente'] ?? 'Roboto';
    escalaTexto = (m['escalaTexto'] ?? 1.0).toDouble();
    formaTarjeta = FormaTarjeta.values[m['formaTarjeta'] ?? FormaTarjeta.redondeada.index];
    idioma = Idioma.values[m['idioma'] ?? Idioma.castellano.index];
    seguimientoTiempo = m['seguimientoTiempo'] ?? false;
    pomodoroTrabajoMin = m['pomodoroTrabajoMin'] ?? 25;
    pomodoroDescansoCortoMin = m['pomodoroDescansoCortoMin'] ?? 5;
    pomodoroDescansoLargoMin = m['pomodoroDescansoLargoMin'] ?? 15;
    pomodoroCiclosParaDescansoLargo = m['pomodoroCiclosParaDescansoLargo'] ?? 4;
    pomodoroObjetivoDiario = m['pomodoroObjetivoDiario'] ?? 8;
  }

  /// Se llama tras mutar cualquier campo, para que la app entera (tema,
  /// pantallas abiertas) se repinte con los valores nuevos.
  void notificar() => notifyListeners();
}
