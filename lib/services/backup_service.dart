import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/dia.dart';
import '../models/lista_favorita.dart';
import '../models/categoria.dart';
import '../models/rutina.dart';
import '../models/configuracion_app.dart';
import '../i18n/traducciones.dart';
import 'persistencia_service.dart';

class ServicioCopiaSeguridad {
  static const _marca = 'organizador_tareas_pro_backup_v1';

  static Future<void> copiarAlPortapapeles({
    required List<Dia> dias,
    required List<ListaFavorita> listas,
    required List<Categoria> categorias,
    required List<Rutina> rutinas,
    required ConfiguracionApp configuracion,
  }) async {
    final mapa = {
      'marca': _marca,
      'dias': dias.map((d) => d.toMap()).toList(),
      'listas': listas.map((l) => l.toMap()).toList(),
      'categorias': categorias.map((c) => c.toMap()).toList(),
      'rutinas': rutinas.map((r) => r.toMap()).toList(),
      'configuracion': {
        'horaInicioHora': configuracion.horaInicioDefecto.hour,
        'horaInicioMinuto': configuracion.horaInicioDefecto.minute,
        'horaFinHora': configuracion.horaFinDefecto.hour,
        'horaFinMinuto': configuracion.horaFinDefecto.minute,
        'avisoHuecosActivado': configuracion.avisoHuecosActivado,
        'modoTema': configuracion.modoTema.index,
        'colorFondo': configuracion.colorFondo,
        'fuente': configuracion.fuente,
        'escalaTexto': configuracion.escalaTexto,
        'formaTarjeta': configuracion.formaTarjeta.index,
        'idioma': configuracion.idioma.index,
        'pomodoroTrabajoMin': configuracion.pomodoroTrabajoMin,
        'pomodoroDescansoCortoMin': configuracion.pomodoroDescansoCortoMin,
        'pomodoroDescansoLargoMin': configuracion.pomodoroDescansoLargoMin,
        'pomodoroCiclosParaDescansoLargo': configuracion.pomodoroCiclosParaDescansoLargo,
        'pomodoroObjetivoDiario': configuracion.pomodoroObjetivoDiario,
      },
    };
    await Clipboard.setData(ClipboardData(text: jsonEncode(mapa)));
  }

  /// Intenta restaurar desde el texto del portapapeles, mutando en el sitio
  /// las listas y la configuración que ya existen (para no perder
  /// referencias usadas por las pantallas abiertas). Devuelve true si tuvo
  /// éxito, false si el contenido no era una copia de seguridad válida.
  static Future<bool> restaurarDesdePortapapeles({
    required List<Dia> dias,
    required List<ListaFavorita> listas,
    required List<Categoria> categorias,
    required List<Rutina> rutinas,
    required ConfiguracionApp configuracion,
  }) async {
    try {
      final datosPortapapeles = await Clipboard.getData(Clipboard.kTextPlain);
      final texto = datosPortapapeles?.text;
      if (texto == null) return false;

      final Map<String, dynamic> mapa = jsonDecode(texto);
      if (mapa['marca'] != _marca) return false;

      dias
        ..clear()
        ..addAll((mapa['dias'] as List).map((m) => Dia.fromMap(m)));
      listas
        ..clear()
        ..addAll((mapa['listas'] as List).map((m) => ListaFavorita.fromMap(m)));
      categorias
        ..clear()
        ..addAll((mapa['categorias'] as List).map((m) => Categoria.fromMap(m)));
      rutinas
        ..clear()
        ..addAll((mapa['rutinas'] as List).map((m) => Rutina.fromMap(m)));

      final c = mapa['configuracion'] as Map<String, dynamic>;
      configuracion.horaInicioDefecto =
          TimeOfDay(hour: c['horaInicioHora'], minute: c['horaInicioMinuto']);
      configuracion.horaFinDefecto = TimeOfDay(hour: c['horaFinHora'], minute: c['horaFinMinuto']);
      configuracion.avisoHuecosActivado = c['avisoHuecosActivado'] ?? false;
      configuracion.modoTema = ModoTema.values[c['modoTema'] ?? ModoTema.sistema.index];
      configuracion.colorFondo = c['colorFondo'];
      configuracion.fuente = c['fuente'] ?? 'Roboto';
      configuracion.escalaTexto = (c['escalaTexto'] ?? 1.0).toDouble();
      configuracion.formaTarjeta =
          FormaTarjeta.values[c['formaTarjeta'] ?? FormaTarjeta.redondeada.index];
      configuracion.idioma = Idioma.values[c['idioma'] ?? Idioma.castellano.index];
      configuracion.pomodoroTrabajoMin = c['pomodoroTrabajoMin'] ?? 25;
      configuracion.pomodoroDescansoCortoMin = c['pomodoroDescansoCortoMin'] ?? 5;
      configuracion.pomodoroDescansoLargoMin = c['pomodoroDescansoLargoMin'] ?? 15;
      configuracion.pomodoroCiclosParaDescansoLargo = c['pomodoroCiclosParaDescansoLargo'] ?? 4;
      configuracion.pomodoroObjetivoDiario = c['pomodoroObjetivoDiario'] ?? 8;

      // Persistir todo lo restaurado y avisar a la app del cambio de tema/idioma.
      await ServicioPersistencia.guardarDias(dias);
      await ServicioPersistencia.guardarListasFavoritas(listas);
      await ServicioPersistencia.guardarCategorias(categorias);
      await ServicioPersistencia.guardarRutinas(rutinas);
      await ServicioPersistencia.guardarConfiguracion(configuracion);
      configuracion.notificar();

      return true;
    } catch (_) {
      return false;
    }
  }
}
