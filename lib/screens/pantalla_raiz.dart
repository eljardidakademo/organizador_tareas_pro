import 'package:flutter/material.dart';
import '../models/dia.dart';
import '../models/lista_favorita.dart';
import '../models/categoria.dart';
import '../models/rutina.dart';
import '../models/configuracion_app.dart';
import '../services/persistencia_service.dart';
import '../services/rutinas_service.dart';
import 'pantalla_mis_dias.dart';
import 'pantalla_dias_pager.dart';

class PantallaRaiz extends StatefulWidget {
  final ConfiguracionApp configuracion;

  const PantallaRaiz({super.key, required this.configuracion});

  @override
  State<PantallaRaiz> createState() => _PantallaRaizState();
}

class _PantallaRaizState extends State<PantallaRaiz> {
  List<Dia> dias = [];
  List<ListaFavorita> listasFavoritas = [];
  List<Categoria> categorias = [];
  List<Rutina> rutinas = [];
  ConfiguracionApp get configuracion => widget.configuracion;
  bool _asistenteMostrado = false;
  bool _datosCargados = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosGuardados();
  }

  Future<void> _cargarDatosGuardados() async {
    final diasGuardados = await ServicioPersistencia.cargarDias();
    final listasGuardadas = await ServicioPersistencia.cargarListasFavoritas();
    final categoriasGuardadas = await ServicioPersistencia.cargarCategorias();
    final rutinasGuardadas = await ServicioPersistencia.cargarRutinas();

    setState(() {
      dias = diasGuardados;
      dias.sort((a, b) => a.fecha.compareTo(b.fecha));
      // null = primera vez que se abre la app: se usan las listas de fábrica.
      listasFavoritas = listasGuardadas ?? listasPredefinidas();
      categorias = categoriasGuardadas;
      rutinas = rutinasGuardadas;
      _datosCargados = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _lanzarAsistente());
  }

  Future<void> _lanzarAsistente() async {
    if (_asistenteMostrado) return;
    _asistenteMostrado = true;

    // Paso 1: ¿para qué día? (con opción de saltar)
    final fechaElegida = await showDialog<DateTime>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(configuracion.t('nuevo_plan')),
        content: Text(configuracion.t('pregunta_que_dia')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text(configuracion.t('saltar_ir_mis_dias')),
          ),
          ElevatedButton(
            onPressed: () async {
              final fecha = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (context.mounted) Navigator.of(context).pop(fecha);
            },
            child: Text(configuracion.t('elegir_dia')),
          ),
        ],
      ),
    );

    if (fechaElegida == null) return; // saltado -> se queda en Mis días

    // Paso 2: ¿a qué hora? (con opción de saltar, usa la hora por defecto configurada)
    TimeOfDay horaElegida = configuracion.horaInicioDefecto;
    if (mounted) {
      final saltarHora = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(configuracion.t('hora_de_inicio')),
          content: Text(
            '${configuracion.t('pregunta_que_hora_defecto')} ${horaElegida.format(context)})',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(configuracion.t('saltar_usar_defecto')),
            ),
            ElevatedButton(
              onPressed: () async {
                final hora = await showTimePicker(
                  context: context,
                  initialTime: horaElegida,
                );
                if (hora != null) horaElegida = hora;
                if (context.mounted) Navigator.of(context).pop(false);
              },
              child: Text(configuracion.t('elegir_hora')),
            ),
          ],
        ),
      );
      if (saltarHora == null) return;
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
      horaFinDia: configuracion.avisoHuecosActivado
          ? DateTime(
              fechaElegida.year,
              fechaElegida.month,
              fechaElegida.day,
              configuracion.horaFinDefecto.hour,
              configuracion.horaFinDefecto.minute,
            )
          : null,
      tareas: [],
    );

    ServicioRutinas.aplicarRutinasCoincidentes(nuevoDia, rutinas);

    setState(() {
      dias.add(nuevoDia);
      dias.sort((a, b) => a.fecha.compareTo(b.fecha));
    });
    ServicioPersistencia.guardarDias(dias);

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PantallaDiasPager(
            dias: dias,
            indiceInicial: dias.indexOf(nuevoDia),
            listasFavoritas: listasFavoritas,
            categorias: categorias,
            rutinas: rutinas,
            configuracion: configuracion,
            onCambio: () {
              setState(() {});
              ServicioPersistencia.guardarDias(dias);
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_datosCargados) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return PantallaMisDias(
      dias: dias,
      listasFavoritas: listasFavoritas,
      categorias: categorias,
      rutinas: rutinas,
      configuracion: configuracion,
    );
  }
}
