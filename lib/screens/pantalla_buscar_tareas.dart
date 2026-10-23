import 'package:flutter/material.dart';
import '../models/dia.dart';
import '../models/tarea.dart';
import '../models/categoria.dart';
import '../models/lista_favorita.dart';
import '../models/rutina.dart';
import '../models/configuracion_app.dart';
import '../services/persistencia_service.dart';
import 'pantalla_dias_pager.dart';

class PantallaBuscarTareas extends StatefulWidget {
  final List<Dia> dias;
  final List<ListaFavorita> listasFavoritas;
  final List<Categoria> categorias;
  final List<Rutina> rutinas;
  final ConfiguracionApp configuracion;

  const PantallaBuscarTareas({
    super.key,
    required this.dias,
    required this.listasFavoritas,
    required this.categorias,
    required this.rutinas,
    required this.configuracion,
  });

  @override
  State<PantallaBuscarTareas> createState() => _PantallaBuscarTareasState();
}

class _Resultado {
  final Dia dia;
  final Tarea tarea;
  _Resultado(this.dia, this.tarea);
}

class _PantallaBuscarTareasState extends State<PantallaBuscarTareas> {
  final _controller = TextEditingController();
  String _consulta = '';

  String _t(String clave) => widget.configuracion.t(clave);

  List<_Resultado> get _resultados {
    if (_consulta.trim().isEmpty) return [];
    final consultaMinuscula = _consulta.trim().toLowerCase();
    final resultados = <_Resultado>[];

    for (final dia in widget.dias) {
      for (final tarea in dia.tareas) {
        final nombreCoincide = tarea.nombre.toLowerCase().contains(consultaMinuscula);
        String nombreCategoria = '';
        if (tarea.categoriaId != null) {
          final coincidencias = widget.categorias.where((c) => c.id == tarea.categoriaId);
          if (coincidencias.isNotEmpty) nombreCategoria = coincidencias.first.nombre.toLowerCase();
        }
        final categoriaCoincide = nombreCategoria.contains(consultaMinuscula);
        if (nombreCoincide || categoriaCoincide) {
          resultados.add(_Resultado(dia, tarea));
        }
      }
    }
    resultados.sort((a, b) => a.dia.fecha.compareTo(b.dia.fecha));
    return resultados;
  }

  void _abrirResultado(_Resultado resultado) {
    final diasOrdenados = [...widget.dias]..sort((a, b) => a.fecha.compareTo(b.fecha));
    final indice = diasOrdenados.indexOf(resultado.dia);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PantallaDiasPager(
          dias: diasOrdenados,
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
    final resultados = _resultados;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: _t('buscar_tareas_hint'),
            border: InputBorder.none,
          ),
          onChanged: (v) => setState(() => _consulta = v),
        ),
      ),
      body: _consulta.trim().isEmpty
          ? const SizedBox.shrink()
          : resultados.isEmpty
              ? Center(child: Text(_t('sin_resultados_busqueda')))
              : ListView.builder(
                  itemCount: resultados.length,
                  itemBuilder: (context, index) {
                    final r = resultados[index];
                    return ListTile(
                      title: Text(r.tarea.nombre),
                      subtitle: Text(
                        '${r.dia.fechaFormateada(widget.configuracion.idioma)} · '
                        '${r.tarea.horaInicio.hour.toString().padLeft(2, '0')}:${r.tarea.horaInicio.minute.toString().padLeft(2, '0')}',
                      ),
                      trailing: r.tarea.completada
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                      onTap: () => _abrirResultado(r),
                    );
                  },
                ),
    );
  }
}
