import 'package:flutter/material.dart';
import '../models/dia.dart';
import '../models/tarea.dart';
import '../models/lista_favorita.dart';
import '../models/categoria.dart';
import '../models/rutina.dart';
import '../models/configuracion_app.dart';
import '../i18n/traducciones.dart';
import '../services/planificador.dart';
import '../services/persistencia_service.dart';
import '../services/rutinas_service.dart';
import 'pantalla_dias_pager.dart';
import 'pantalla_ajustes.dart';
import 'pantalla_categorias.dart';
import 'pantalla_pomodoro.dart';
import 'pantalla_estadisticas.dart';
import 'pantalla_rutinas.dart';
import 'pantalla_buscar_tareas.dart';

class PantallaMisDias extends StatefulWidget {
  final List<Dia> dias;
  final List<ListaFavorita> listasFavoritas;
  final List<Categoria> categorias;
  final List<Rutina> rutinas;
  final ConfiguracionApp configuracion;

  const PantallaMisDias({
    super.key,
    required this.dias,
    required this.listasFavoritas,
    required this.categorias,
    required this.rutinas,
    required this.configuracion,
  });

  @override
  State<PantallaMisDias> createState() => _PantallaMisDiasState();
}

class _PantallaMisDiasState extends State<PantallaMisDias> {
  bool _vistaCalendario = false;
  DateTime _mesMostrado = DateTime(DateTime.now().year, DateTime.now().month);

  void _ordenarDias() {
    widget.dias.sort((a, b) => a.fecha.compareTo(b.fecha));
  }

  Dia? _buscarDiaPorFecha(DateTime fecha) {
    final coincidencias = widget.dias.where((d) => d.esMismaFecha(fecha)).toList();
    return coincidencias.isEmpty ? null : coincidencias.first;
  }

  Future<void> _crearDiaNuevo({DateTime? fechaPreestablecida}) async {
    DateTime? fechaElegida = fechaPreestablecida;
    if (fechaElegida == null) {
      fechaElegida = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        helpText: widget.configuracion.t('pregunta_que_dia'),
      );
      if (fechaElegida == null) return;
    }

    final existente = _buscarDiaPorFecha(fechaElegida);
    if (existente != null) {
      _abrirDia(existente);
      return;
    }

    TimeOfDay horaElegida = widget.configuracion.horaInicioDefecto;
    if (mounted) {
      final resultado = await showTimePicker(
        context: context,
        initialTime: horaElegida,
        helpText: widget.configuracion.t('que_hora_empieza_dia'),
      );
      if (resultado != null) horaElegida = resultado;
    }

    final nuevoDia = Dia(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fecha: DateTime(fechaElegida.year, fechaElegida.month, fechaElegida.day),
      horaInicio: DateTime(
        fechaElegida.year,
        fechaElegida.month,
        fechaElegida.day,
        horaElegida.hour,
        horaElegida.minute,
      ),
      horaFinDia: widget.configuracion.avisoHuecosActivado
          ? DateTime(
              fechaElegida.year,
              fechaElegida.month,
              fechaElegida.day,
              widget.configuracion.horaFinDefecto.hour,
              widget.configuracion.horaFinDefecto.minute,
            )
          : null,
      tareas: [],
    );

    ServicioRutinas.aplicarRutinasCoincidentes(nuevoDia, widget.rutinas);

