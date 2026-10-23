import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/configuracion_app.dart';
import 'screens/pantalla_raiz.dart';
import 'services/persistencia_service.dart';
import 'services/widget_service.dart';

void main() {
  runApp(const OrganizadorTareasApp());
}

class OrganizadorTareasApp extends StatefulWidget {
  const OrganizadorTareasApp({super.key});

  @override
  State<OrganizadorTareasApp> createState() => _OrganizadorTareasAppState();
}

class _OrganizadorTareasAppState extends State<OrganizadorTareasApp> {
  final ConfiguracionApp configuracion = ConfiguracionApp();
  bool _configuracionCargada = false;

  /// Multiplica el tamaño de cada estilo de texto por [factor], sin usar
  /// TextTheme.apply (que falla si algún estilo no trae fontSize definido).
  TextStyle? _escalarEstilo(TextStyle? estilo, double factor) {
    if (estilo == null) return null;
    return estilo.copyWith(fontSize: (estilo.fontSize ?? 14) * factor);
  }

  TextTheme _escalarTextTheme(TextTheme t, double factor) {
    return TextTheme(
      displayLarge: _escalarEstilo(t.displayLarge, factor),
      displayMedium: _escalarEstilo(t.displayMedium, factor),
      displaySmall: _escalarEstilo(t.displaySmall, factor),
      headlineLarge: _escalarEstilo(t.headlineLarge, factor),
      headlineMedium: _escalarEstilo(t.headlineMedium, factor),
      headlineSmall: _escalarEstilo(t.headlineSmall, factor),
      titleLarge: _escalarEstilo(t.titleLarge, factor),
      titleMedium: _escalarEstilo(t.titleMedium, factor),
      titleSmall: _escalarEstilo(t.titleSmall, factor),
      bodyLarge: _escalarEstilo(t.bodyLarge, factor),
      bodyMedium: _escalarEstilo(t.bodyMedium, factor),
      bodySmall: _escalarEstilo(t.bodySmall, factor),
      labelLarge: _escalarEstilo(t.labelLarge, factor),
      labelMedium: _escalarEstilo(t.labelMedium, factor),
      labelSmall: _escalarEstilo(t.labelSmall, factor),
    );
  }

  ThemeData _construirTema(Brightness brillo) {
    final textThemeBase = brillo == Brightness.dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;
    final textThemeConFuente = GoogleFonts.getTextTheme(configuracion.fuente, textThemeBase);
    final textTheme = _escalarTextTheme(textThemeConFuente, configuracion.escalaTexto);

    const semilla = Color(0xFF3B82F6);

    // Si el usuario no eligió un color de fondo propio, en vez de dejar el
    // blanco/negro plano de Material, usamos un tono suave derivado de la
    // semilla — así el fondo por defecto ya tiene un poco de color.
    final fondoPorDefecto = brillo == Brightness.dark
        ? Color.lerp(semilla, Colors.black, 0.88)!
        : Color.lerp(semilla, Colors.white, 0.90)!;

    return ThemeData(
      useMaterial3: true,
      brightness: brillo,
      colorSchemeSeed: semilla,
      scaffoldBackgroundColor:
          configuracion.colorFondo != null ? Color(configuracion.colorFondo!) : fondoPorDefecto,
      textTheme: textTheme,
    );
  }

  @override
  void initState() {
    super.initState();
    // Repinta toda la app (tema incluido) y guarda cada vez que cambie algo en Ajustes.
    configuracion.addListener(() {
      setState(() {});
      ServicioWidget.idioma = configuracion.idioma;
      ServicioPersistencia.guardarConfiguracion(configuracion);
    });
    _cargarConfiguracionGuardada();
  }

  Future<void> _cargarConfiguracionGuardada() async {
    await ServicioPersistencia.cargarConfiguracionEn(configuracion);
    ServicioWidget.idioma = configuracion.idioma;
    if (mounted) setState(() => _configuracionCargada = true);
  }

  @override
  Widget build(BuildContext context) {
    // Evita un parpadeo con el tema por defecto antes de cargar el guardado.
    if (!_configuracionCargada) {
      return const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
    }

    ThemeMode modo;
    switch (configuracion.modoTema) {
      case ModoTema.claro:
        modo = ThemeMode.light;
        break;
      case ModoTema.oscuro:
        modo = ThemeMode.dark;
        break;
      case ModoTema.sistema:
        modo = ThemeMode.system;
        break;
    }

    return MaterialApp(
      title: 'Organizador de tareas Pro',
      theme: _construirTema(Brightness.light),
      darkTheme: _construirTema(Brightness.dark),
      themeMode: modo,
      home: PantallaRaiz(configuracion: configuracion),
    );
  }
}
