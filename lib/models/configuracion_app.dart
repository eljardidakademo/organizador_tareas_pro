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

  String get etiqueta {
    switch (this) {
      case FormaTarjeta.cuadrada:
        return 'Cuadrada';
      case FormaTarjeta.redondeada:
        return 'Redondeada';
      case FormaTarjeta.muyRedondeada:
        return 'Muy redondeada';
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
    this.pomodoroTrabajoMin = 25,
    this.pomodoroDescansoCortoMin = 5,
    this.pomodoroDescansoLargoMin = 15,
    this.pomodoroCiclosParaDescansoLargo = 4,
    this.pomodoroObjetivoDiario = 8,
  });

  /// Atajo para traducir cualquier texto de la app según el idioma elegido.
  String t(String clave) => Traducciones.t(idioma, clave);

  /// Se llama tras mutar cualquier campo, para que la app entera (tema,
  /// pantallas abiertas) se repinte con los valores nuevos.
  void notificar() => notifyListeners();
}
