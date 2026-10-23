import 'package:flutter/material.dart';
import '../models/rutina.dart';
import '../models/categoria.dart';
import '../models/configuracion_app.dart';

class PantallaRutinas extends StatefulWidget {
  final List<Rutina> rutinas;
  final List<Categoria> categorias;
  final ConfiguracionApp configuracion;

  const PantallaRutinas({
    super.key,
    required this.rutinas,
    required this.categorias,
    required this.configuracion,
  });

  @override
  State<PantallaRutinas> createState() => _PantallaRutinasState();
}

class _PantallaRutinasState extends State<PantallaRutinas> {
  String _t(String clave) => widget.configuracion.t(clave);

  List<String> get _clavesDias => [
        'lunes_corto',
        'martes_corto',
        'miercoles_corto',
        'jueves_corto',
        'viernes_corto',
        'sabado_corto',
        'domingo_corto',
      ];

  Future<void> _crearOEditarRutina({Rutina? existente}) async {
    final nombreController = TextEditingController(text: existente?.nombre ?? '');
    Set<int> diasElegidos = {...(existente?.diasSemana ?? {})};

    final guardar = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existente == null ? _t('nueva_rutina') : _t('editar_rutina')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: InputDecoration(labelText: _t('nombre_rutina')),
                ),
                const SizedBox(height: 16),
                Text(_t('dias_de_la_semana')),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: List.generate(7, (i) {
                    final numeroDia = i + 1; // 1=lunes ... 7=domingo
                    final seleccionado = diasElegidos.contains(numeroDia);
                    return FilterChip(
                      label: Text(_t(_clavesDias[i])),
                      selected: seleccionado,
                      onSelected: (v) => setDialogState(() {
                        if (v) {
                          diasElegidos.add(numeroDia);
                        } else {
                          diasElegidos.remove(numeroDia);
                        }
                      }),
                    );
                  }),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(_t('cancelar')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(_t('guardar')),
            ),
          ],
        ),
      ),
    );

    if (guardar != true || nombreController.text.trim().isEmpty) return;

    setState(() {
      if (existente != null) {
        existente.nombre = nombreController.text.trim();
        existente.diasSemana = diasElegidos;
      } else {
        widget.rutinas.add(
          Rutina(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            nombre: nombreController.text.trim(),
            diasSemana: diasElegidos,
          ),
        );
      }
    });
  }

  Future<void> _eliminarRutina(Rutina rutina) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_t('eliminar_rutina')),
        content: Text('${_t('seguro_eliminar_lista')} "${rutina.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(_t('cancelar')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(_t('eliminar')),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      setState(() => widget.rutinas.remove(rutina));
    }
  }

  Future<void> _crearOEditarTarea(Rutina rutina, {TareaRutina? existente}) async {
    final nombreController = TextEditingController(text: existente?.nombre ?? '');
    final duracionController =
        TextEditingController(text: existente?.duracionMinutos.toString() ?? '');
    bool prioridadTemp = existente?.prioridadAlta ?? false;
    String? categoriaTemp = existente?.categoriaId;

    final guardar = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existente == null ? _t('anadir_tarea_a_rutina') : _t('editar_tarea')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: InputDecoration(labelText: _t('nombre_tarea')),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: duracionController,
                  decoration: InputDecoration(labelText: _t('duracion_estimada_min')),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_t('prioridad_alta')),
                  value: prioridadTemp,
                  onChanged: (v) => setDialogState(() => prioridadTemp = v),
                ),
                if (widget.categorias.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(_t('categoria')),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text(_t('sin_categoria')),
                        selected: categoriaTemp == null,
                        onSelected: (_) => setDialogState(() => categoriaTemp = null),
                      ),
                      ...widget.categorias.map(
                        (c) => ChoiceChip(
                          label: Text(c.nombre),
                          avatar: CircleAvatar(backgroundColor: Color(c.colorValue)),
                          selected: categoriaTemp == c.id,
                          onSelected: (_) => setDialogState(() => categoriaTemp = c.id),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(_t('cancelar')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(_t('guardar')),
            ),
          ],
        ),
      ),
    );

    final duracion = int.tryParse(duracionController.text.trim());
    if (guardar != true || nombreController.text.trim().isEmpty || duracion == null || duracion <= 0) {
      return;
    }

    setState(() {
      if (existente != null) {
        existente.nombre = nombreController.text.trim();
        existente.duracionMinutos = duracion;
        existente.prioridadAlta = prioridadTemp;
        existente.categoriaId = categoriaTemp;
      } else {
        rutina.tareas.add(
          TareaRutina(
            nombre: nombreController.text.trim(),
            duracionMinutos: duracion,
            prioridadAlta: prioridadTemp,
            categoriaId: categoriaTemp,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_t('mis_rutinas'))),
      body: widget.rutinas.isEmpty
          ? Center(child: Text(_t('aun_no_rutinas')))
          : ListView(
              padding: const EdgeInsets.all(12),
              children: widget.rutinas.map((rutina) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(widget.configuracion.formaTarjeta.radio),
                  ),
                  child: ExpansionTile(
                    title: Text(rutina.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      rutina.diasSemana.isEmpty
                          ? '—'
                          : (List.generate(7, (i) => i + 1)
                              ..retainWhere((d) => rutina.diasSemana.contains(d)))
                              .map((d) => _t(_clavesDias[d - 1]))
                              .join(', '),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: rutina.activa,
                          onChanged: (v) => setState(() => rutina.activa = v),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _crearOEditarRutina(existente: rutina),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () => _eliminarRutina(rutina),
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(_t('tareas_de_la_rutina'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                      ...rutina.tareas.map(
                        (t) => ListTile(
                          title: Text(t.nombre),
                          subtitle: Text('${t.duracionMinutos} min'),
                          onTap: () => _crearOEditarTarea(rutina, existente: t),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => setState(() => rutina.tareas.remove(t)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TextButton.icon(
                          onPressed: () => _crearOEditarTarea(rutina),
                          icon: const Icon(Icons.add),
                          label: Text(_t('anadir_tarea_a_rutina')),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _crearOEditarRutina(),
        icon: const Icon(Icons.add),
        label: Text(_t('nueva_rutina')),
      ),
    );
  }
}
