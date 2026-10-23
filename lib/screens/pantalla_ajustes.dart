import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/configuracion_app.dart';
import '../models/dia.dart';
import '../models/lista_favorita.dart';
import '../models/categoria.dart';
import '../models/rutina.dart';
import '../i18n/traducciones.dart';
import '../services/backup_service.dart';

class PantallaAjustes extends StatefulWidget {
  final ConfiguracionApp configuracion;
  final List<Dia> dias;
  final List<ListaFavorita> listasFavoritas;
  final List<Categoria> categorias;
  final List<Rutina> rutinas;

  const PantallaAjustes({
    super.key,
    required this.configuracion,
    required this.dias,
    required this.listasFavoritas,
    required this.categorias,
    required this.rutinas,
  });

  @override
  State<PantallaAjustes> createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends State<PantallaAjustes> {
  String _t(String clave) => widget.configuracion.t(clave);

  String _formatea(TimeOfDay hora) =>
      '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';

  String _etiquetaForma(FormaTarjeta f) {
    switch (f) {
      case FormaTarjeta.cuadrada:
        return _t('cuadrada');
      case FormaTarjeta.redondeada:
        return _t('redondeada');
      case FormaTarjeta.muyRedondeada:
        return _t('muy_redondeada');
    }
  }

  Future<void> _elegirHoraInicio() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: widget.configuracion.horaInicioDefecto,
      helpText: _t('hora_inicio_defecto'),
    );
    if (hora != null) {
      _actualizarConfiguracion(() => widget.configuracion.horaInicioDefecto = hora);
    }
  }

  Future<void> _elegirHoraFin() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: widget.configuracion.horaFinDefecto,
      helpText: _t('hora_fin_defecto'),
    );
    if (hora != null) {
      _actualizarConfiguracion(() => widget.configuracion.horaFinDefecto = hora);
    }
  }

  Future<void> _copiarDatos() async {
    await ServicioCopiaSeguridad.copiarAlPortapapeles(
      dias: widget.dias,
      listas: widget.listasFavoritas,
      categorias: widget.categorias,
      rutinas: widget.rutinas,
      configuracion: widget.configuracion,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('datos_copiados'))),
      );
    }
  }

  Future<void> _restaurarDatos() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_t('confirmar_restaurar')),
        content: Text(_t('confirmar_restaurar_desc')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(_t('cancelar')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(_t('restaurar_datos')),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    final exito = await ServicioCopiaSeguridad.restaurarDesdePortapapeles(
      dias: widget.dias,
      listas: widget.listasFavoritas,
      categorias: widget.categorias,
      rutinas: widget.rutinas,
      configuracion: widget.configuracion,
    );
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(exito ? _t('restaurar_exito') : _t('restaurar_error'))),
    );
  }

  void _actualizarConfiguracion(void Function() cambio) {
    setState(cambio);
    widget.configuracion.notificar(); // repinta el tema y guarda el cambio
  }

  Widget _filaNumero({
    required String titulo,
    required int valor,
    required void Function(int) onCambiar,
    int minimo = 0,
  }) {
    return ListTile(
      title: Text(titulo),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: valor > minimo ? () => onCambiar(valor - 1) : null,
          ),
          SizedBox(
            width: 32,
            child: Text('$valor', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => onCambiar(valor + 1),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.configuracion;
    return Scaffold(
      appBar: AppBar(title: Text(_t('ajustes'))),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(_t('planificacion'), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
            title: Text(_t('aviso_tiempo_libre')),
            subtitle: Text(_t('aviso_tiempo_libre_desc')),
            value: config.avisoHuecosActivado,
            onChanged: (v) => _actualizarConfiguracion(() => config.avisoHuecosActivado = v),
          ),
          ListTile(
            title: Text(_t('hora_inicio_defecto')),
            subtitle: Text(_t('hora_inicio_defecto_desc')),
            trailing: Text(
              _formatea(config.horaInicioDefecto),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            onTap: _elegirHoraInicio,
          ),
          ListTile(
            title: Text(_t('hora_fin_defecto')),
            subtitle: Text(_t('hora_fin_defecto_desc')),
            trailing: Text(
              _formatea(config.horaFinDefecto),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            onTap: _elegirHoraFin,
          ),

          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(_t('pomodoro'), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          _filaNumero(
            titulo: _t('duracion_trabajo'),
            valor: config.pomodoroTrabajoMin,
            onCambiar: (v) => _actualizarConfiguracion(() => config.pomodoroTrabajoMin = v),
          ),
          _filaNumero(
            titulo: _t('duracion_descanso_corto'),
            valor: config.pomodoroDescansoCortoMin,
            onCambiar: (v) => _actualizarConfiguracion(() => config.pomodoroDescansoCortoMin = v),
          ),
          _filaNumero(
            titulo: _t('duracion_descanso_largo'),
            valor: config.pomodoroDescansoLargoMin,
            onCambiar: (v) => _actualizarConfiguracion(() => config.pomodoroDescansoLargoMin = v),
          ),
          _filaNumero(
            titulo: _t('ciclos_para_descanso_largo'),
            valor: config.pomodoroCiclosParaDescansoLargo,
            minimo: 1,
            onCambiar: (v) =>
                _actualizarConfiguracion(() => config.pomodoroCiclosParaDescansoLargo = v),
          ),
          _filaNumero(
            titulo: _t('objetivo_diario'),
            valor: config.pomodoroObjetivoDiario,
            minimo: 1,
            onCambiar: (v) => _actualizarConfiguracion(() => config.pomodoroObjetivoDiario = v),
          ),

          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(_t('apariencia'), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),

          // --- Idioma ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_t('idioma')),
                const SizedBox(height: 8),
                SegmentedButton<Idioma>(
                  segments: Idioma.values
                      .map((i) => ButtonSegment(value: i, label: Text(i.nombrePropio)))
                      .toList(),
                  selected: {config.idioma},
                  onSelectionChanged: (nuevo) =>
                      _actualizarConfiguracion(() => config.idioma = nuevo.first),
                ),
              ],
            ),
          ),

          // --- Modo de tema (claro / oscuro / sistema) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_t('tema')),
                const SizedBox(height: 8),
                SegmentedButton<ModoTema>(
                  segments: [
                    ButtonSegment(value: ModoTema.claro, label: Text(_t('claro')), icon: const Icon(Icons.light_mode)),
                    ButtonSegment(value: ModoTema.oscuro, label: Text(_t('oscuro')), icon: const Icon(Icons.dark_mode)),
                    ButtonSegment(value: ModoTema.sistema, label: Text(_t('sistema')), icon: const Icon(Icons.brightness_auto)),
                  ],
                  selected: {config.modoTema},
                  onSelectionChanged: (nuevo) =>
                      _actualizarConfiguracion(() => config.modoTema = nuevo.first),
                ),
              ],
            ),
          ),

          // --- Color de fondo ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_t('color_de_fondo')),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: paletaColoresFondo.map((color) {
                    final seleccionado = color == config.colorFondo;
                    return GestureDetector(
                      onTap: () => _actualizarConfiguracion(() => config.colorFondo = color),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color != null ? Color(color) : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: seleccionado ? Colors.blue : Colors.black26,
                            width: seleccionado ? 3 : 1,
                          ),
                        ),
                        child: color == null
                            ? const Icon(Icons.format_color_reset, size: 16, color: Colors.black45)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // --- Tipo de letra ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_t('tipo_de_letra')),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: fuentesDisponibles.map((nombreFuente) {
                    final seleccionada = nombreFuente == config.fuente;
                    return ChoiceChip(
                      label: Text(
                        nombreFuente,
                        style: GoogleFonts.getFont(nombreFuente),
                      ),
                      selected: seleccionada,
                      onSelected: (_) =>
                          _actualizarConfiguracion(() => config.fuente = nombreFuente),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // --- Tamaño de letra ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_t('tamano_de_letra')),
                const SizedBox(height: 8),
                SegmentedButton<double>(
                  segments: [
                    ButtonSegment(value: 0.9, label: Text(_t('pequeno'))),
                    ButtonSegment(value: 1.0, label: Text(_t('normal'))),
                    ButtonSegment(value: 1.15, label: Text(_t('grande'))),
                    ButtonSegment(value: 1.3, label: Text(_t('muy_grande'))),
                  ],
                  selected: {config.escalaTexto},
                  onSelectionChanged: (nuevo) =>
                      _actualizarConfiguracion(() => config.escalaTexto = nuevo.first),
                ),
              ],
            ),
          ),

          // --- Forma de las tarjetas de tarea ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_t('forma_cuadro_tareas')),
                const SizedBox(height: 8),
                SegmentedButton<FormaTarjeta>(
                  segments: FormaTarjeta.values
                      .map((f) => ButtonSegment(value: f, label: Text(_etiquetaForma(f))))
                      .toList(),
                  selected: {config.formaTarjeta},
                  onSelectionChanged: (nuevo) =>
                      _actualizarConfiguracion(() => config.formaTarjeta = nuevo.first),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(_t('copia_seguridad'), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.copy_all_outlined),
            title: Text(_t('copiar_datos')),
            onTap: _copiarDatos,
          ),
          ListTile(
            leading: const Icon(Icons.restore_outlined),
            title: Text(_t('restaurar_datos')),
            onTap: _restaurarDatos,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
