import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../models/dia.dart';
import '../i18n/traducciones.dart';

/// Envía al widget de Android "Tareas de hoy" los textos que debe mostrar.
/// En la versión web no hace nada (allí no existen los widgets).
class ServicioWidget {
  /// Idioma con el que se escriben los textos del widget. Lo actualiza la
  /// app al cargar la configuración y cada vez que cambia.
  static Idioma idioma = Idioma.castellano;

  static const _maxTareas = 8;

  static bool get _disponible =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static String _t(String clave) => Traducciones.t(idioma, clave);

  static String _dosCifras(int n) => n.toString().padLeft(2, '0');

  static Future<void> actualizar(List<Dia> dias) async {
    if (!_disponible) return;
    try {
      final ahora = DateTime.now();
      final hoy = dias.where((d) => d.esMismaFecha(ahora)).toList();
      final tareas = hoy.isEmpty
          ? []
          : ([...hoy.first.tareas]
            ..sort((a, b) => a.horaInicio.compareTo(b.horaInicio)));
      final pendientes = tareas.where((t) => !t.completada).toList();
      final hechas = tareas.length - pendientes.length;

      final String titulo;
      final String contenido;
      if (tareas.isEmpty) {
        titulo = _t('hoy');
        contenido = _t('widget_sin_tareas');
      } else {
        titulo = '${_t('hoy')} · $hechas/${tareas.length}';
        if (pendientes.isEmpty) {
          contenido = _t('widget_todo_hecho');
        } else {
          final lineas = pendientes.take(_maxTareas).map((t) =>
              '${_dosCifras(t.horaInicio.hour)}:${_dosCifras(t.horaInicio.minute)}  ${t.prioridadAlta ? '❗' : ''}${t.nombre}');
          final resto = pendientes.length - _maxTareas;
          contenido = [...lineas, if (resto > 0) '+$resto…'].join('\n');
        }
      }

      final fecha =
          '${ahora.year}-${_dosCifras(ahora.month)}-${_dosCifras(ahora.day)}';
      await HomeWidget.saveWidgetData<String>('widget_fecha', fecha);
      await HomeWidget.saveWidgetData<String>('widget_titulo', titulo);
      await HomeWidget.saveWidgetData<String>('widget_contenido', contenido);
      await HomeWidget.saveWidgetData<String>('widget_titulo_vacio', _t('hoy'));
      await HomeWidget.saveWidgetData<String>(
          'widget_abrir_app', _t('widget_abrir_app'));
      await HomeWidget.updateWidget(androidName: 'WidgetTareasHoy');
    } catch (_) {
      // Si el widget falla, la app debe seguir funcionando con normalidad.
    }
  }
}
