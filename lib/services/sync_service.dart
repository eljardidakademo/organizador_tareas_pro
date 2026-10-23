import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dia.dart';
import '../models/lista_favorita.dart';
import '../models/categoria.dart';
import '../models/rutina.dart';
import '../models/configuracion_app.dart';
import 'persistencia_service.dart';

/// Resultado de un intento de sincronización.
enum ResultadoSync { sinCambios, descargado, subido, error, desactivada }

/// Sincroniza los datos entre el móvil y la web a través de un Google Apps
/// Script (que guarda una copia de todo en un archivo de tu Google Drive).
///
/// Funciona así:
/// - Cada vez que se guarda algo, se apunta la hora del cambio y, unos
///   segundos después, se sube todo a la nube.
/// - Al abrir la app (o volver a ella), se mira la nube: si allí hay datos
///   más recientes, se descargan y sustituyen a los del dispositivo.
/// Si se edita en dos dispositivos a la vez sin conexión, gana el último cambio.
class ServicioSync {
  static const _claveUrl = 'sync_url';
  static const _claveClave = 'sync_clave';
  static const _claveModificado = 'sync_modificado_local';
  static const _claveUltimaSync = 'sync_ultima';

  static String url = '';
  static String clave = '';
  static int _modificadoLocal = 0; // milisegundos desde 1970
  static DateTime? ultimaSync;
  static String? ultimoError;

  /// Se incrementa cuando se descargan datos de la nube, para que la
  /// pantalla principal los vuelva a cargar.
  static final ValueNotifier<int> datosDescargados = ValueNotifier(0);

  static bool _aplicandoRemoto = false;
  static Timer? _temporizadorSubida;

  static bool get activa => url.trim().isNotEmpty && clave.trim().isNotEmpty;

  static Future<void> cargarAjustes() async {
    final prefs = await SharedPreferences.getInstance();
    url = prefs.getString(_claveUrl) ?? '';
    clave = prefs.getString(_claveClave) ?? '';
    _modificadoLocal = prefs.getInt(_claveModificado) ?? 0;
    final ultima = prefs.getString(_claveUltimaSync);
    ultimaSync = ultima == null ? null : DateTime.tryParse(ultima);
  }

