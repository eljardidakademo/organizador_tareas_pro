import 'package:flutter/material.dart';
import '../models/dia.dart';
import '../models/categoria.dart';
import '../models/configuracion_app.dart';
import '../services/estadisticas_service.dart';
import '../services/persistencia_service.dart';

class PantallaEstadisticas extends StatefulWidget {
  final List<Dia> dias;
  final List<Categoria> categorias;
  final ConfiguracionApp configuracion;

  const PantallaEstadisticas({
    super.key,
    required this.dias,
    required this.categorias,
    required this.configuracion,
  });

  @override
  State<PantallaEstadisticas> createState() => _PantallaEstadisticasState();
}

class _PantallaEstadisticasState extends State<PantallaEstadisticas> {
  List<DateTime> _pomodoros = [];
  bool _cargando = true;

  String _t(String clave) => widget.configuracion.t(clave);

  @override
  void initState() {
    super.initState();
    _cargarPomodoros();
  }

  Future<void> _cargarPomodoros() async {
    final pomodoros = await ServicioPersistencia.cargarPomodorosCompletados();
    if (mounted) {
      setState(() {
        _pomodoros = pomodoros;
        _cargando = false;
      });
    }
  }

  (DateTime, DateTime) _rangoHoy() {
    final hoy = DateTime.now();
    final inicio = DateTime(hoy.year, hoy.month, hoy.day);
    final fin = DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59);
    return (inicio, fin);
  }

  (DateTime, DateTime) _rangoSemana() {
    final hoy = DateTime.now();
    final inicioSemana =
        DateTime(hoy.year, hoy.month, hoy.day).subtract(Duration(days: hoy.weekday - 1));
    final finSemana =
        inicioSemana.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    return (inicioSemana, finSemana);
  }

  (DateTime, DateTime) _rangoMes() {
    final hoy = DateTime.now();
    final inicio = DateTime(hoy.year, hoy.month, 1);
    final fin = DateTime(hoy.year, hoy.month + 1, 0, 23, 59, 59);
    return (inicio, fin);
  }

  String _formateaMinutos(int minutos) {
    final horas = minutos ~/ 60;
    final mins = minutos % 60;
    return horas > 0 ? '${horas}h ${mins}min' : '${mins}min';
  }

  Widget _tarjetaPeriodo(String titulo, DateTime inicio, DateTime fin) {
    final tiempo = ServicioEstadisticas.tiempoTrabajadoEnRango(widget.dias, inicio, fin);
    final tareas = ServicioEstadisticas.tareasCompletadasEnRango(widget.dias, inicio, fin);
    final pomodoros = ServicioEstadisticas.pomodorosEnRango(_pomodoros, inicio, fin);

    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.configuracion.formaTarjeta.radio),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Text(_formateaMinutos(tiempo),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(_t('tiempo_trabajado'), style: const TextStyle(fontSize: 11)),
              const SizedBox(height: 8),
              Text('$tareas', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(_t('tareas_completadas_stat'), style: const TextStyle(fontSize: 11)),
              const SizedBox(height: 8),
              Text('$pomodoros 🍅', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(_t('pomodoros_realizados'), style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _seccion(String titulo, Widget contenido) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.configuracion.formaTarjeta.radio),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              contenido,
            ],
          ),
        ),
      ),
    );
  }

  Widget _graficoTendencia(List<int> minutosPorDia) {
    final maximo = minutosPorDia.isEmpty
        ? 1
        : (minutosPorDia.reduce((a, b) => a > b ? a : b)).clamp(1, 999999);
    return SizedBox(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: minutosPorDia.map((m) {
          final alturaRelativa = m / maximo;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 70 * alturaRelativa.clamp(0.03, 1.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${m}m', style: const TextStyle(fontSize: 9)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(
        appBar: AppBar(title: Text(_t('estadisticas'))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final (inicioHoy, finHoy) = _rangoHoy();
    final (inicioSemana, finSemana) = _rangoSemana();
    final (inicioMes, finMes) = _rangoMes();

    final tiempoPorCategoria = ServicioEstadisticas.tiempoPorCategoria(widget.dias);
    final (estimadoTotal, realTotal) = ServicioEstadisticas.estimadoVsRealTotal(widget.dias);
    final franjaHora = ServicioEstadisticas.franjaMasProductiva(widget.dias);
    final tasaAcierto = ServicioEstadisticas.tasaAciertoEstimaciones(widget.dias);
    final categoriaRetraso =
        ServicioEstadisticas.categoriaConMasRetraso(widget.categorias, widget.dias);
    final racha = ServicioEstadisticas.rachaDiasConTareasCompletadas(widget.dias);
    final tendencia = ServicioEstadisticas.tendenciaUltimos7Dias(widget.dias);

    return Scaffold(
      appBar: AppBar(title: Text(_t('estadisticas'))),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Row(
            children: [
              _tarjetaPeriodo(_t('hoy'), inicioHoy, finHoy),
              const SizedBox(width: 8),
              _tarjetaPeriodo(_t('esta_semana'), inicioSemana, finSemana),
              const SizedBox(width: 8),
              _tarjetaPeriodo(_t('este_mes'), inicioMes, finMes),
            ],
          ),

          _seccion(
            _t('tendencia_ultimos_7_dias'),
            tendencia.every((m) => m == 0)
                ? Text(_t('sin_datos_suficientes'))
                : _graficoTendencia(tendencia),
          ),

          _seccion(
            _t('tiempo_por_categoria'),
            tiempoPorCategoria.isEmpty
                ? Text(_t('sin_datos_suficientes'))
                : Column(
                    children: tiempoPorCategoria.entries.map((entry) {
                      final categoria =
                          widget.categorias.where((c) => c.id == entry.key).toList();
                      final nombre =
                          categoria.isEmpty ? _t('sin_categoria') : categoria.first.nombre;
                      final color =
                          categoria.isEmpty ? Colors.grey : Color(categoria.first.colorValue);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            CircleAvatar(radius: 6, backgroundColor: color),
                            const SizedBox(width: 8),
                            Expanded(child: Text(nombre)),
                            Text(_formateaMinutos(entry.value)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),

          _seccion(
            _t('estimado_vs_real'),
            estimadoTotal == 0
                ? Text(_t('sin_datos_suficientes'))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_t('estimado')}: ${_formateaMinutos(estimadoTotal)}'),
                      Text('${_t('real')}: ${_formateaMinutos(realTotal)}'),
                    ],
                  ),
          ),

          _seccion(
            _t('franja_mas_productiva'),
            franjaHora == null
                ? Text(_t('sin_datos_suficientes'))
                : Text(
                    '${franjaHora.toString().padLeft(2, '0')}:00 - ${franjaHora.toString().padLeft(2, '0')}:59'),
          ),

          _seccion(
            _t('tasa_acierto'),
            tasaAcierto == null ? Text(_t('sin_datos_suficientes')) : Text('${tasaAcierto.round()}%'),
          ),

          _seccion(
            _t('categoria_mas_se_retrasa'),
            categoriaRetraso == null
                ? Text(_t('sin_datos_suficientes'))
                : Row(
                    children: [
                      CircleAvatar(radius: 6, backgroundColor: Color(categoriaRetraso.$1.colorValue)),
                      const SizedBox(width: 8),
                      Text('${categoriaRetraso.$1.nombre}: +${categoriaRetraso.$2.round()}%'),
                    ],
                  ),
          ),

          _seccion(_t('racha_dias'), Text('$racha ${_t('dias')}')),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
