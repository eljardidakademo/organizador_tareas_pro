import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/dia.dart';
import '../models/tarea.dart';
import '../models/lista_favorita.dart';
import '../models/categoria.dart';
import '../models/rutina.dart';
import '../models/configuracion_app.dart';
import '../services/planificador.dart';
import '../services/persistencia_service.dart';
import '../services/estadisticas_service.dart';
import '../services/rutinas_service.dart';
import 'pantalla_anadir_tarea.dart';
import 'pantalla_listas_favoritas.dart';
import 'pantalla_pomodoro.dart';

const Color colorNeutro = Color(0xFF6B7280); // gris, para tareas sin lista

class PantallaChecklistDia extends StatefulWidget {
  final Dia dia;
  final List<Dia> todosLosDias; // para calcular recomendaciones por categoría
  final List<ListaFavorita> listasFavoritas;
  final List<Categoria> categorias;
  final List<Rutina> rutinas;
  final ConfiguracionApp configuracion;
  final VoidCallback onCambio;

  const PantallaChecklistDia({
    super.key,
    required this.dia,
    required this.todosLosDias,
    required this.listasFavoritas,
    required this.categorias,
    required this.rutinas,
    required this.configuracion,
    required this.onCambio,
  });

  @override
  State<PantallaChecklistDia> createState() => _PantallaChecklistDiaState();
}

class _PantallaChecklistDiaState extends State<PantallaChecklistDia> {
  bool _ocultarCompletadas = false;
  Dia get dia => widget.dia;

