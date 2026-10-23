class TareaGuardada {
  String nombre;
  int duracionMinutos;

  TareaGuardada({required this.nombre, required this.duracionMinutos});

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'duracionMinutos': duracionMinutos,
      };

  factory TareaGuardada.fromMap(Map<String, dynamic> map) => TareaGuardada(
        nombre: map['nombre'],
        duracionMinutos: map['duracionMinutos'],
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
/// abre la app (luego puede editarlas o añadir las suyas propias).
List<ListaFavorita> listasPredefinidas() => [
      ListaFavorita(
        id: 'trabajo',
        nombre: 'Trabajo',
        icono: 'work',
        colorValue: 0xFF3B82F6,
        tareas: [
          TareaGuardada(nombre: 'Revisar correo', duracionMinutos: 15),
          TareaGuardada(nombre: 'Reunión de equipo', duracionMinutos: 30),
        ],
      ),
      ListaFavorita(
        id: 'casa',
        nombre: 'Casa',
        icono: 'home',
        colorValue: 0xFF22C55E,
        tareas: [
          TareaGuardada(nombre: 'Hacer la compra', duracionMinutos: 40),
          TareaGuardada(nombre: 'Limpiar cocina', duracionMinutos: 20),
        ],
      ),
      ListaFavorita(
        id: 'deporte',
        nombre: 'Deporte',
        icono: 'fitness_center',
        colorValue: 0xFFF97316,
        tareas: [
          TareaGuardada(nombre: 'Correr', duracionMinutos: 30),
          TareaGuardada(nombre: 'Estirar', duracionMinutos: 10),
        ],
      ),
    ];
