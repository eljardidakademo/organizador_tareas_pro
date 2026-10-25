import 'dart:async';
import 'package:flutter/material.dart';
import '../models/configuracion_app.dart';
import 'pantalla_pomodoro.dart';

/// Herramienta opcional para usar cuando quieras: un temporizador Pomodoro
/// y un cronómetro. Los dos siguen funcionando aunque cambies de pestaña.
class PantallaTemporizador extends StatefulWidget {
  final ConfiguracionApp configuracion;

  const PantallaTemporizador({super.key, required this.configuracion});

  @override
  State<PantallaTemporizador> createState() => _PantallaTemporizadorState();
}

class _PantallaTemporizadorState extends State<PantallaTemporizador> {
  int _pestana = 0; // 0 = Pomodoro, 1 = Cronómetro

  String _t(String clave) => widget.configuracion.t(clave);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_t('temporizador'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SegmentedButton<int>(
              segments: [
                ButtonSegment(
                  value: 0,
                  icon: const Icon(Icons.timer_outlined),
                  label: Text(_t('pomodoro')),
                ),
                ButtonSegment(
                  value: 1,
                  icon: const Icon(Icons.av_timer),
                  label: Text(_t('cronometro')),
                ),
              ],
              selected: {_pestana},
              onSelectionChanged: (s) => setState(() => _pestana = s.first),
            ),
          ),
          Expanded(
            // IndexedStack mantiene vivos los dos, para que no se paren al cambiar.
            child: IndexedStack(
              index: _pestana,
              children: [
                VistaPomodoro(configuracion: widget.configuracion),
                _VistaCronometro(configuracion: widget.configuracion),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VistaCronometro extends StatefulWidget {
  final ConfiguracionApp configuracion;

  const _VistaCronometro({required this.configuracion});

  @override
  State<_VistaCronometro> createState() => _VistaCronometroState();
}

class _VistaCronometroState extends State<_VistaCronometro> {
  final Stopwatch _cronometro = Stopwatch();
  final List<Duration> _vueltas = [];
  Timer? _refresco;

  String _t(String clave) => widget.configuracion.t(clave);

  @override
  void dispose() {
    _refresco?.cancel();
    super.dispose();
  }

  void _iniciar() {
    _cronometro.start();
    _refresco = Timer.periodic(const Duration(milliseconds: 100), (_) => setState(() {}));
    setState(() {});
  }

  void _pausar() {
    _cronometro.stop();
    _refresco?.cancel();
    setState(() {});
  }

  void _reiniciar() {
    _cronometro
      ..stop()
      ..reset();
    _refresco?.cancel();
    setState(() => _vueltas.clear());
  }

  void _vuelta() => setState(() => _vueltas.insert(0, _cronometro.elapsed));

  String _formatea(Duration d) {
    final h = d.inHours;
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    final dec = ((d.inMilliseconds % 1000) ~/ 100).toString();
    return h > 0 ? '$h:$m:$s.$dec' : '$m:$s.$dec';
  }

  @override
  Widget build(BuildContext context) {
    final corriendo = _cronometro.isRunning;
    final empezado = _cronometro.elapsedMilliseconds > 0;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Text(
              _formatea(_cronometro.elapsed),
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                if (!corriendo)
                  ElevatedButton.icon(
                    onPressed: _iniciar,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(empezado ? _t('reanudar') : _t('iniciar')),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _pausar,
                    icon: const Icon(Icons.pause),
                    label: Text(_t('pausar')),
                  ),
                if (corriendo)
                  OutlinedButton.icon(
                    onPressed: _vuelta,
                    icon: const Icon(Icons.flag_outlined),
                    label: Text(_t('vuelta')),
                  ),
                if (!corriendo && empezado)
                  OutlinedButton.icon(
                    onPressed: _reiniciar,
                    icon: const Icon(Icons.restart_alt),
                    label: Text(_t('reiniciar')),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _vueltas.length,
                itemBuilder: (context, i) => ListTile(
                  dense: true,
                  leading: Text('${_t('vuelta')} ${_vueltas.length - i}'),
                  trailing: Text(
                    _formatea(_vueltas[i]),
                    style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