  Future<void> _reajustarHoras() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.configuracion.t('reajustar_horas')),
        content: Text(widget.configuracion.t('reajustar_horas_desc')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(widget.configuracion.t('cancelar')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(widget.configuracion.t('reajustar_horas')),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    setState(() {
      dia.tareas = Planificador.reajustarHorasPendientes(
        tareas: dia.tareas,
        fechaDelDia: dia.fecha,
      );
    });
    _notificarCambio();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.configuracion.t('horas_reajustadas'))),
      );
    }
  }

  void _aplicarRutinas() {
    final anadidas = ServicioRutinas.aplicarRutinasCoincidentes(dia, widget.rutinas);
    setState(() {});
    if (anadidas > 0) {
      _notificarCambio();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          anadidas > 0
              ? widget.configuracion.t('rutinas_aplicadas')
              : widget.configuracion.t('sin_rutinas_coincidentes'),
        ),
      ),
    );
  }

  Future<void> _cambiarHoraInicio() async {
    final horaElegida = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(dia.horaInicio),
      helpText: widget.configuracion.t('que_hora_empieza_dia'),
    );
    if (horaElegida == null) return;

    setState(() {
      dia.horaInicio = DateTime(
        dia.fecha.year,
        dia.fecha.month,
        dia.fecha.day,
        horaElegida.hour,
        horaElegida.minute,
      );
      dia.tareas = Planificador.recalcular(
        tareas: dia.tareas,
        horaInicioDia: dia.horaInicio,
      );
    });
    _notificarCambio();
  }

  Future<void> _cambiarHoraFin() async {
    final horaElegida = await showTimePicker(
      context: context,
      initialTime: dia.horaFinDia != null
          ? TimeOfDay.fromDateTime(dia.horaFinDia!)
          : const TimeOfDay(hour: 22, minute: 0),
      helpText: widget.configuracion.t('que_hora_acaba_jornada'),
    );
    if (horaElegida == null) return;

    setState(() {
      dia.horaFinDia = DateTime(
        dia.fecha.year,
        dia.fecha.month,
        dia.fecha.day,
        horaElegida.hour,
        horaElegida.minute,
      );
    });
    widget.onCambio();
  }

  void _notificarCambio() {
    widget.onCambio();
  }

  Color colorDe(Tarea t) {
    if (t.listaOrigenId == null) return colorNeutro;
    final lista = widget.listasFavoritas.where((l) => l.id == t.listaOrigenId).toList();
    if (lista.isEmpty) return colorNeutro;
    return Color(lista.first.colorValue);
  }

  Categoria? categoriaDe(Tarea t) {
    if (t.categoriaId == null) return null;
    final encontradas = widget.categorias.where((c) => c.id == t.categoriaId).toList();
    return encontradas.isEmpty ? null : encontradas.first;
  }

  Future<void> _abrirPantallaListasFavoritas() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PantallaListasFavoritas(listas: widget.listasFavoritas, configuracion: widget.configuracion),
      ),
    );
    setState(() {});
    ServicioPersistencia.guardarListasFavoritas(widget.listasFavoritas);
  }

  Future<void> _abrirPantallaAnadirTarea() async {
    final resultado = await Navigator.of(context).push<NuevaTareaDatos>(
      MaterialPageRoute(
        builder: (_) => PantallaAnadirTarea(
          listas: widget.listasFavoritas,
          categorias: widget.categorias,
          configuracion: widget.configuracion,
        ),
      ),
    );
    if (resultado == null) return;

    final horaInicioTarea = resultado.horaFija && resultado.horaFijaElegida != null
        ? DateTime(
            dia.fecha.year,
            dia.fecha.month,
            dia.fecha.day,
            resultado.horaFijaElegida!.hour,
            resultado.horaFijaElegida!.minute,
          )
        : dia.horaInicio;

    final nuevaTarea = Tarea(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: resultado.nombre,
      horaInicio: horaInicioTarea,
      duracionMinutos: resultado.duracionMinutos,
      prioridadAlta: resultado.prioridadAlta,
      horaFija: resultado.horaFija,
      listaOrigenId: resultado.listaOrigenId,
      categoriaId: resultado.categoriaId,
      orden: dia.tareas.length,
    );

    setState(() {
      dia.tareas = Planificador.anadirTarea(
        tareas: dia.tareas,
        nuevaTarea: nuevaTarea,
        horaInicioDia: dia.horaInicio,
      );
    });
    _notificarCambio();
  }

  void marcarCompletada(Tarea tarea) {
    setState(() {
      tarea.completada = !tarea.completada;
      // El horario se queda fijo: no se reordena ni se recalculan horas al
      // marcar/desmarcar. Para reajustar el resto del día a la hora actual,
      // usa el botón "Reajustar horas" de la barra superior.
    });
    _notificarCambio();
  }

  void _reordenar(int desdeIndex, int haciaIndex) {
    setState(() {
      int destino = haciaIndex;
      if (desdeIndex < haciaIndex) destino -= 1;
      dia.tareas = Planificador.reordenar(
        tareas: dia.tareas,
        desdeIndex: desdeIndex,
        haciaIndex: destino,
        horaInicioDia: dia.horaInicio,
      );
    });
    _notificarCambio();
  }

  void _borrarTarea(Tarea tarea) {
    final indiceOriginal = dia.tareas.indexOf(tarea);
    setState(() {
      dia.tareas.remove(tarea);
      for (int i = 0; i < dia.tareas.length; i++) {
        dia.tareas[i].orden = i;
      }
      dia.tareas = Planificador.recalcular(
        tareas: dia.tareas,
        horaInicioDia: dia.horaInicio,
      );
    });
    _notificarCambio();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.configuracion.t('tarea_eliminada')),
        action: SnackBarAction(
          label: widget.configuracion.t('deshacer'),
          onPressed: () {
            setState(() {
              final indice = indiceOriginal.clamp(0, dia.tareas.length);
              dia.tareas.insert(indice, tarea);
              for (int i = 0; i < dia.tareas.length; i++) {
                dia.tareas[i].orden = i;
              }
              dia.tareas = Planificador.recalcular(
                tareas: dia.tareas,
                horaInicioDia: dia.horaInicio,
              );
            });
            _notificarCambio();
          },
        ),
      ),
    );
  }

  Future<void> _anadirAFavoritos(Tarea tarea) async {
    final lista = await showModalBottomSheet<ListaFavorita>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.configuracion.t('que_lista_anadir'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ...widget.listasFavoritas.map(
              (l) => ListTile(
                leading: CircleAvatar(backgroundColor: Color(l.colorValue)),
                title: Text(l.nombre),
                onTap: () => Navigator.of(context).pop(l),
              ),
            ),
          ],
        ),
      ),
    );
    if (lista == null) return;

    setState(() {
      lista.tareas.add(
        TareaGuardada(nombre: tarea.nombre, duracionMinutos: tarea.duracionMinutos),
      );
    });
    ServicioPersistencia.guardarListasFavoritas(widget.listasFavoritas);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.configuracion.t('anadida_a')} "${lista.nombre}"')),
      );
    }
  }

  Future<int?> _pedirMinutos() async {
    final controller = TextEditingController();
    final minutos = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.configuracion.t('registrar_tiempo')),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: widget.configuracion.t('minutos_invertidos')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(widget.configuracion.t('cancelar')),
          ),
          ElevatedButton(
            onPressed: () {
              final n = int.tryParse(controller.text.trim());
              Navigator.of(context).pop(n);
            },
            child: Text(widget.configuracion.t('anadir_sesion')),
          ),
        ],
      ),
    );
    if (minutos == null || minutos <= 0) return null;
    return minutos;
  }

  String _formateaMinutos(int minutos) {
    final horas = minutos.abs() ~/ 60;
    final mins = minutos.abs() % 60;
    final texto = horas > 0 ? '${horas}h ${mins}min' : '${mins}min';
    return minutos < 0 ? '-$texto' : texto;
  }

  Widget _bloqueComparativaTiempos(Tarea tarea, void Function(void Function()) setModalState) {
    final t = widget.configuracion.t;
    final diferencia = tarea.diferenciaMinutos;
    final estado = diferencia == 0
        ? t('en_tiempo')
        : diferencia > 0
            ? t('por_encima')
            : t('por_debajo');
    final colorEstado = diferencia == 0
        ? Colors.blueGrey
        : diferencia > 0
            ? Colors.red
            : Colors.green;
    final progreso = tarea.duracionMinutos == 0
        ? 0.0
        : (tarea.tiempoRealMinutos / tarea.duracionMinutos).clamp(0.0, 1.0);
    final superaEl80 = tarea.duracionMinutos > 0 &&
        tarea.tiempoRealMinutos / tarea.duracionMinutos >= 0.8 &&
        tarea.tiempoRealMinutos < tarea.duracionMinutos;

    double? recomendacion;
    if (tarea.categoriaId != null) {
      recomendacion = ServicioEstadisticas.desviacionPromedioPorCategoria(
        tarea.categoriaId!,
        widget.todosLosDias,
      );
    }

    return StatefulBuilder(
      builder: (context, setLocalState) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${t('estimado')}: ${_formateaMinutos(tarea.duracionMinutos)}'),
              Text('${t('real')}: ${_formateaMinutos(tarea.tiempoRealMinutos)}'),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progreso,
              minHeight: 8,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              color: diferencia > 0 ? Colors.red : Colors.green,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorEstado.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$estado (${diferencia > 0 ? '+' : ''}${_formateaMinutos(diferencia)})',
                  style: TextStyle(color: colorEstado, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ],
          ),
          if (superaEl80) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                const SizedBox(width: 6),
                Expanded(child: Text(t('aviso_80_por_ciento'), style: const TextStyle(fontSize: 12))),
              ],
            ),
          ],
          if (recomendacion != null) ...[
            const SizedBox(height: 6),
            Text(
              '${t('sugerencia_estimacion')} ${recomendacion.abs().round()}% '
              '${recomendacion > 0 ? t('mas_de_lo_estimado') : t('menos_de_lo_estimado')}',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () async {
              final minutos = await _pedirMinutos();
              if (minutos == null) return;
              tarea.registrarSesion(minutos, origen: 'manual');
              setLocalState(() {});
              setModalState(() {});
              setState(() {});
              _notificarCambio();
            },
            icon: const Icon(Icons.add_circle_outline),
            label: Text(t('registrar_tiempo')),
          ),
          if (tarea.sesiones.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(t('historial_sesiones'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 4),
            ...tarea.sesiones.reversed.take(5).map(
                  (s) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '${s.inicio.day.toString().padLeft(2, '0')}/${s.inicio.month.toString().padLeft(2, '0')} '
                      '${s.inicio.hour.toString().padLeft(2, '0')}:${s.inicio.minute.toString().padLeft(2, '0')} · '
                      '${s.minutos} min${s.origen == 'pomodoro' ? ' 🍅' : ''}',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }

  Future<void> _editarTarea(Tarea tarea) async {
    bool modoTemporizador = false;
    Duration duracionTemp = Duration(minutes: tarea.duracionMinutos);
    final duracionController =
        TextEditingController(text: tarea.duracionMinutos.toString());
    bool prioridadTemp = tarea.prioridadAlta;
    String? categoriaTemp = tarea.categoriaId;
    bool horaFijaTemp = tarea.horaFija;
    TimeOfDay horaFijaElegidaTemp = TimeOfDay.fromDateTime(tarea.horaInicio);
    bool iniciarPomodoroDespues = false;

    final guardar = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tarea.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              Text(widget.configuracion.t('duracion'), style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(value: false, label: Text(widget.configuracion.t('escribir')), icon: const Icon(Icons.keyboard)),
                  ButtonSegment(value: true, label: Text(widget.configuracion.t('girar_temporizador')), icon: const Icon(Icons.timer)),
                ],
                selected: {modoTemporizador},
                onSelectionChanged: (nuevo) => setModalState(() {
                  modoTemporizador = nuevo.first;
                  if (modoTemporizador) {
                    final n = int.tryParse(duracionController.text.trim());
                    if (n != null && n > 0) duracionTemp = Duration(minutes: n);
                  } else {
                    duracionController.text = duracionTemp.inMinutes.toString();
                  }
                }),
              ),
              const SizedBox(height: 12),
              if (!modoTemporizador)
                TextField(
                  controller: duracionController,
                  decoration: InputDecoration(labelText: widget.configuracion.t('minutos'), suffixText: 'min'),
                  keyboardType: TextInputType.number,
                )
              else
                SizedBox(
                  height: 160,
                  child: CupertinoTimerPicker(
                    mode: CupertinoTimerPickerMode.hm,
                    initialTimerDuration: duracionTemp,
                    onTimerDurationChanged: (d) => setModalState(() => duracionTemp = d),
                  ),
                ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(widget.configuracion.t('prioridad_alta')),
                value: prioridadTemp,
                onChanged: (v) => setModalState(() => prioridadTemp = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(widget.configuracion.t('tarea_hora_fija')),
                subtitle: Text(widget.configuracion.t('tarea_hora_fija_desc')),
                value: horaFijaTemp,
                onChanged: (v) => setModalState(() => horaFijaTemp = v),
              ),
              if (horaFijaTemp)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text(widget.configuracion.t('hora_de_inicio')),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          final hora = await showTimePicker(
                            context: context,
                            initialTime: horaFijaElegidaTemp,
                          );
                          if (hora != null) setModalState(() => horaFijaElegidaTemp = hora);
                        },
                        child: Text(
                          horaFijaElegidaTemp.format(context),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              if (widget.categorias.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(widget.configuracion.t('categoria'), style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(widget.configuracion.t('sin_categoria')),
                      selected: categoriaTemp == null,
                      onSelected: (_) => setModalState(() => categoriaTemp = null),
                    ),
                    ...widget.categorias.map(
                      (c) => ChoiceChip(
                        label: Text(c.nombre),
                        avatar: CircleAvatar(backgroundColor: Color(c.colorValue)),
                        selected: categoriaTemp == c.id,
                        onSelected: (_) => setModalState(() => categoriaTemp = c.id),
                      ),
                    ),
                  ],
                ),
              ],
              const Divider(height: 32),
              _bloqueComparativaTiempos(tarea, setModalState),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    iniciarPomodoroDespues = true;
                    Navigator.of(context).pop(true);
                  },
                  icon: const Icon(Icons.timer_outlined),
                  label: Text(widget.configuracion.t('iniciar_pomodoro_con_tarea')),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(widget.configuracion.t('guardar_cambios')),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (guardar != true) return;

    final nuevaDuracion = modoTemporizador
        ? duracionTemp.inMinutes
        : (int.tryParse(duracionController.text.trim()) ?? tarea.duracionMinutos);

    setState(() {
      tarea.duracionMinutos = nuevaDuracion > 0 ? nuevaDuracion : tarea.duracionMinutos;
      tarea.prioridadAlta = prioridadTemp;
      tarea.categoriaId = categoriaTemp;
      tarea.horaFija = horaFijaTemp;
      if (horaFijaTemp) {
        tarea.horaInicio = DateTime(
          dia.fecha.year,
          dia.fecha.month,
          dia.fecha.day,
          horaFijaElegidaTemp.hour,
          horaFijaElegidaTemp.minute,
        );
      }
      dia.tareas = Planificador.recalcular(
        tareas: dia.tareas,
        horaInicioDia: dia.horaInicio,
      );
    });
    _notificarCambio();

    if (iniciarPomodoroDespues && mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PantallaPomodoro(
            tarea: tarea,
            configuracion: widget.configuracion,
            onCambio: _notificarCambio,
          ),
        ),
      );
      setState(() {});
    }
  }

  String formateaHora(DateTime hora) {
    final h = hora.hour.toString().padLeft(2, '0');
    final m = hora.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(dia.fechaFormateada(widget.configuracion.idioma)),
        actions: [
          IconButton(
            onPressed: _abrirPantallaListasFavoritas,
            icon: const Icon(Icons.list_alt),
            tooltip: widget.configuracion.t('mis_listas'),
          ),
          IconButton(
            onPressed: _aplicarRutinas,
            icon: const Icon(Icons.repeat),
            tooltip: widget.configuracion.t('aplicar_rutinas'),
          ),
          IconButton(
            onPressed: _reajustarHoras,
            icon: const Icon(Icons.update),
            tooltip: widget.configuracion.t('reajustar_horas'),
          ),
          IconButton(
            onPressed: () => setState(() => _ocultarCompletadas = !_ocultarCompletadas),
            icon: Icon(_ocultarCompletadas ? Icons.visibility_off : Icons.visibility),
            tooltip: widget.configuracion.t(
              _ocultarCompletadas ? 'mostrar_completadas' : 'ocultar_completadas',
            ),
          ),
          TextButton.icon(
            onPressed: _cambiarHoraInicio,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface,
            ),
            icon: const Icon(Icons.schedule),
            label: Text('${widget.configuracion.t('inicio')} ${formateaHora(dia.horaInicio)}'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Builder(
              builder: (context) {
                final tareasVisibles = _ocultarCompletadas
                    ? dia.tareas.where((t) => !t.completada).toList()
                    : dia.tareas;

                if (tareasVisibles.isEmpty) {
                  return Center(
                    child: Text(
                      dia.tareas.isEmpty
                          ? widget.configuracion.t('aun_no_tareas')
                          : widget.configuracion.t('sin_resultados_busqueda'),
                    ),
                  );
                }

                if (_ocultarCompletadas) {
                  // Con el filtro activo no se permite arrastrar (los índices
                  // visibles no coinciden con los reales de dia.tareas).
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: tareasVisibles.length,
                    itemBuilder: (context, index) =>
                        _construirFilaTarea(tareasVisibles[index], index, permitirArrastrar: false),
                  );
                }

                return ReorderableListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: tareasVisibles.length,
                  onReorder: _reordenar,
                  itemBuilder: (context, index) =>
                      _construirFilaTarea(tareasVisibles[index], index, permitirArrastrar: true),
                );
              },
            ),
          ),
          _AvisoTiempoLibre(dia: dia, onTap: _cambiarHoraFin, configuracion: widget.configuracion),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirPantallaAnadirTarea,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _construirFilaTarea(Tarea tarea, int index, {required bool permitirArrastrar}) {
    final color = colorDe(tarea);
    return Dismissible(
      key: ValueKey(tarea.id),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(widget.configuracion.formaTarjeta.radio),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.amber.shade700,
          borderRadius: BorderRadius.circular(widget.configuracion.formaTarjeta.radio),
        ),
        child: const Icon(Icons.star, color: Colors.white),
      ),
      confirmDismiss: (direccion) async {
        if (direccion == DismissDirection.startToEnd) {
          return true; // deslizar a la derecha: borrar
        }
        await _anadirAFavoritos(tarea); // deslizar a la izquierda: favoritos
        return false; // no se quita de la lista de hoy
      },
      onDismissed: (_) => _borrarTarea(tarea),
      child: GestureDetector(
        onLongPress: () => _editarTarea(tarea),
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.configuracion.formaTarjeta.radio),
            side: BorderSide(color: color, width: 1.2),
          ),
          child: ListTile(
            leading: Checkbox(
              value: tarea.completada,
              activeColor: color,
              onChanged: (_) => marcarCompletada(tarea),
            ),
            title: Text(
              tarea.nombre,
              style: TextStyle(
                decoration: tarea.completada ? TextDecoration.lineThrough : null,
                color: tarea.completada
                    ? Theme.of(context).colorScheme.onSurface.withOpacity(0.4)
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: tarea.prioridadAlta ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Opacity(
              opacity: tarea.completada ? 0.4 : 1.0,
              child: Row(
                children: [
                  Text(
                    '${formateaHora(tarea.horaInicio)} - ${formateaHora(tarea.horaFin)} · ${tarea.duracionMinutos} min',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  if (tarea.sesiones.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: (tarea.diferenciaMinutos > 0 ? Colors.red : Colors.green)
                            .withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${tarea.diferenciaMinutos > 0 ? '+' : ''}${tarea.diferenciaMinutos}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: tarea.diferenciaMinutos > 0 ? Colors.red : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (tarea.horaFija)
                  Icon(Icons.push_pin, size: 18, color: Theme.of(context).colorScheme.primary),
                if (tarea.prioridadAlta) const Icon(Icons.priority_high, color: Colors.red),
                const SizedBox(width: 4),
                if (permitirArrastrar)
                  ReorderableDragStartListener(
                    index: index,
                    child: Icon(
                      Icons.drag_handle,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Muestra, justo debajo de la lista, cuánto tiempo libre queda antes de la
/// hora de fin de jornada del día (o un aviso si las tareas se pasan de esa
/// hora). No aparece si el día no tiene activado el aviso de huecos libres.
class _AvisoTiempoLibre extends StatelessWidget {
  final Dia dia;
  final VoidCallback onTap;
  final ConfiguracionApp configuracion;

  const _AvisoTiempoLibre({required this.dia, required this.onTap, required this.configuracion});

  @override
  Widget build(BuildContext context) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;
    final minutos = dia.minutosLibres;

    if (minutos == null) {
      // Este día no tiene activado el aviso: se ofrece activarlo puntualmente.
      return InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              Icon(Icons.add_alarm, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
              const SizedBox(width: 8),
              Text(
                configuracion.t('activar_aviso_huecos'),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    final seExcede = minutos < 0;
    final minutosAbs = minutos.abs();
    final horas = minutosAbs ~/ 60;
    final mins = minutosAbs % 60;
    final texto = horas > 0 ? '${horas}h ${mins}min' : '${mins}min';

    final colorFondo = seExcede
        ? (esOscuro ? Colors.red.shade900 : Colors.red.shade50)
        : (esOscuro ? Colors.green.shade900 : Colors.green.shade50);
    final colorTexto = seExcede
        ? (esOscuro ? Colors.red.shade100 : Colors.red.shade900)
        : (esOscuro ? Colors.green.shade100 : Colors.green.shade900);

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: colorFondo,
        child: Row(
          children: [
            Icon(
              seExcede ? Icons.warning_amber_rounded : Icons.check_circle_outline,
              color: colorTexto,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                seExcede
                    ? '${configuracion.t('te_pasas')} $texto ${configuracion.t('de_tu_hora_fin')}'
                    : '${configuracion.t('tiempo_libre_restante')}: $texto',
                style: TextStyle(color: colorTexto, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