    setState(() {
      widget.dias.add(nuevoDia);
      _ordenarDias();
    });
    ServicioPersistencia.guardarDias(widget.dias);
    _abrirDia(nuevoDia);
  }

  Future<void> _duplicarDia(Dia diaOrigen) async {
    final fechaElegida = await showDatePicker(
      context: context,
      initialDate: diaOrigen.fecha.add(const Duration(days: 1)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText:
          '${widget.configuracion.t('pregunta_copiar_a')} "${diaOrigen.fechaFormateada(widget.configuracion.idioma)}"?',
    );
    if (fechaElegida == null) return;

    if (_buscarDiaPorFecha(fechaElegida) != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.configuracion.t('dia_ya_existe'))),
        );
      }
      return;
    }

    final nuevaHoraInicio = DateTime(
      fechaElegida.year,
      fechaElegida.month,
      fechaElegida.day,
      diaOrigen.horaInicio.hour,
      diaOrigen.horaInicio.minute,
    );

    final tareasCopiadas = diaOrigen.tareas
        .map((t) => Tarea(
              id: '${DateTime.now().millisecondsSinceEpoch}_${t.id}',
              nombre: t.nombre,
              horaInicio: nuevaHoraInicio,
              duracionMinutos: t.duracionMinutos,
              prioridadAlta: t.prioridadAlta,
              completada: false,
              listaOrigenId: t.listaOrigenId,
              categoriaId: t.categoriaId,
              orden: t.orden,
            ))
        .toList();

    final nuevoDia = Dia(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fecha: DateTime(fechaElegida.year, fechaElegida.month, fechaElegida.day),
      horaInicio: nuevaHoraInicio,
      horaFinDia: diaOrigen.horaFinDia == null
          ? null
          : DateTime(
              fechaElegida.year,
              fechaElegida.month,
              fechaElegida.day,
              diaOrigen.horaFinDia!.hour,
              diaOrigen.horaFinDia!.minute,
            ),
      tareas: Planificador.recalcular(tareas: tareasCopiadas, horaInicioDia: nuevaHoraInicio),
    );

    setState(() {
      widget.dias.add(nuevoDia);
      _ordenarDias();
    });
    ServicioPersistencia.guardarDias(widget.dias);
  }

  void _eliminarDiaConDeshacer(Dia dia) {
    final indiceOriginal = widget.dias.indexOf(dia);
    setState(() => widget.dias.remove(dia));
    ServicioPersistencia.guardarDias(widget.dias);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.configuracion.t('dia_eliminado')),
        action: SnackBarAction(
          label: widget.configuracion.t('deshacer'),
          onPressed: () {
            setState(() {
              final indice = indiceOriginal.clamp(0, widget.dias.length);
              widget.dias.insert(indice, dia);
              _ordenarDias();
            });
            ServicioPersistencia.guardarDias(widget.dias);
          },
        ),
      ),
    );
  }

  void _abrirDia(Dia dia) {
    _ordenarDias();
    final indice = widget.dias.indexOf(dia);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PantallaDiasPager(
          dias: widget.dias,
          indiceInicial: indice,
          listasFavoritas: widget.listasFavoritas,
          categorias: widget.categorias,
          rutinas: widget.rutinas,
          configuracion: widget.configuracion,
          onCambio: () {
            setState(() {});
            ServicioPersistencia.guardarDias(widget.dias);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _ordenarDias();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.configuracion.t('mis_dias')),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: widget.configuracion.t('buscar_tareas'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PantallaBuscarTareas(
                    dias: widget.dias,
                    listasFavoritas: widget.listasFavoritas,
                    categorias: widget.categorias,
                    rutinas: widget.rutinas,
                    configuracion: widget.configuracion,
                  ),
                ),
              ).then((_) => setState(() {}));
            },
          ),
          IconButton(
            icon: Icon(_vistaCalendario ? Icons.view_list : Icons.calendar_month),
            tooltip: widget.configuracion.t(_vistaCalendario ? 'vista_lista' : 'vista_calendario'),
            onPressed: () => setState(() => _vistaCalendario = !_vistaCalendario),
          ),
          IconButton(
            icon: const Icon(Icons.sell_outlined),
            tooltip: widget.configuracion.t('mis_categorias'),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PantallaCategorias(
                    categorias: widget.categorias,
                    configuracion: widget.configuracion,
                  ),
                ),
              );
              setState(() {});
              ServicioPersistencia.guardarCategorias(widget.categorias);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: widget.configuracion.t('ajustes'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PantallaAjustes(
                    configuracion: widget.configuracion,
                    dias: widget.dias,
                    listasFavoritas: widget.listasFavoritas,
                    categorias: widget.categorias,
                    rutinas: widget.rutinas,
                  ),
                ),
              ).then((_) => setState(() {}));
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (valor) {
              if (valor == 'pomodoro') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PantallaPomodoro(configuracion: widget.configuracion),
                  ),
                );
              } else if (valor == 'estadisticas') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PantallaEstadisticas(
                      dias: widget.dias,
                      categorias: widget.categorias,
                      configuracion: widget.configuracion,
                    ),
                  ),
                );
              } else if (valor == 'rutinas') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PantallaRutinas(
                      rutinas: widget.rutinas,
                      categorias: widget.categorias,
                      configuracion: widget.configuracion,
                    ),
                  ),
                ).then((_) => ServicioPersistencia.guardarRutinas(widget.rutinas));
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'pomodoro',
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 20),
                    const SizedBox(width: 10),
                    Text(widget.configuracion.t('pomodoro')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'estadisticas',
                child: Row(
                  children: [
                    const Icon(Icons.bar_chart, size: 20),
                    const SizedBox(width: 10),
                    Text(widget.configuracion.t('estadisticas')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'rutinas',
                child: Row(
                  children: [
                    const Icon(Icons.repeat, size: 20),
                    const SizedBox(width: 10),
                    Text(widget.configuracion.t('mis_rutinas')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _vistaCalendario ? _construirVistaCalendario() : _construirVistaLista(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _crearDiaNuevo(),
        icon: const Icon(Icons.add),
        label: Text(widget.configuracion.t('nuevo_dia')),
      ),
    );
  }

  Widget _construirVistaLista() {
    return widget.dias.isEmpty
        ? Center(child: Text(widget.configuracion.t('aun_no_dias')))
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: widget.dias.length,
            itemBuilder: (context, index) {
              final dia = widget.dias[index];
              return Dismissible(
                key: ValueKey(dia.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) async => true,
                onDismissed: (_) => _eliminarDiaConDeshacer(dia),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(widget.configuracion.formaTarjeta.radio),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(widget.configuracion.formaTarjeta.radio),
                  ),
                  child: ListTile(
                    onTap: () => _abrirDia(dia),
                    title: Text(
                      dia.fechaFormateada(widget.configuracion.idioma),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${dia.tareas.length} ${widget.configuracion.t('tareas_completadas')} ${dia.tareasCompletadas}',
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: dia.progreso,
                              minHeight: 6,
                              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy),
                      tooltip: widget.configuracion.t('duplicar_dia'),
                      onPressed: () => _duplicarDia(dia),
                    ),
                  ),
                ),
              );
            },
          );
  }

  Widget _construirVistaCalendario() {
    final primerDiaDelMes = DateTime(_mesMostrado.year, _mesMostrado.month, 1);
    final diasEnElMes = DateTime(_mesMostrado.year, _mesMostrado.month + 1, 0).day;
    // weekday: 1=lunes...7=domingo -> huecos vacíos antes del día 1
    final huecosIniciales = primerDiaDelMes.weekday - 1;
    final idioma = widget.configuracion.idioma;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(() {
                  _mesMostrado = DateTime(_mesMostrado.year, _mesMostrado.month - 1);
                }),
              ),
              Text(
                '${Traducciones.mes(idioma, _mesMostrado.month)} ${_mesMostrado.year}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(() {
                  _mesMostrado = DateTime(_mesMostrado.year, _mesMostrado.month + 1);
                }),
              ),
            ],
          ),
        ),
        Row(
          children: List.generate(7, (i) {
            return Expanded(
              child: Center(
                child: Text(
                  Traducciones.diaSemana(idioma, i + 1),
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: huecosIniciales + diasEnElMes,
            itemBuilder: (context, index) {
              if (index < huecosIniciales) return const SizedBox.shrink();
              final numeroDia = index - huecosIniciales + 1;
              final fecha = DateTime(_mesMostrado.year, _mesMostrado.month, numeroDia);
              final dia = _buscarDiaPorFecha(fecha);
              final esHoy = DateTime.now().year == fecha.year &&
                  DateTime.now().month == fecha.month &&
                  DateTime.now().day == fecha.day;

              Color? colorFondo;
              if (dia != null) {
                colorFondo = dia.progreso >= 1
                    ? Colors.green.withOpacity(0.25)
                    : Theme.of(context).colorScheme.primary.withOpacity(0.15);
              }

              return InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  if (dia != null) {
                    _abrirDia(dia);
                  } else {
                    _crearDiaNuevo(fechaPreestablecida: fecha);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: colorFondo,
                    borderRadius: BorderRadius.circular(8),
                    border: esHoy
                        ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$numeroDia',
                      style: TextStyle(
                        fontWeight: dia != null ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
