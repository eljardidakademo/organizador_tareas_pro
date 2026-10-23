import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/dia.dart';
import '../models/lista_favorita.dart';
import '../models/categoria.dart';
import '../models/rutina.dart';
import '../models/configuracion_app.dart';
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
    final pomodoros = await ServicioPersistencia.cargarPomodorosCompletados();
    final mapa = {
      'marca': _marca,
      'dias': dias.map((d) => d.toMap()).toList(),
      'listas': listas.map((l) => l.toMap()).toList(),
      'categorias': categorias.map((c) => c.toMap()).toList(),
      'rutinas': rutinas.map((r) => r.toMap()).toList(),
      'configuracion': configuracion.toMap(),
      'pomodoros': pomodoros.map((p) => p.toIso8601String()).toList(),
    };
    await Clipboard.setData(ClipboardData(text: jsonEncode(mapa)));
  }

  /// Intenta restaurar desde el texto del portapapeles, mutando en el sitio
  /// las listas y la configuración que ya existen (para no perder
  /// referencias usadas por las pantallas abiertas). Devuelve true si tuvo
  /// éxito, false si el contenido no era una copia de seguridad válida.
  ///
  /// Primero se lee y comprueba TODA la copia; solo si está completa se
  /// sustituyen los datos actuales. Si algo falla, no se toca nada.
  static Future<bool> restaurarDesdePortapapeles({
    required List<Dia> dias,
    required List<ListaFavorita> listas,
    required List<Categoria> categorias,
    required List<Rutina> rutinas,
    required ConfiguracionApp configuracion,
  }) async {
    final List<Dia> nuevosDias;
    final List<ListaFavorita> nuevasListas;
    final List<Categoria> nuevasCategorias;
    final List<Rutina> nuevasRutinas;
    final Map<String, dynamic> nuevaConfiguracion;
    final List<DateTime>? nuevosPomodoros;

    // 1) Leer y validar sin modificar nada.
    try {
      final datosPortapapeles = await Clipboard.getData(Clipboard.kTextPlain);
      final texto = datosPortapapeles?.text;
      if (texto == null) return false;

      final Map<String, dynamic> mapa = jsonDecode(texto);
      if (mapa['marca'] != _marca) return false;

      nuevosDias = (mapa['dias'] as List).map((m) => Dia.fromMap(m)).toList();
      nuevasListas = (mapa['listas'] as List).map((m) => ListaFavorita.fromMap(m)).toList();
      nuevasCategorias = (mapa['categorias'] as List).map((m) => Categoria.fromMap(m)).toList();
      nuevasRutinas = (mapa['rutinas'] as List).map((m) => Rutina.fromMap(m)).toList();
      nuevaConfiguracion = Map<String, dynamic>.from(mapa['configuracion'] as Map);
      // Comprueba que la configuración se puede aplicar sin errores.
      ConfiguracionApp().aplicarMap(nuevaConfiguracion);
      // Las copias antiguas no traen Pomodoros: en ese caso se conservan los actuales.
      nuevosPomodoros = mapa['pomodoros'] == null
          ? null
          : (mapa['pomodoros'] as List).map((s) => DateTime.parse(s as String)).toList();
    } catch (_) {
      return false;
    }

    // 2) La copia es válida: ahora sí, sustituir los datos.
    dias
      ..clear()
      ..addAll(nuevosDias);
    listas
      ..clear()
      ..addAll(nuevasListas);
    categorias
      ..clear()
      ..addAll(nuevasCategorias);
    rutinas
      ..clear()
      ..addAll(nuevasRutinas);
    configuracion.aplicarMap(nuevaConfiguracion);

    // Persistir todo lo restaurado y avisar a la app del cambio de tema/idioma.
    await ServicioPersistencia.guardarDias(dias);
    await ServicioPersistencia.guardarListasFavoritas(listas);
    await ServicioPersistencia.guardarCategorias(categorias);
    await ServicioPersistencia.guardarRutinas(rutinas);
    await ServicioPersistencia.guardarConfiguracion(configuracion);
    if (nuevosPomodoros != null) {
      await ServicioPersistencia.guardarPomodorosCompletados(nuevosPomodoros);
    }
    configuracion.notificar();

    return true;
  }
}
