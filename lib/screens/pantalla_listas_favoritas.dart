import 'package:flutter/material.dart';
import '../models/lista_favorita.dart';
import '../models/configuracion_app.dart';

IconData _iconoDesdeNombre(String nombre) {
  switch (nombre) {
    case 'work':
      return Icons.work;
    case 'home':
      return Icons.home;
    case 'fitness_center':
      return Icons.fitness_center;
    case 'school':
      return Icons.school;
    case 'shopping_cart':
      return Icons.shopping_cart;
    case 'restaurant':
      return Icons.restaurant;
    case 'favorite':
      return Icons.favorite;
    case 'star':
      return Icons.star;
    default:
      return Icons.label;
  }
}

class PantallaListasFavoritas extends StatefulWidget {
  final List<ListaFavorita> listas;
  final ConfiguracionApp configuracion;

  const PantallaListasFavoritas({super.key, required this.listas, required this.configuracion});

  @override
  State<PantallaListasFavoritas> createState() =>
      _PantallaListasFavoritasState();
}

class _PantallaListasFavoritasState extends State<PantallaListasFavoritas> {
  String _t(String clave) => widget.configuracion.t(clave);

  Future<void> _crearOEditarLista({ListaFavorita? listaExistente}) async {
    final nombreController =
        TextEditingController(text: listaExistente?.nombre ?? '');
    String iconoElegido = listaExistente?.icono ?? paletaIconosListas.first;
    int colorElegido = listaExistente?.colorValue ?? paletaColoresListas.first;

    final guardar = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(listaExistente == null ? _t('nueva_lista') : _t('editar_lista')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: InputDecoration(labelText: _t('nombre')),
                ),
                const SizedBox(height: 16),
                Text(_t('icono')),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: paletaIconosListas.map((icono) {
                    final seleccionado = icono == iconoElegido;
                    return GestureDetector(
                      onTap: () =>
                          setDialogState(() => iconoElegido = icono),
                      child: CircleAvatar(
                        backgroundColor: seleccionado
                            ? Color(colorElegido)
                            : Colors.grey.shade200,
                        child: Icon(
                          _iconoDesdeNombre(icono),
                          color: seleccionado ? Colors.white : Colors.black54,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text(_t('color')),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: paletaColoresListas.map((color) {
                    final seleccionado = color == colorElegido;
                    return GestureDetector(
                      onTap: () => setDialogState(() => colorElegido = color),
                      child: CircleAvatar(
                        backgroundColor: Color(color),
                        radius: seleccionado ? 18 : 14,
                        child: seleccionado
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 16)
                            : null,
                      ),
                    );
                  }).toList(),
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
      if (listaExistente != null) {
        listaExistente.nombre = nombreController.text.trim();
        listaExistente.icono = iconoElegido;
        listaExistente.colorValue = colorElegido;
      } else {
        widget.listas.add(
          ListaFavorita(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            nombre: nombreController.text.trim(),
            icono: iconoElegido,
            colorValue: colorElegido,
            tareas: [],
          ),
        );
      }
    });
  }

  Future<void> _eliminarLista(ListaFavorita lista) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_t('eliminar_lista')),
        content: Text('${_t('seguro_eliminar_lista')} "${lista.nombre}"?'),
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
      setState(() => widget.listas.remove(lista));
    }
  }

  Future<void> _crearOEditarTareaGuardada(
    ListaFavorita lista, {
    TareaGuardada? tareaExistente,
  }) async {
    final nombreController =
        TextEditingController(text: tareaExistente?.nombre ?? '');
    final duracionController = TextEditingController(
      text: tareaExistente?.duracionMinutos.toString() ?? '',
    );

    final guardar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tareaExistente == null ? _t('nueva_tarea_guardada') : _t('editar_tarea')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              decoration: InputDecoration(labelText: _t('nombre_tarea')),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: duracionController,
              decoration: InputDecoration(labelText: _t('duracion_tipica_min')),
              keyboardType: TextInputType.number,
            ),
          ],
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
    );

    final duracion = int.tryParse(duracionController.text.trim());
    if (guardar != true ||
        nombreController.text.trim().isEmpty ||
        duracion == null ||
        duracion <= 0) {
      return;
    }

    setState(() {
      if (tareaExistente != null) {
        tareaExistente.nombre = nombreController.text.trim();
        tareaExistente.duracionMinutos = duracion;
      } else {
        lista.tareas.add(
          TareaGuardada(nombre: nombreController.text.trim(), duracionMinutos: duracion),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_t('mis_listas'))),
      body: widget.listas.isEmpty
          ? Center(child: Text(_t('aun_no_listas')))
          : ListView(
              padding: const EdgeInsets.all(12),
              children: widget.listas.map((lista) {
                final color = Color(lista.colorValue);
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(widget.configuracion.formaTarjeta.radio),
                    side: BorderSide(color: color, width: 1.2),
                  ),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: color,
                      child: Icon(_iconoDesdeNombre(lista.icono), color: Colors.white),
                    ),
                    title: Text(lista.nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${lista.tareas.length} ${_t('tareas_guardadas')}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () =>
                              _crearOEditarLista(listaExistente: lista),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () => _eliminarLista(lista),
                        ),
                      ],
                    ),
                    children: [
                      ...lista.tareas.map(
                        (t) => ListTile(
                          title: Text(t.nombre),
                          subtitle: Text('${t.duracionMinutos} min'),
                          onTap: () => _crearOEditarTareaGuardada(
                            lista,
                            tareaExistente: t,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () =>
                                setState(() => lista.tareas.remove(t)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TextButton.icon(
                          onPressed: () => _crearOEditarTareaGuardada(lista),
                          icon: const Icon(Icons.add),
                          label: Text(_t('anadir_tarea_a_lista')),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _crearOEditarLista(),
        icon: const Icon(Icons.add),
        label: Text(_t('nueva_lista')),
      ),
    );
  }
}
