import 'package:flutter/material.dart';
import '../models/dia.dart';
import '../models/lista_favorita.dart';
import '../models/categoria.dart';
import '../models/rutina.dart';
import '../models/configuracion_app.dart';
import 'pantalla_checklist_dia.dart';

class PantallaDiasPager extends StatefulWidget {
  final List<Dia> dias; // ya ordenados por fecha
  final int indiceInicial;
  final List<ListaFavorita> listasFavoritas;
  final List<Categoria> categorias;
  final List<Rutina> rutinas;
  final ConfiguracionApp configuracion;
  final VoidCallback onCambio;

  const PantallaDiasPager({
    super.key,
    required this.dias,
    required this.indiceInicial,
    required this.listasFavoritas,
    required this.categorias,
    required this.rutinas,
    required this.configuracion,
    required this.onCambio,
  });

  @override
  State<PantallaDiasPager> createState() => _PantallaDiasPagerState();
}

class _PantallaDiasPagerState extends State<PantallaDiasPager> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.indiceInicial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      itemCount: widget.dias.length,
      itemBuilder: (context, index) {
        return PantallaChecklistDia(
          dia: widget.dias[index],
          todosLosDias: widget.dias,
          listasFavoritas: widget.listasFavoritas,
          categorias: widget.categorias,
          rutinas: widget.rutinas,
          configuracion: widget.configuracion,
          onCambio: widget.onCambio,
        );
      },
    );
  }
}
