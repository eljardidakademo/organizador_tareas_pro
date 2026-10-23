import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dia.dart';
import '../models/lista_favorita.dart';
import '../models/categoria.dart';
import '../models/rutina.dart';
import '../models/configuracion_app.dart';
import 'widget_service.dart';

/// Guarda y recupera los datos de la app en el almacenamiento local del
/// dispositivo (SharedPreferences), para que no se pierdan al cerrar la app.
/// Cuando conectemos Firebase, esto se ampliará para sincronizar también
/// en la nube, pero esta capa local seguirá funcionando como caché rápida.
class ServicioPersistencia {
  static const _claveDias = 'dias_json';
  static const _claveListas = 'listas_favoritas_json';
  static const _claveConfiguracion = 'configuracion_json';
  static const _claveCategorias = 'categorias_json';

  static Future<void> guardarCategorias(List<Categoria> categorias) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = categorias.map((c) => c.toMap()).toList();
    await prefs.setString(_claveCategorias, jsonEncode(lista));
  }

  static Future<List<Categoria>> cargarCategorias() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_claveCategorias);
    if (json == null) return [];
    final List<dynamic> lista = jsonDecode(json);
    return lista.map((m) => Categoria.fromMap(m)).toList();
  }

  static const _claveRutinas = 'rutinas_json';

  static Future<void> guardarRutinas(List<Rutina> rutinas) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = rutinas.map((r) => r.toMap()).toList();
    await prefs.setString(_claveRutinas, jsonEncode(lista));
  }

  static Future<List<Rutina>> cargarRutinas() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_claveRutinas);
    if (json == null) return [];
    final List<dynamic> lista = jsonDecode(json);
    return lista.map((m) => Rutina.fromMap(m)).toList();
  }

  static Future<void> guardarDias(List<Dia> dias) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = dias.map((d) => d.toMap()).toList();
    await prefs.setString(_claveDias, jsonEncode(lista));
    // Cada vez que cambian los días, se refresca el widget de inicio.
    await ServicioWidget.actualizar(dias);
  }

  static Future<List<Dia>> cargarDias() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_claveDias);
    if (json == null) return [];
    final List<dynamic> lista = jsonDecode(json);
    return lista.map((m) => Dia.fromMap(m)).toList();
  }

  static Future<void> guardarListasFavoritas(List<ListaFavorita> listas) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = listas.map((l) => l.toMap()).toList();
    await prefs.setString(_claveListas, jsonEncode(lista));
  }

  /// Null si nunca se han guardado (primera vez que se abre la app):
  /// así quien llama sabe que debe usar las listas predefinidas de fábrica.
  static Future<List<ListaFavorita>?> cargarListasFavoritas() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_claveListas);
    if (json == null) return null;
    final List<dynamic> lista = jsonDecode(json);
    return lista.map((m) => ListaFavorita.fromMap(m)).toList();
  }

  static Future<void> guardarConfiguracion(ConfiguracionApp c) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_claveConfiguracion, jsonEncode(c.toMap()));
  }

  /// Aplica los valores guardados sobre una instancia ya creada de
  /// ConfiguracionApp (sin reemplazarla, para no perder sus listeners).
  static Future<void> cargarConfiguracionEn(ConfiguracionApp c) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_claveConfiguracion);
    if (json == null) return;
    c.aplicarMap(jsonDecode(json));
  }

  // --- Historial global de Pomodoros completados (para el objetivo diario
  // y las estadísticas), independiente de las tareas/días. ---
  static const _clavePomodoros = 'pomodoros_completados_json';

  static Future<void> registrarPomodoroCompletado() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_clavePomodoros);
    final List<dynamic> lista = json == null ? [] : jsonDecode(json);
    lista.add(DateTime.now().toIso8601String());
    await prefs.setString(_clavePomodoros, jsonEncode(lista));
  }

  /// Sustituye el historial completo (se usa al restaurar una copia).
  static Future<void> guardarPomodorosCompletados(List<DateTime> pomodoros) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _clavePomodoros, jsonEncode(pomodoros.map((p) => p.toIso8601String()).toList()));
  }

  static Future<List<DateTime>> cargarPomodorosCompletados() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_clavePomodoros);
    if (json == null) return [];
    final List<dynamic> lista = jsonDecode(json);
    return lista.map((s) => DateTime.parse(s as String)).toList();
  }
}
