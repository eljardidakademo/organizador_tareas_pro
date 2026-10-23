import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/lista_favorita.dart';
import '../models/categoria.dart';
import '../models/configuracion_app.dart';

/// Resultado que devuelve esta pantalla al guardar: los datos necesarios
/// para que Planificador.anadirTarea() construya la Tarea definitiva.
class NuevaTareaDatos {
  final String nombre;
  final int duracionMinutos;
  final bool prioridadAlta;
  final String? listaOrigenId;
  final String? categoriaId;
  final bool horaFija;
  final TimeOfDay? horaFijaElegida;

  NuevaTareaDatos({
    required this.nombre,
    required this.duracionMinutos,
    required this.prioridadAlta,
    this.listaOrigenId,
    this.categoriaId,
    this.horaFija = false,
    this.horaFijaElegida,
  });
}

class PantallaAnadirTarea extends StatefulWidget {
  final List<ListaFavorita> listas;
  final List<Categoria> categorias;
  final ConfiguracionApp configuracion;

  const PantallaAnadirTarea({
    super.key,
    required this.listas,
    required this.categorias,
    required this.configuracion,
  });

  @override
  State<PantallaAnadirTarea> createState() => _PantallaAnadirTareaState();
}

class _PantallaAnadirTareaState extends State<PantallaAnadirTarea> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _duracionController = TextEditingController();
  bool _prioridadAlta = false;
  bool _horaFija = false;
  TimeOfDay _horaFijaElegida = TimeOfDay.now();
  String? _listaSeleccionadaId;
  String? _categoriaSeleccionadaId;

  // false = escribir con teclado, true = girar temporizador visual
  bool _modoTemporizador = false;
  Duration _duracionTemporizador = const Duration(minutes: 15);

  String _t(String clave) => widget.configuracion.t(clave);

  @override
  void dispose() {
    _nombreController.dispose();
    _duracionController.dispose();
    super.dispose();
  }

  /// Al elegir una tarea guardada de una lista favorita, se rellenan
  /// automáticamente el nombre y la duración (el usuario puede ajustarlos).
  void _elegirDesdeFavorita(ListaFavorita lista, TareaGuardada guardada) {
    setState(() {
      _nombreController.text = guardada.nombre;
      _duracionController.text = guardada.duracionMinutos.toString();
      _duracionTemporizador = Duration(minutes: guardada.duracionMinutos);
      _listaSeleccionadaId = lista.id;
      _prioridadAlta = guardada.prioridadAlta;
      // Solo si la categoría sigue existiendo (puede haberse borrado).
      _categoriaSeleccionadaId =
          widget.categorias.any((c) => c.id == guardada.categoriaId) ? guardada.categoriaId : null;
    });
  }

  int get _duracionFinalEnMinutos => _modoTemporizador
      ? _duracionTemporizador.inMinutes
      : int.parse(_duracionController.text.trim());

  void _guardar() {
    if (!_modoTemporizador && !_formKey.currentState!.validate()) return;
    if (_modoTemporizador && _duracionTemporizador.inMinutes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('introduce_minutos_validos'))),
      );
      return;
    }
    if (_nombreController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('escribe_nombre'))),
      );
      return;
    }
    final datos = NuevaTareaDatos(
      nombre: _nombreController.text.trim(),
      duracionMinutos: _duracionFinalEnMinutos,
      prioridadAlta: _prioridadAlta,
      listaOrigenId: _listaSeleccionadaId,
      categoriaId: _categoriaSeleccionadaId,
      horaFija: _horaFija,
      horaFijaElegida: _horaFija ? _horaFijaElegida : null,
    );
    Navigator.of(context).pop(datos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_t('anadir_tarea'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: _t('nombre_tarea')),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? _t('escribe_nombre') : null,
              ),
              const SizedBox(height: 12),
              Text(
                _t('duracion_estimada_min').replaceFirst(' (minutos)', ''),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: false,
                    label: Text(_t('escribir')),
                    icon: const Icon(Icons.keyboard),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text(_t('girar_temporizador')),
                    icon: const Icon(Icons.timer),
                  ),
                ],
                selected: {_modoTemporizador},
                onSelectionChanged: (nuevo) {
                  setState(() {
                    _modoTemporizador = nuevo.first;
                    // Mantenemos ambos valores sincronizados al cambiar de modo
                    if (_modoTemporizador) {
                      final n = int.tryParse(_duracionController.text.trim());
                      if (n != null && n > 0) {
                        _duracionTemporizador = Duration(minutes: n);
                      }
                    } else {
                      _duracionController.text =
                          _duracionTemporizador.inMinutes.toString();
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              if (!_modoTemporizador)
                TextFormField(
                  controller: _duracionController,
                  decoration: InputDecoration(
                    labelText: _t('minutos'),
                    suffixText: 'min',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n <= 0) return _t('introduce_minutos_validos');
                    return null;
                  },
                )
              else
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CupertinoTimerPicker(
                    mode: CupertinoTimerPickerMode.hm,
                    initialTimerDuration: _duracionTemporizador,
                    onTimerDurationChanged: (nuevaDuracion) {
                      setState(() => _duracionTemporizador = nuevaDuracion);
                    },
                  ),
                ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: Text(_t('prioridad_alta')),
                value: _prioridadAlta,
                onChanged: (v) => setState(() => _prioridadAlta = v),
              ),
              SwitchListTile(
                title: Text(_t('tarea_hora_fija')),
                subtitle: Text(_t('tarea_hora_fija_desc')),
                value: _horaFija,
                onChanged: (v) => setState(() => _horaFija = v),
              ),
              if (_horaFija)
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: Row(
                    children: [
                      Text(_t('hora_de_inicio')),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          final hora = await showTimePicker(
                            context: context,
                            initialTime: _horaFijaElegida,
                          );
                          if (hora != null) setState(() => _horaFijaElegida = hora);
                        },
                        child: Text(
                          _horaFijaElegida.format(context),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              if (widget.categorias.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(_t('categoria'), style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(_t('sin_categoria')),
                      selected: _categoriaSeleccionadaId == null,
                      onSelected: (_) => setState(() => _categoriaSeleccionadaId = null),
                    ),
                    ...widget.categorias.map(
                      (c) => ChoiceChip(
                        label: Text(c.nombre),
                        avatar: CircleAvatar(backgroundColor: Color(c.colorValue)),
                        selected: _categoriaSeleccionadaId == c.id,
                        onSelected: (_) => setState(() => _categoriaSeleccionadaId = c.id),
                      ),
                    ),
                  ],
                ),
              ],
              const Divider(height: 32),
              Text(
                _t('o_elige_desde_favoritas'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...widget.listas.map(
                (lista) => ExpansionTile(
                  title: Text(lista.nombre),
                  children: lista.tareas
                      .map(
                        (t) => ListTile(
                          title: Text(t.nombre),
                          subtitle: Text('${t.duracionMinutos} min'),
                          onTap: () => _elegirDesdeFavorita(lista, t),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _guardar,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(_t('guardar_tarea')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
