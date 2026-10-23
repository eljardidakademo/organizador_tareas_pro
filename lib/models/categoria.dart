/// Categoría para agrupar tareas a efectos de estadísticas y recomendaciones
/// de estimación (ej. "Clases", "Corrección", "Personal"). Independiente de
/// las listas favoritas, que sirven para otro propósito (plantillas de tarea).
class Categoria {
  String id;
  String nombre;
  int colorValue;

  Categoria({required this.id, required this.nombre, required this.colorValue});

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'colorValue': colorValue,
      };

  factory Categoria.fromMap(Map<String, dynamic> map) => Categoria(
        id: map['id'],
        nombre: map['nombre'],
        colorValue: map['colorValue'] ?? 0xFF6B7280,
      );
}

/// Paleta de colores para elegir al crear una categoría (misma paleta que
/// las listas favoritas, para mantener coherencia visual).
const List<int> paletaColoresCategorias = [
  0xFF3B82F6, 0xFF22C55E, 0xFFF97316, 0xFFA855F7,
  0xFFEF4444, 0xFFEAB308, 0xFF14B8A6, 0xFFEC4899,
];
