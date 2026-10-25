import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/tarea.dart';
import '../models/configuracion_app.dart';
import '../services/persistencia_service.dart';

enum _FasePomodoro { trabajo, descansoCorto, descansoLargo }

/// Pantalla completa del Pomodoro (se usa al lanzarlo desde una tarea).
class PantallaPomodoro extends StatelessWidget {
  /// Si se abre desde una tarea concreta, cada sesión de trabajo completada
  /// se registra automáticamente como tiempo real de esa tarea.
  final Tarea? tarea;
  final ConfiguracionApp configuracion;
  final VoidCallback? onCambio;

  const PantallaPomodoro({super.key, this.tarea, required this.configuracion, this.onCambio});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tarea?.nombre ?? configuracion.t('sin_tarea_asociada'))),
      body: VistaPomodoro(
        tarea: tarea,
        configuracion: configuracion,
        onCambio: onCambio,
        alTerminar: () => Navigator.of(context).pop(),
      ),
    );
  }
}

/// El temporizador Pomodoro en sí, para poder usarlo dentro de otras
/// pantallas (por ejemplo, en la pantalla Temporizador).
class VistaPomodoro extends StatefulWidget {
  final Tarea? tarea;
  final ConfiguracionApp configuracion;
  final VoidCallback? onCambio;

  /// Qué hacer al pulsar "Terminar". Si es null, se reinicia el temporizador.
  final VoidCallback? alTerminar;

  const VistaPomodoro({
    super.key,
    this.tarea,
    required this.configuracion,
    this.onCambio,
    this.alTerminar,
  });

  @override
  State<VistaPomodoro> createState() => _VistaPomodoroState();
}

class _VistaPomodoroState extends State<VistaPomodoro> {
  _FasePomodoro _fase = _FasePomodoro.trabajo;
  int _ciclosCompletados = 0;
  late int _segundosRestantes;
  Timer? _timer;
  bool _corriendo = false;
  bool _modoContinuo = true;
  int _pomodorosHoy = 0;

  ConfiguracionApp get _c => widget.configuracion;

  int _duracionSegundos(_FasePomodoro fase) {
    switch (fase) {
      case _FasePomodoro.trabajo:
        return _c.pomodoroTrabajoMin * 60;
      case _FasePomodoro.descansoCorto:
        return _c.pomodoroDescansoCortoMin * 60;
      case _FasePomodoro.descansoLargo:
        return _c.pomodoroDescansoLargoMin * 60;
    }
  }

  @override
  void initState() {
    super.initState();
    _segundosRestantes = _duracionSegundos(_fase);
    _cargarPomodorosHoy();
  }

  Future<void> _cargarPomodorosHoy() async {
    final todos = await ServicioPersistencia.cargarPomodorosCompletados();
    final hoy = DateTime.now();
    final delDia =
        todos.where((f) => f.year == hoy.year && f.month == hoy.month && f.day == hoy.day);
    if (mounted) setState(() => _pomodorosHoy = delDia.length);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _iniciar() {
    setState(() => _corriendo = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_segundosRestantes <= 1) {
        _completarFase();
      } else {
        setState(() => _segundosRestantes--);
      }
    });
  }

  void _pausar() {
    _timer?.cancel();
    setState(() => _corriendo = false);
  }

  void _terminar() {
    _timer?.cancel();
    if (widget.alTerminar != null) {
      widget.alTerminar!();
      return;
    }
    setState(() {
      _fase = _FasePomodoro.trabajo;
      _ciclosCompletados = 0;
      _segundosRestantes = _duracionSegundos(_fase);
      _corriendo = false;
    });
  }

  Future<void> _completarFase() async {
    _timer?.cancel();
    HapticFeedback.vibrate();
    SystemSound.play(SystemSoundType.click);

    if (_fase == _FasePomodoro.trabajo) {
      // Registrar la sesión de trabajo completada.
      await ServicioPersistencia.registrarPomodoroCompletado();
      widget.tarea?.registrarSesion(_c.pomodoroTrabajoMin, origen: 'pomodoro');
      widget.onCambio?.call();
      _ciclosCompletados++;
      if (mounted) {
        setState(() => _pomodorosHoy++);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_c.t('sesion_completada')), duration: const Duration(seconds: 2)),
        );
      }
    }

    final siguienteFase = _fase != _FasePomodoro.trabajo
        ? _FasePomodoro.trabajo
        : (_ciclosCompletados % _c.pomodoroCiclosParaDescansoLargo == 0
            ? _FasePomodoro.descansoLargo
            : _FasePomodoro.descansoCorto);

    setState(() {
      _fase = siguienteFase;
      _segundosRestantes = _duracionSegundos(_fase);
      _corriendo = false;
    });

    if (_modoContinuo && mounted) {
      _iniciar();
    }
  }

  void _saltarDescanso() {
    if (_fase == _FasePomodoro.trabajo) return;
    _timer?.cancel();
    setState(() {
      _fase = _FasePomodoro.trabajo;
      _segundosRestantes = _duracionSegundos(_fase);
      _corriendo = false;
    });
  }

  String _formateaTiempo(int segundos) {
    final m = (segundos ~/ 60).toString().padLeft(2, '0');
    final s = (segundos % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _etiquetaFase() {
    switch (_fase) {
      case _FasePomodoro.trabajo:
        return _c.t('trabajo');
      case _FasePomodoro.descansoCorto:
        return _c.t('descanso_corto');
      case _FasePomodoro.descansoLargo:
        return _c.t('descanso_largo');
    }
  }

  Color _colorFase() {
    switch (_fase) {
      case _FasePomodoro.trabajo:
        return Colors.redAccent;
      case _FasePomodoro.descansoCorto:
        return Colors.green;
      case _FasePomodoro.descansoLargo:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final duracionTotal = _duracionSegundos(_fase);
    final progreso = duracionTotal == 0 ? 0.0 : 1 - (_segundosRestantes / duracionTotal);
    final color = _colorFase();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              '${_c.t('ciclo')} ${_ciclosCompletados + 1}   ·   ${_c.t('pomodoros_hoy')}: $_pomodorosHoy/${_c.pomodoroObjetivoDiario}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 240,
                      height: 240,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 240,
                            height: 240,
                            child: CircularProgressIndicator(
                              value: progreso,
                              strokeWidth: 10,
                              backgroundColor: color.withValues(alpha: 0.15),
                              color: color,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formateaTiempo(_segundosRestantes),
                                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _etiquetaFase(),
                                style: TextStyle(
                                    color: color, fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SwitchListTile(
              title: Text(_c.t('modo_continuo')),
              value: _modoContinuo,
              onChanged: (v) => setState(() => _modoContinuo = v),
            ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                if (!_corriendo)
                  ElevatedButton.icon(
                    onPressed: _iniciar,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(
                        _segundosRestantes == duracionTotal ? _c.t('iniciar') : _c.t('reanudar')),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _pausar,
                    icon: const Icon(Icons.pause),
                    label: Text(_c.t('pausar')),
                  ),
                if (_fase != _FasePomodoro.trabajo)
                  OutlinedButton.icon(
                    onPressed: _saltarDescanso,
                    icon: const Icon(Icons.skip_next),
                    label: Text(_c.t('saltar_descanso')),
                  ),
                OutlinedButton.icon(
                  onPressed: _terminar,
                  icon: const Icon(Icons.stop),
                  label: Text(_c.t('terminar')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
