import 'package:flutter/material.dart';
import '../models/categoria.dart';
import '../models/configuracion_app.dart';

class PantallaCategorias extends StatefulWidget {
  final List<Categoria> categorias;
  final ConfiguracionApp configuracion;

  const PantallaCategorias({super.key, required this.categorias, required this.configuracion});

  @override
  State<PantallaCategorias> createState() => _PantallaCategoriasState();
}

class _PantallaCategoriasState extends State<PantallaCategorias> {
  String _t(String clave) => widget.configuracion.t(clave);

  Future<void> _crearOEditar({Categoria? existente}) async {
    final nombreController = TextEditingController(text: existente?.nombre ?? '');
    int colorElegido = existente?.colorValue ?? paletaColoresCategorias.first;

    final guardar = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existente == null ? _t('nueva_categoria') : _t('editar_categoria')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nombreController,
                decoration: InputDecoration(labelText: _t('nombre')),
              ),
              const SizedBox(height: 16),
              Text(_t('color')),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: paletaColoresCategorias.map((color) {
                  final seleccionado = color == colorElegido;
                  return GestureDetector(
                    onTap: () => setDialogState(() => colorElegido = color),
                    child: CircleAvatar(
                      backgroundColor: Color(color),
                      radius: seleccionado ? 18 : 14,
                      child: seleccionado
                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                          : null,
                    ),
                  );
                }).toList(),
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
      ),
    );

    if (guardar != true || nombreController.text.trim().isEmpty) return;

    setState(() {
      if (existente != null) {
        existente.nombre = nombreController.text.trim();
        existente.colorValue = colorElegido;
      } else {
        widget.categorias.add(
          Categoria(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            nombre: nombreController.text.trim(),
            colorValue: colorElegido,
          ),
        );
      }
    });
  }

  Future<void> _eliminar(Categoria categoria) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_t('eliminar_categoria')),
        content: Text('${_t('seguro_eliminar_lista')} "${categoria.nombre}"?'),
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
      setState(() => widget.categorias.remove(categoria));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_t('mis_categorias'))),
      body: widget.categorias.isEmpty
          ? Center(child: Text(_t('aun_no_categorias')))
          : ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
              children: widget.categorias.map((categoria) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(widget.configuracion.formaTarjeta.radio),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: Color(categoria.colorValue)),
                    title: Text(categoria.nombre),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _crearOEditar(existente: categoria),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () => _eliminar(categoria),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _crearOEditar(),
        icon: const Icon(Icons.add),
        label: Text(_t('nueva_categoria')),
      ),
    );
  }
}