  static Future<void> guardarAjustes(String nuevaUrl, String nuevaClave) async {
    url = nuevaUrl.trim();
    clave = nuevaClave.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_claveUrl, url);
    await prefs.setString(_claveClave, clave);
  }

  /// Lo llama ServicioPersistencia cada vez que se guarda algo.
  static void marcarCambioLocal() {
    if (_aplicandoRemoto) return; // guardando datos que vienen de la nube
    _modificadoLocal = DateTime.now().millisecondsSinceEpoch;
    SharedPreferences.getInstance().then((p) => p.setInt(_claveModificado, _modificadoLocal));
    if (!activa) return;
    _temporizadorSubida?.cancel();
    _temporizadorSubida = Timer(const Duration(seconds: 3), () => subir());
  }

  /// Comprueba la nube y deja el dispositivo y la nube iguales: descarga si
  /// la nube es más reciente y sube si lo es el dispositivo.
  static Future<ResultadoSync> sincronizar() async {
    if (!activa) return ResultadoSync.desactivada;
    try {
      final remoto = await _leerNube();
      final modificadoRemoto = ((remoto['modificado'] ?? 0) as num).toInt();
      if (remoto['datos'] != null && modificadoRemoto > _modificadoLocal) {
        await _aplicarDatos(Map<String, dynamic>.from(remoto['datos']), modificadoRemoto);
        return ResultadoSync.descargado;
      }
      if (_modificadoLocal > modificadoRemoto) {
        return await subir();
      }
      await _apuntarSyncCorrecta();
      return ResultadoSync.sinCambios;
    } catch (e) {
      ultimoError = e.toString();
      return ResultadoSync.error;
    }
  }

  /// Sube todos los datos del dispositivo. Con [forzar], sustituye lo que
  /// haya en la nube aunque sea más reciente (se usa al conectar el primer
  /// dispositivo).
  static Future<ResultadoSync> subir({bool forzar = false}) async {
    if (!activa) return ResultadoSync.desactivada;
    _temporizadorSubida?.cancel();
    try {
      if (_modificadoLocal == 0 || forzar) {
        _modificadoLocal = DateTime.now().millisecondsSinceEpoch;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_claveModificado, _modificadoLocal);
      }
      final cuerpo = jsonEncode({
        'clave': clave,
        'modificado': _modificadoLocal,
        'forzar': forzar,
        'datos': await _datosDelDispositivo(),
      });
      final respuesta = await _post(cuerpo);
      if (respuesta['ok'] == true) {
        await _apuntarSyncCorrecta();
        return ResultadoSync.subido;
      }
      if (respuesta['error'] == 'antiguo') {
        // En la nube hay algo más reciente: se descarga en su lugar.
        return await sincronizar();
      }
      throw Exception(respuesta['error'] ?? 'respuesta desconocida');
    } catch (e) {
      ultimoError = e.toString();
      return ResultadoSync.error;
    }
  }

  /// Sustituye los datos del dispositivo por los de la nube.
  static Future<ResultadoSync> descargar() async {
    if (!activa) return ResultadoSync.desactivada;
    try {
      final remoto = await _leerNube();
      if (remoto['datos'] == null) return ResultadoSync.sinCambios;
      await _aplicarDatos(
          Map<String, dynamic>.from(remoto['datos']), ((remoto['modificado'] ?? 0) as num).toInt());
      return ResultadoSync.descargado;
    } catch (e) {
      ultimoError = e.toString();
      return ResultadoSync.error;
    }
  }

  /// Ejecuta [accion] sin que los guardados que haga cuenten como cambios
  /// nuevos (se usa al recargar en pantalla lo que se acaba de descargar).
  static Future<void> sinMarcarCambios(Future<void> Function() accion) async {
    _aplicandoRemoto = true;
    try {
      await accion();
    } finally {
      _aplicandoRemoto = false;
    }
  }

  // ---------------------------------------------------------------------

  static Future<void> _apuntarSyncCorrecta() async {
    ultimoError = null;
    ultimaSync = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_claveUltimaSync, ultimaSync!.toIso8601String());
  }

  static Future<Map<String, dynamic>> _datosDelDispositivo() async {
    final dias = await ServicioPersistencia.cargarDias();
    final listas = await ServicioPersistencia.cargarListasFavoritas();
    final categorias = await ServicioPersistencia.cargarCategorias();
    final rutinas = await ServicioPersistencia.cargarRutinas();
    final pomodoros = await ServicioPersistencia.cargarPomodorosCompletados();
    return {
      'dias': dias.map((d) => d.toMap()).toList(),
      // null = aún se usan las listas de fábrica
      'listas': listas?.map((l) => l.toMap()).toList(),
      'categorias': categorias.map((c) => c.toMap()).toList(),
      'rutinas': rutinas.map((r) => r.toMap()).toList(),
      'configuracion': await ServicioPersistencia.cargarConfiguracionMapa(),
      'pomodoros': pomodoros.map((p) => p.toIso8601String()).toList(),
    };
  }

  /// Comprueba TODOS los datos antes de guardar nada: si algo está mal,
  /// se lanza un error y el dispositivo se queda como estaba.
  static Future<void> _aplicarDatos(Map<String, dynamic> datos, int modificadoRemoto) async {
    final dias = (datos['dias'] as List).map((m) => Dia.fromMap(m)).toList();
    final listas = datos['listas'] == null
        ? null
        : (datos['listas'] as List).map((m) => ListaFavorita.fromMap(m)).toList();
    final categorias = (datos['categorias'] as List).map((m) => Categoria.fromMap(m)).toList();
    final rutinas = (datos['rutinas'] as List).map((m) => Rutina.fromMap(m)).toList();
    final configuracion =
        datos['configuracion'] == null ? null : Map<String, dynamic>.from(datos['configuracion']);
    if (configuracion != null) ConfiguracionApp().aplicarMap(configuracion);
    final pomodoros =
        ((datos['pomodoros'] ?? []) as List).map((s) => DateTime.parse(s as String)).toList();

    _aplicandoRemoto = true;
    try {
      await ServicioPersistencia.guardarDias(dias);
      if (listas != null) await ServicioPersistencia.guardarListasFavoritas(listas);
      await ServicioPersistencia.guardarCategorias(categorias);
      await ServicioPersistencia.guardarRutinas(rutinas);
      if (configuracion != null) {
        await ServicioPersistencia.guardarConfiguracionMapa(configuracion);
      }
      await ServicioPersistencia.guardarPomodorosCompletados(pomodoros);
      _modificadoLocal = modificadoRemoto;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_claveModificado, _modificadoLocal);
    } finally {
      _aplicandoRemoto = false;
    }
    await _apuntarSyncCorrecta();
    datosDescargados.value++;
  }

  static Future<Map<String, dynamic>> _leerNube() async {
    final uri = Uri.parse(url).replace(queryParameters: {'clave': clave});
    final respuesta = await http.get(uri).timeout(const Duration(seconds: 30));
    final mapa = _decodificar(respuesta);
    if (mapa['ok'] != true) throw Exception(mapa['error'] ?? 'error');
    return mapa;
  }

  static Future<Map<String, dynamic>> _post(String cuerpo) async {
    // text/plain evita que el navegador (versión web) bloquee la petición.
    var respuesta = await http
        .post(Uri.parse(url), headers: {'Content-Type': 'text/plain;charset=utf-8'}, body: cuerpo)
        .timeout(const Duration(seconds: 60));
    // Google responde a los POST con una redirección hacia el resultado; en
    // el móvil hay que seguirla a mano (en la web la sigue el navegador).
    final destino = respuesta.headers['location'];
    if (respuesta.statusCode >= 300 && respuesta.statusCode < 400 && destino != null) {
      respuesta = await http.get(Uri.parse(destino)).timeout(const Duration(seconds: 30));
    }
    return _decodificar(respuesta);
  }

  static Map<String, dynamic> _decodificar(http.Response respuesta) {
    if (respuesta.statusCode != 200) {
      throw Exception('HTTP ${respuesta.statusCode}');
    }
    try {
      return Map<String, dynamic>.from(jsonDecode(respuesta.body));
    } catch (_) {
      // Normalmente pasa si el script no está publicado con acceso "Cualquier usuario".
      throw Exception('respuesta no válida');
    }
  }
}
