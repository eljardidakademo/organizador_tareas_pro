import '../i18n/traducciones.dart';

class TareaGuardada {
  String nombre;
  int duracionMinutos;
  bool prioridadAlta;
  String? categoriaId;

  TareaGuardada({
    required this.nombre,
    required this.duracionMinutos,
    this.prioridadAlta = false,
    this.categoriaId,
  });

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'duracionMinutos': duracionMinutos,
        'prioridadAlta': prioridadAlta,
        'categoriaId': categoriaId,
      };

  // Las listas guardadas con versiones anteriores no traen prioridad ni
  // categoría: se leen con los valores por defecto.
  factory TareaGuardada.fromMap(Map<String, dynamic> map) => TareaGuardada(
        nombre: map['nombre'],
        duracionMinutos: map['duracionMinutos'],
        prioridadAlta: map['prioridadAlta'] ?? false,
        categoriaId: map['categoriaId'],
      );
}

class ListaFavorita {
  String id;
  String nombre; // ej. "Trabajo", "Casa", "Deporte"
  String icono; // nombre del icono a usar
  int colorValue; // Color.value, para poder guardarlo como número
  List<TareaGuardada> tareas;

  ListaFavorita({
    required this.id,
    required this.nombre,
    required this.icono,
    required this.colorValue,
    required this.tareas,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'icono': icono,
        'colorValue': colorValue,
        'tareas': tareas.map((t) => t.toMap()).toList(),
      };

  factory ListaFavorita.fromMap(Map<String, dynamic> map) => ListaFavorita(
        id: map['id'],
        nombre: map['nombre'],
        icono: map['icono'],
        colorValue: map['colorValue'] ?? 0xFF6B7280,
        tareas: (map['tareas'] as List)
            .map((t) => TareaGuardada.fromMap(t))
            .toList(),
      );
}

/// Paleta de colores e iconos disponibles para que el usuario elija
/// al crear una lista propia.
const List<int> paletaColoresListas = [
  0xFF3B82F6, // azul
  0xFF22C55E, // verde
  0xFFF97316, // naranja
  0xFFA855F7, // morado
  0xFFEF4444, // rojo
  0xFFEAB308, // amarillo
  0xFF14B8A6, // turquesa
  0xFFEC4899, // rosa
];

const List<String> paletaIconosListas = [
  'work',
  'home',
  'fitness_center',
  'school',
  'shopping_cart',
  'restaurant',
  'favorite',
  'star',
];

/// Listas predefinidas de ejemplo, se cargan la primera vez que el usuario
/// abre la app (luego puede editarlas o añadir las suyas propias). Se crean
/// en el idioma de la app en ese momento.
List<ListaFavorita> listasPredefinidas(Idioma idioma) {
  String t(String clave) => Traducciones.t(idioma, clave);
  return [
      ListaFavorita(
        id: 'trabajo',
        nombre: t('lp_trabajo'),
        icono: 'work',
        colorValue: 0xFF3B82F6,
        tareas: [
          TareaGuardada(nombre: t('lp_revisar_correo'), duracionMinutos: 15),
          TareaGuardada(nombre: t('lp_reunion_equipo'), duracionMinutos: 30),
        ],
      ),
      ListaFavorita(
        id: 'casa',
        nombre: t('lp_casa'),
        icono: 'home',
        colorValue: 0xFF22C55E,
        tareas: [
          TareaGuardada(nombre: t('lp_hacer_compra'), duracionMinutos: 40),
          TareaGuardada(nombre: t('lp_limpiar_cocina'), duracionMinutos: 20),
        ],
      ),
      ListaFavorita(
        id: 'deporte',
        nombre: t('lp_deporte'),
        icono: 'fitness_center',
        colorValue: 0xFFF97316,
        tareas: [
          TareaGuardada(nombre: t('lp_correr'), duracionMinutos: 30),
          TareaGuardada(nombre: t('lp_estirar'), duracionMinutos: 10),
        ],
      ),
    ];
}
