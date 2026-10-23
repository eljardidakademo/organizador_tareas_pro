enum Idioma { valenciano, castellano, ingles }

extension IdiomaEtiqueta on Idioma {
  String get nombrePropio {
    switch (this) {
      case Idioma.valenciano:
        return 'Valencià';
      case Idioma.castellano:
        return 'Castellano';
      case Idioma.ingles:
        return 'English';
    }
  }
}

/// Traducciones de todos los textos visibles de la app. Cada clave tiene
/// una entrada por idioma; si falta una, se devuelve la clave tal cual
/// (para detectar fácilmente algo sin traducir durante el desarrollo).
class Traducciones {
  static const Map<String, Map<Idioma, String>> _textos = {
    // --- General / navegación ---
    'mis_dias': {
      Idioma.valenciano: 'Els meus dies',
      Idioma.castellano: 'Mis días',
      Idioma.ingles: 'My days',
    },
    'nuevo_dia': {
      Idioma.valenciano: 'Nou dia',
      Idioma.castellano: 'Nuevo día',
      Idioma.ingles: 'New day',
    },
    'ajustes': {
      Idioma.valenciano: 'Ajustos',
      Idioma.castellano: 'Ajustes',
      Idioma.ingles: 'Settings',
    },
    'guardar': {
      Idioma.valenciano: 'Guardar',
      Idioma.castellano: 'Guardar',
      Idioma.ingles: 'Save',
    },
    'guardar_cambios': {
      Idioma.valenciano: 'Guardar canvis',
      Idioma.castellano: 'Guardar cambios',
      Idioma.ingles: 'Save changes',
    },
    'cancelar': {
      Idioma.valenciano: 'Cancel·lar',
      Idioma.castellano: 'Cancelar',
      Idioma.ingles: 'Cancel',
    },
    'eliminar': {
      Idioma.valenciano: 'Eliminar',
      Idioma.castellano: 'Eliminar',
      Idioma.ingles: 'Delete',
    },
    'editar': {
      Idioma.valenciano: 'Editar',
      Idioma.castellano: 'Editar',
      Idioma.ingles: 'Edit',
    },

    // --- Asistente inicial (pantalla_raiz) ---
    'nuevo_plan': {
      Idioma.valenciano: 'Nou pla',
      Idioma.castellano: 'Nuevo plan',
      Idioma.ingles: 'New plan',
    },
    'pregunta_que_dia': {
      Idioma.valenciano: 'Per a quin dia vols organitzar tasques?',
      Idioma.castellano: '¿Para qué día quieres organizar tareas?',
      Idioma.ingles: 'Which day do you want to plan tasks for?',
    },
    'saltar_ir_mis_dias': {
      Idioma.valenciano: 'Saltar, anar a Els meus dies',
      Idioma.castellano: 'Saltar, ir a Mis días',
      Idioma.ingles: 'Skip, go to My days',
    },
    'elegir_dia': {
      Idioma.valenciano: 'Triar dia',
      Idioma.castellano: 'Elegir día',
      Idioma.ingles: 'Pick a day',
    },
    'hora_de_inicio': {
      Idioma.valenciano: 'Hora d\'inici',
      Idioma.castellano: 'Hora de inicio',
      Idioma.ingles: 'Start time',
    },
    'pregunta_que_hora_defecto': {
      Idioma.valenciano: 'A quina hora comença eixe dia? (per defecte',
      Idioma.castellano: '¿A qué hora empieza ese día? (por defecto',
      Idioma.ingles: 'What time does that day start? (default',
    },
    'saltar_usar_defecto': {
      Idioma.valenciano: 'Saltar (usar per defecte)',
      Idioma.castellano: 'Saltar (usar por defecto)',
      Idioma.ingles: 'Skip (use default)',
    },
    'elegir_hora': {
      Idioma.valenciano: 'Triar hora',
      Idioma.castellano: 'Elegir hora',
      Idioma.ingles: 'Pick a time',
    },

    // --- Mis días ---
    'aun_no_dias': {
      Idioma.valenciano: 'Encara no has creat cap dia',
      Idioma.castellano: 'Aún no has creado ningún día',
      Idioma.ingles: 'You haven\'t created any day yet',
    },
    'tareas_completadas': {
      Idioma.valenciano: 'tasques · completades',
      Idioma.castellano: 'tareas · completadas',
      Idioma.ingles: 'tasks · completed',
    },
    'duplicar_dia': {
      Idioma.valenciano: 'Duplicar dia',
      Idioma.castellano: 'Duplicar día',
      Idioma.ingles: 'Duplicate day',
    },
    'pregunta_copiar_a': {
      Idioma.valenciano: 'A quin dia vols copiar',
      Idioma.castellano: '¿A qué día quieres copiar',
      Idioma.ingles: 'Which day do you want to copy',
    },
    'dia_ya_existe': {
      Idioma.valenciano: 'Ja existeix un dia planificat per a eixa data',
      Idioma.castellano: 'Ya existe un día planificado para esa fecha',
      Idioma.ingles: 'A day is already planned for that date',
    },

    // --- Checklist del día ---
    'aun_no_tareas': {
      Idioma.valenciano: 'Encara no has afegit tasques este dia',
      Idioma.castellano: 'Aún no has añadido tareas este día',
      Idioma.ingles: 'You haven\'t added tasks for this day yet',
    },
    'mis_listas': {
      Idioma.valenciano: 'Les meues llistes',
      Idioma.castellano: 'Mis listas',
      Idioma.ingles: 'My lists',
    },
    'inicio': {
      Idioma.valenciano: 'Inici',
      Idioma.castellano: 'Inicio',
      Idioma.ingles: 'Start',
    },
    'que_lista_anadir': {
      Idioma.valenciano: 'A quina llista vols afegir esta tasca?',
      Idioma.castellano: '¿A qué lista quieres añadir esta tarea?',
      Idioma.ingles: 'Which list do you want to add this task to?',
    },
    'anadida_a': {
      Idioma.valenciano: 'Afegida a',
      Idioma.castellano: 'Añadida a',
      Idioma.ingles: 'Added to',
    },
    'duracion': {
      Idioma.valenciano: 'Durada',
      Idioma.castellano: 'Duración',
      Idioma.ingles: 'Duration',
    },
    'escribir': {
      Idioma.valenciano: 'Escriure',
      Idioma.castellano: 'Escribir',
      Idioma.ingles: 'Type',
    },
    'girar_temporizador': {
      Idioma.valenciano: 'Girar temporitzador',
      Idioma.castellano: 'Girar temporizador',
      Idioma.ingles: 'Spin timer',
    },
    'minutos': {
      Idioma.valenciano: 'Minuts',
      Idioma.castellano: 'Minutos',
      Idioma.ingles: 'Minutes',
    },
    'prioridad_alta': {
      Idioma.valenciano: 'Prioritat alta',
      Idioma.castellano: 'Prioridad alta',
      Idioma.ingles: 'High priority',
    },
    'activar_aviso_huecos': {
      Idioma.valenciano: 'Activar avís de temps lliure per a este dia',
      Idioma.castellano: 'Activar aviso de tiempo libre para este día',
      Idioma.ingles: 'Turn on free-time alert for this day',
    },
    'te_pasas': {
      Idioma.valenciano: 'Et passes',
      Idioma.castellano: 'Te pasas',
      Idioma.ingles: 'You\'re over by',
    },
    'de_tu_hora_fin': {
      Idioma.valenciano: 'de la teua hora de fi de jornada',
      Idioma.castellano: 'de tu hora de fin de jornada',
      Idioma.ingles: 'past your end-of-day time',
    },
    'tiempo_libre_restante': {
      Idioma.valenciano: 'Temps lliure restant hui',
      Idioma.castellano: 'Tiempo libre restante hoy',
      Idioma.ingles: 'Free time remaining today',
    },
    'que_hora_acaba_jornada': {
      Idioma.valenciano: 'A quina hora acaba la teua jornada este dia?',
      Idioma.castellano: '¿A qué hora acaba tu jornada este día?',
      Idioma.ingles: 'What time does your day end today?',
    },
    'que_hora_empieza_dia': {
      Idioma.valenciano: 'A quina hora comença este dia?',
      Idioma.castellano: '¿A qué hora empieza este día?',
      Idioma.ingles: 'What time does this day start?',
    },

    // --- Añadir tarea ---
    'anadir_tarea': {
      Idioma.valenciano: 'Afegir tasca',
      Idioma.castellano: 'Añadir tarea',
      Idioma.ingles: 'Add task',
    },
    'nombre_tarea': {
      Idioma.valenciano: 'Nom de la tasca',
      Idioma.castellano: 'Nombre de la tarea',
      Idioma.ingles: 'Task name',
    },
    'escribe_nombre': {
      Idioma.valenciano: 'Escriu un nom',
      Idioma.castellano: 'Escribe un nombre',
      Idioma.ingles: 'Type a name',
    },
    'duracion_estimada_min': {
      Idioma.valenciano: 'Durada estimada (minuts)',
      Idioma.castellano: 'Duración estimada (minutos)',
      Idioma.ingles: 'Estimated duration (minutes)',
    },
    'introduce_minutos_validos': {
      Idioma.valenciano: 'Introdueix minuts vàlids',
      Idioma.castellano: 'Introduce minutos válidos',
      Idioma.ingles: 'Enter a valid number of minutes',
    },
    'o_elige_desde_favoritas': {
      Idioma.valenciano: 'O tria des de les teues llistes preferides:',
      Idioma.castellano: 'O elige desde tus listas favoritas:',
      Idioma.ingles: 'Or pick from your favorite lists:',
    },
    'guardar_tarea': {
      Idioma.valenciano: 'Guardar tasca',
      Idioma.castellano: 'Guardar tarea',
      Idioma.ingles: 'Save task',
    },

    // --- Listas favoritas ---
    'nueva_lista': {
      Idioma.valenciano: 'Nova llista',
      Idioma.castellano: 'Nueva lista',
      Idioma.ingles: 'New list',
    },
    'editar_lista': {
      Idioma.valenciano: 'Editar llista',
      Idioma.castellano: 'Editar lista',
      Idioma.ingles: 'Edit list',
    },
    'nombre': {
      Idioma.valenciano: 'Nom',
      Idioma.castellano: 'Nombre',
      Idioma.ingles: 'Name',
    },
    'icono': {
      Idioma.valenciano: 'Icona',
      Idioma.castellano: 'Icono',
      Idioma.ingles: 'Icon',
    },
    'color': {
      Idioma.valenciano: 'Color',
      Idioma.castellano: 'Color',
      Idioma.ingles: 'Color',
    },
    'aun_no_listas': {
      Idioma.valenciano: 'Encara no tens llistes preferides',
      Idioma.castellano: 'Aún no tienes listas favoritas',
      Idioma.ingles: 'You don\'t have any favorite lists yet',
    },
    'tareas_guardadas': {
      Idioma.valenciano: 'tasques guardades',
      Idioma.castellano: 'tareas guardadas',
      Idioma.ingles: 'saved tasks',
    },
    'eliminar_lista': {
      Idioma.valenciano: 'Eliminar llista',
      Idioma.castellano: 'Eliminar lista',
      Idioma.ingles: 'Delete list',
    },
    'seguro_eliminar_lista': {
      Idioma.valenciano: 'Segur que vols eliminar',
      Idioma.castellano: '¿Seguro que quieres eliminar',
      Idioma.ingles: 'Are you sure you want to delete',
    },
    'nueva_tarea_guardada': {
      Idioma.valenciano: 'Nova tasca guardada',
      Idioma.castellano: 'Nueva tarea guardada',
      Idioma.ingles: 'New saved task',
    },
    'editar_tarea': {
      Idioma.valenciano: 'Editar tasca',
      Idioma.castellano: 'Editar tarea',
      Idioma.ingles: 'Edit task',
    },
    'duracion_tipica_min': {
      Idioma.valenciano: 'Durada típica (min)',
      Idioma.castellano: 'Duración típica (min)',
      Idioma.ingles: 'Typical duration (min)',
    },
    'anadir_tarea_a_lista': {
      Idioma.valenciano: 'Afegir tasca a la llista',
      Idioma.castellano: 'Añadir tarea a la lista',
      Idioma.ingles: 'Add task to list',
    },

    // --- Ajustes ---
    'planificacion': {
      Idioma.valenciano: 'Planificació',
      Idioma.castellano: 'Planificación',
      Idioma.ingles: 'Planning',
    },
    'aviso_tiempo_libre': {
      Idioma.valenciano: 'Avís de temps lliure',
      Idioma.castellano: 'Aviso de tiempo libre',
      Idioma.ingles: 'Free time alert',
    },
    'aviso_tiempo_libre_desc': {
      Idioma.valenciano: 'Mostra quant de temps et queda lliure (o si et passes) abans de la teua hora de fi de jornada',
      Idioma.castellano: 'Muestra cuánto tiempo te queda libre (o si te pasas) antes de tu hora de fin de jornada',
      Idioma.ingles: 'Shows how much free time you have left (or if you\'re over) before your end-of-day time',
    },
    'hora_inicio_defecto': {
      Idioma.valenciano: 'Hora d\'inici per defecte',
      Idioma.castellano: 'Hora de inicio por defecto',
      Idioma.ingles: 'Default start time',
    },
    'hora_inicio_defecto_desc': {
      Idioma.valenciano: 'S\'usa en crear un dia nou si no en tries una altra',
      Idioma.castellano: 'Se usa al crear un día nuevo si no eliges otra',
      Idioma.ingles: 'Used when creating a new day if you don\'t choose another',
    },
    'hora_fin_defecto': {
      Idioma.valenciano: 'Hora de fi de jornada per defecte',
      Idioma.castellano: 'Hora de fin de jornada por defecto',
      Idioma.ingles: 'Default end-of-day time',
    },
    'hora_fin_defecto_desc': {
      Idioma.valenciano: 'S\'usa per a l\'avís de temps lliure en dies nous',
      Idioma.castellano: 'Se usa para el aviso de tiempo libre en días nuevos',
      Idioma.ingles: 'Used for the free time alert on new days',
    },
    'apariencia': {
      Idioma.valenciano: 'Aparença',
      Idioma.castellano: 'Apariencia',
      Idioma.ingles: 'Appearance',
    },
    'tema': {
      Idioma.valenciano: 'Tema',
      Idioma.castellano: 'Tema',
      Idioma.ingles: 'Theme',
    },
    'claro': {
      Idioma.valenciano: 'Clar',
      Idioma.castellano: 'Claro',
      Idioma.ingles: 'Light',
    },
    'oscuro': {
      Idioma.valenciano: 'Fosc',
      Idioma.castellano: 'Oscuro',
      Idioma.ingles: 'Dark',
    },
    'sistema': {
      Idioma.valenciano: 'Sistema',
      Idioma.castellano: 'Sistema',
      Idioma.ingles: 'System',
    },
    'color_de_fondo': {
      Idioma.valenciano: 'Color de fons',
      Idioma.castellano: 'Color de fondo',
      Idioma.ingles: 'Background color',
    },
    'tipo_de_letra': {
      Idioma.valenciano: 'Tipus de lletra',
      Idioma.castellano: 'Tipo de letra',
      Idioma.ingles: 'Font',
    },
    'tamano_de_letra': {
      Idioma.valenciano: 'Grandària de lletra',
      Idioma.castellano: 'Tamaño de letra',
      Idioma.ingles: 'Font size',
    },
    'pequeno': {
      Idioma.valenciano: 'Xicotet',
      Idioma.castellano: 'Pequeño',
      Idioma.ingles: 'Small',
    },
    'normal': {
      Idioma.valenciano: 'Normal',
      Idioma.castellano: 'Normal',
      Idioma.ingles: 'Normal',
    },
    'grande': {
      Idioma.valenciano: 'Gran',
      Idioma.castellano: 'Grande',
      Idioma.ingles: 'Large',
    },
    'muy_grande': {
      Idioma.valenciano: 'Molt gran',
      Idioma.castellano: 'Muy grande',
      Idioma.ingles: 'Extra large',
    },
    'forma_cuadro_tareas': {
      Idioma.valenciano: 'Forma del quadre de les tasques',
      Idioma.castellano: 'Forma del cuadro de las tareas',
      Idioma.ingles: 'Task card shape',
    },
    // --- Listas predefinidas (se crean la primera vez que se abre la app) ---
    'lp_trabajo': {
      Idioma.valenciano: 'Treball',
      Idioma.castellano: 'Trabajo',
      Idioma.ingles: 'Work',
    },
    'lp_casa': {
      Idioma.valenciano: 'Casa',
      Idioma.castellano: 'Casa',
      Idioma.ingles: 'Home',
    },
    'lp_deporte': {
      Idioma.valenciano: 'Esport',
      Idioma.castellano: 'Deporte',
      Idioma.ingles: 'Sport',
    },
    'lp_revisar_correo': {
      Idioma.valenciano: 'Revisar el correu',
      Idioma.castellano: 'Revisar correo',
      Idioma.ingles: 'Check email',
    },
    'lp_reunion_equipo': {
      Idioma.valenciano: "Reunió d'equip",
      Idioma.castellano: 'Reunión de equipo',
      Idioma.ingles: 'Team meeting',
    },
    'lp_hacer_compra': {
      Idioma.valenciano: 'Fer la compra',
      Idioma.castellano: 'Hacer la compra',
      Idioma.ingles: 'Do the shopping',
    },
    'lp_limpiar_cocina': {
      Idioma.valenciano: 'Netejar la cuina',
      Idioma.castellano: 'Limpiar cocina',
      Idioma.ingles: 'Clean the kitchen',
    },
    'lp_correr': {
      Idioma.valenciano: 'Córrer',
      Idioma.castellano: 'Correr',
      Idioma.ingles: 'Go for a run',
    },
    'lp_estirar': {
      Idioma.valenciano: 'Estiraments',
      Idioma.castellano: 'Estirar',
      Idioma.ingles: 'Stretch',
    },
    'cuadrada': {
      Idioma.valenciano: 'Quadrada',
      Idioma.castellano: 'Cuadrada',
      Idioma.ingles: 'Square',
    },
    'redondeada': {
      Idioma.valenciano: 'Arredonida',
      Idioma.castellano: 'Redondeada',
      Idioma.ingles: 'Rounded',
    },
    'muy_redondeada': {
      Idioma.valenciano: 'Molt arredonida',
      Idioma.castellano: 'Muy redondeada',
      Idioma.ingles: 'Very rounded',
    },
    'idioma': {
      Idioma.valenciano: 'Idioma',
      Idioma.castellano: 'Idioma',
      Idioma.ingles: 'Language',
    },

    // --- Categorías y comparativa de tiempos ---
    'mis_categorias': {
      Idioma.valenciano: 'Les meues categories',
      Idioma.castellano: 'Mis categorías',
      Idioma.ingles: 'My categories',
    },
    'nueva_categoria': {
      Idioma.valenciano: 'Nova categoria',
      Idioma.castellano: 'Nueva categoría',
      Idioma.ingles: 'New category',
    },
    'editar_categoria': {
      Idioma.valenciano: 'Editar categoria',
      Idioma.castellano: 'Editar categoría',
      Idioma.ingles: 'Edit category',
    },
    'eliminar_categoria': {
      Idioma.valenciano: 'Eliminar categoria',
      Idioma.castellano: 'Eliminar categoría',
      Idioma.ingles: 'Delete category',
    },
    'aun_no_categorias': {
      Idioma.valenciano: 'Encara no tens categories',
      Idioma.castellano: 'Aún no tienes categorías',
      Idioma.ingles: 'You don\'t have any categories yet',
    },
    'sin_categoria': {
      Idioma.valenciano: 'Sense categoria',
      Idioma.castellano: 'Sin categoría',
      Idioma.ingles: 'No category',
    },
    'categoria': {
      Idioma.valenciano: 'Categoria',
      Idioma.castellano: 'Categoría',
      Idioma.ingles: 'Category',
    },
    'estimado': {
      Idioma.valenciano: 'Estimat',
      Idioma.castellano: 'Estimado',
      Idioma.ingles: 'Estimated',
    },
    'real': {
      Idioma.valenciano: 'Real',
      Idioma.castellano: 'Real',
      Idioma.ingles: 'Actual',
    },
    'en_tiempo': {
      Idioma.valenciano: 'En temps',
      Idioma.castellano: 'En tiempo',
      Idioma.ingles: 'On time',
    },
    'por_encima': {
      Idioma.valenciano: 'Per damunt',
      Idioma.castellano: 'Por encima',
      Idioma.ingles: 'Over',
    },
    'por_debajo': {
      Idioma.valenciano: 'Per davall',
      Idioma.castellano: 'Por debajo',
      Idioma.ingles: 'Under',
    },
    'aviso_80_por_ciento': {
      Idioma.valenciano: 'Ja portes el 80% del temps estimat',
      Idioma.castellano: 'Ya llevas el 80% del tiempo estimado',
      Idioma.ingles: 'You\'ve used 80% of the estimated time',
    },
    'registrar_tiempo': {
      Idioma.valenciano: 'Registrar temps',
      Idioma.castellano: 'Registrar tiempo',
      Idioma.ingles: 'Log time',
    },
    'minutos_invertidos': {
      Idioma.valenciano: 'Minuts invertits en esta sessió',
      Idioma.castellano: 'Minutos invertidos en esta sesión',
      Idioma.ingles: 'Minutes spent in this session',
    },
    'anadir_sesion': {
      Idioma.valenciano: 'Afegir sessió',
      Idioma.castellano: 'Añadir sesión',
      Idioma.ingles: 'Add session',
    },
    'historial_sesiones': {
      Idioma.valenciano: 'Historial de sessions',
      Idioma.castellano: 'Historial de sesiones',
      Idioma.ingles: 'Session history',
    },
    'sin_sesiones': {
      Idioma.valenciano: 'Encara no hi ha sessions registrades',
      Idioma.castellano: 'Aún no hay sesiones registradas',
      Idioma.ingles: 'No sessions logged yet',
    },
    'sugerencia_estimacion': {
      Idioma.valenciano: 'Les tasques de esta categoria solen durar',
      Idioma.castellano: 'Las tareas de esta categoría suelen durar',
      Idioma.ingles: 'Tasks in this category usually take',
    },
    'mas_de_lo_estimado': {
      Idioma.valenciano: 'més del que s\'estima',
      Idioma.castellano: 'más de lo estimado',
      Idioma.ingles: 'longer than estimated',
    },
    'menos_de_lo_estimado': {
      Idioma.valenciano: 'menys del que s\'estima',
      Idioma.castellano: 'menos de lo estimado',
      Idioma.ingles: 'less than estimated',
    },

    // --- Eliminar día ---
    'eliminar_dia': {
      Idioma.valenciano: 'Eliminar dia',
      Idioma.castellano: 'Eliminar día',
      Idioma.ingles: 'Delete day',
    },
    'seguro_eliminar_dia': {
      Idioma.valenciano: 'Segur que vols eliminar el dia',
      Idioma.castellano: '¿Seguro que quieres eliminar el día',
      Idioma.ingles: 'Are you sure you want to delete the day',
    },

    // --- Pomodoro ---
    'pomodoro': {
      Idioma.valenciano: 'Pomodoro',
      Idioma.castellano: 'Pomodoro',
      Idioma.ingles: 'Pomodoro',
    },
    'iniciar_pomodoro': {
      Idioma.valenciano: 'Iniciar Pomodoro',
      Idioma.castellano: 'Iniciar Pomodoro',
      Idioma.ingles: 'Start Pomodoro',
    },
    'iniciar_pomodoro_con_tarea': {
      Idioma.valenciano: 'Iniciar Pomodoro amb esta tasca',
      Idioma.castellano: 'Iniciar Pomodoro con esta tarea',
      Idioma.ingles: 'Start Pomodoro with this task',
    },
    'sin_tarea_asociada': {
      Idioma.valenciano: 'Pomodoro lliure (sense tasca)',
      Idioma.castellano: 'Pomodoro libre (sin tarea)',
      Idioma.ingles: 'Free Pomodoro (no task)',
    },
    'trabajo': {
      Idioma.valenciano: 'Treball',
      Idioma.castellano: 'Trabajo',
      Idioma.ingles: 'Focus',
    },
    'descanso_corto': {
      Idioma.valenciano: 'Descans curt',
      Idioma.castellano: 'Descanso corto',
      Idioma.ingles: 'Short break',
    },
    'descanso_largo': {
      Idioma.valenciano: 'Descans llarg',
      Idioma.castellano: 'Descanso largo',
      Idioma.ingles: 'Long break',
    },
    'iniciar': {
      Idioma.valenciano: 'Iniciar',
      Idioma.castellano: 'Iniciar',
      Idioma.ingles: 'Start',
    },
    'pausar': {
      Idioma.valenciano: 'Pausar',
      Idioma.castellano: 'Pausar',
      Idioma.ingles: 'Pause',
    },
    'reanudar': {
      Idioma.valenciano: 'Reprendre',
      Idioma.castellano: 'Reanudar',
      Idioma.ingles: 'Resume',
    },
    'terminar': {
      Idioma.valenciano: 'Acabar',
      Idioma.castellano: 'Terminar',
      Idioma.ingles: 'End',
    },
    'saltar_descanso': {
      Idioma.valenciano: 'Saltar descans',
      Idioma.castellano: 'Saltar descanso',
      Idioma.ingles: 'Skip break',
    },
    'ciclo': {
      Idioma.valenciano: 'Cicle',
      Idioma.castellano: 'Ciclo',
      Idioma.ingles: 'Cycle',
    },
    'modo_continuo': {
      Idioma.valenciano: 'Mode continu',
      Idioma.castellano: 'Modo continuo',
      Idioma.ingles: 'Continuous mode',
    },
    'objetivo_diario': {
      Idioma.valenciano: 'Objectiu diari',
      Idioma.castellano: 'Objetivo diario',
      Idioma.ingles: 'Daily goal',
    },
    'pomodoros_hoy': {
      Idioma.valenciano: 'Pomodoros hui',
      Idioma.castellano: 'Pomodoros hoy',
      Idioma.ingles: 'Pomodoros today',
    },
    'duracion_trabajo': {
      Idioma.valenciano: 'Durada del treball',
      Idioma.castellano: 'Duración del trabajo',
      Idioma.ingles: 'Focus duration',
    },
    'duracion_descanso_corto': {
      Idioma.valenciano: 'Durada del descans curt',
      Idioma.castellano: 'Duración del descanso corto',
      Idioma.ingles: 'Short break duration',
    },
    'duracion_descanso_largo': {
      Idioma.valenciano: 'Durada del descans llarg',
      Idioma.castellano: 'Duración del descanso largo',
      Idioma.ingles: 'Long break duration',
    },
    'ciclos_para_descanso_largo': {
      Idioma.valenciano: 'Cicles abans del descans llarg',
      Idioma.castellano: 'Ciclos antes del descanso largo',
      Idioma.ingles: 'Cycles before long break',
    },
    'sesion_completada': {
      Idioma.valenciano: 'Sessió completada i registrada',
      Idioma.castellano: 'Sesión completada y registrada',
      Idioma.ingles: 'Session completed and logged',
    },

    // --- Estadísticas ---
    'estadisticas': {
      Idioma.valenciano: 'Estadístiques',
      Idioma.castellano: 'Estadísticas',
      Idioma.ingles: 'Statistics',
    },
    'hoy': {
      Idioma.valenciano: 'Hui',
      Idioma.castellano: 'Hoy',
      Idioma.ingles: 'Today',
    },
    'widget_sin_tareas': {
      Idioma.valenciano: 'No hi ha tasques per a hui',
      Idioma.castellano: 'No hay tareas para hoy',
      Idioma.ingles: 'No tasks for today',
    },
    'widget_todo_hecho': {
      Idioma.valenciano: 'Tot fet! 🎉',
      Idioma.castellano: '¡Todo hecho! 🎉',
      Idioma.ingles: 'All done! 🎉',
    },
    'widget_abrir_app': {
      Idioma.valenciano: "Obri l'app per a vore les tasques de hui",
      Idioma.castellano: 'Abre la app para ver las tareas de hoy',
      Idioma.ingles: "Open the app to see today's tasks",
    },
    'esta_semana': {
      Idioma.valenciano: 'Esta setmana',
      Idioma.castellano: 'Esta semana',
      Idioma.ingles: 'This week',
    },
    'este_mes': {
      Idioma.valenciano: 'Este mes',
      Idioma.castellano: 'Este mes',
      Idioma.ingles: 'This month',
    },
    'tiempo_trabajado': {
      Idioma.valenciano: 'Temps treballat',
      Idioma.castellano: 'Tiempo trabajado',
      Idioma.ingles: 'Time worked',
    },
    'tareas_completadas_stat': {
      Idioma.valenciano: 'Tasques completades',
      Idioma.castellano: 'Tareas completadas',
      Idioma.ingles: 'Completed tasks',
    },
    'pomodoros_realizados': {
      Idioma.valenciano: 'Pomodoros realitzats',
      Idioma.castellano: 'Pomodoros realizados',
      Idioma.ingles: 'Pomodoros completed',
    },
    'tiempo_por_categoria': {
      Idioma.valenciano: 'Temps per categoria',
      Idioma.castellano: 'Tiempo por categoría',
      Idioma.ingles: 'Time by category',
    },
    'estimado_vs_real': {
      Idioma.valenciano: 'Estimat vs real (total)',
      Idioma.castellano: 'Estimado vs real (total)',
      Idioma.ingles: 'Estimated vs actual (total)',
    },
    'franja_mas_productiva': {
      Idioma.valenciano: 'Franja més productiva',
      Idioma.castellano: 'Franja más productiva',
      Idioma.ingles: 'Most productive time slot',
    },
    'tasa_acierto': {
      Idioma.valenciano: 'Taxa d\'encert en estimacions',
      Idioma.castellano: 'Tasa de acierto en estimaciones',
      Idioma.ingles: 'Estimation accuracy rate',
    },
    'categoria_mas_se_retrasa': {
      Idioma.valenciano: 'Categoria que més es retarda',
      Idioma.castellano: 'Categoría que más se retrasa',
      Idioma.ingles: 'Category that runs over the most',
    },
    'racha_dias': {
      Idioma.valenciano: 'Ratxa de dies amb tasques completades',
      Idioma.castellano: 'Racha de días con tareas completadas',
      Idioma.ingles: 'Streak of days with completed tasks',
    },
    'tendencia_ultimos_7_dias': {
      Idioma.valenciano: 'Tendència dels últims 7 dies',
      Idioma.castellano: 'Tendencia de los últimos 7 días',
      Idioma.ingles: 'Trend for the last 7 days',
    },
    'sin_datos_suficientes': {
      Idioma.valenciano: 'Encara no hi ha prou dades',
      Idioma.castellano: 'Aún no hay datos suficientes',
      Idioma.ingles: 'Not enough data yet',
    },
    'dias': {
      Idioma.valenciano: 'dies',
      Idioma.castellano: 'días',
      Idioma.ingles: 'days',
    },

    // --- Exportar ---
    'exportar': {
      Idioma.valenciano: 'Exportar',
      Idioma.castellano: 'Exportar',
      Idioma.ingles: 'Export',
    },
    'exportar_tareas': {
      Idioma.valenciano: 'Exportar tasques',
      Idioma.castellano: 'Exportar tareas',
      Idioma.ingles: 'Export tasks',
    },
    'seleccionar_dias': {
      Idioma.valenciano: 'Selecciona els dies a exportar',
      Idioma.castellano: 'Selecciona los días a exportar',
      Idioma.ingles: 'Select the days to export',
    },
    'todos': {
      Idioma.valenciano: 'Tots',
      Idioma.castellano: 'Todos',
      Idioma.ingles: 'All',
    },
    'ninguno': {
      Idioma.valenciano: 'Cap',
      Idioma.castellano: 'Ninguno',
      Idioma.ingles: 'None',
    },
    'formato': {
      Idioma.valenciano: 'Format',
      Idioma.castellano: 'Formato',
      Idioma.ingles: 'Format',
    },
    'selecciona_al_menos_un_dia': {
      Idioma.valenciano: 'Selecciona almenys un dia',
      Idioma.castellano: 'Selecciona al menos un día',
      Idioma.ingles: 'Select at least one day',
    },
    'columna_dia': {
      Idioma.valenciano: 'Dia',
      Idioma.castellano: 'Día',
      Idioma.ingles: 'Day',
    },
    'columna_tarea': {
      Idioma.valenciano: 'Tasca',
      Idioma.castellano: 'Tarea',
      Idioma.ingles: 'Task',
    },
    'columna_inicio': {
      Idioma.valenciano: 'Inici',
      Idioma.castellano: 'Inicio',
      Idioma.ingles: 'Start',
    },
    'columna_fin': {
      Idioma.valenciano: 'Fi',
      Idioma.castellano: 'Fin',
      Idioma.ingles: 'End',
    },
    'columna_duracion': {
      Idioma.valenciano: 'Durada (min)',
      Idioma.castellano: 'Duración (min)',
      Idioma.ingles: 'Duration (min)',
    },
    'horario_de': {
      Idioma.valenciano: 'Horari de',
      Idioma.castellano: 'Horario de',
      Idioma.ingles: 'Schedule for',
    },

    // --- Rutinas ---
    'mis_rutinas': {
      Idioma.valenciano: 'Les meues rutines',
      Idioma.castellano: 'Mis rutinas',
      Idioma.ingles: 'My routines',
    },
    'nueva_rutina': {
      Idioma.valenciano: 'Nova rutina',
      Idioma.castellano: 'Nueva rutina',
      Idioma.ingles: 'New routine',
    },
    'editar_rutina': {
      Idioma.valenciano: 'Editar rutina',
      Idioma.castellano: 'Editar rutina',
      Idioma.ingles: 'Edit routine',
    },
    'eliminar_rutina': {
      Idioma.valenciano: 'Eliminar rutina',
      Idioma.castellano: 'Eliminar rutina',
      Idioma.ingles: 'Delete routine',
    },
    'aun_no_rutinas': {
      Idioma.valenciano: 'Encara no tens rutines',
      Idioma.castellano: 'Aún no tienes rutinas',
      Idioma.ingles: 'You don\'t have any routines yet',
    },
    'nombre_rutina': {
      Idioma.valenciano: 'Nom de la rutina',
      Idioma.castellano: 'Nombre de la rutina',
      Idioma.ingles: 'Routine name',
    },
    'dias_de_la_semana': {
      Idioma.valenciano: 'Dies de la setmana',
      Idioma.castellano: 'Días de la semana',
      Idioma.ingles: 'Days of the week',
    },
    'rutina_activa': {
      Idioma.valenciano: 'Rutina activa',
      Idioma.castellano: 'Rutina activa',
      Idioma.ingles: 'Active routine',
    },
    'tareas_de_la_rutina': {
      Idioma.valenciano: 'Tasques de la rutina',
      Idioma.castellano: 'Tareas de la rutina',
      Idioma.ingles: 'Routine tasks',
    },
    'anadir_tarea_a_rutina': {
      Idioma.valenciano: 'Afegir tasca a la rutina',
      Idioma.castellano: 'Añadir tarea a la rutina',
      Idioma.ingles: 'Add task to routine',
    },
    'aplicar_rutinas': {
      Idioma.valenciano: 'Aplicar rutines',
      Idioma.castellano: 'Aplicar rutinas',
      Idioma.ingles: 'Apply routines',
    },
    'rutinas_aplicadas': {
      Idioma.valenciano: 'S\'han afegit les tasques de les rutines',
      Idioma.castellano: 'Se han añadido las tareas de las rutinas',
      Idioma.ingles: 'Routine tasks have been added',
    },
    'sin_rutinas_coincidentes': {
      Idioma.valenciano: 'No hi ha rutines actives per a este dia',
      Idioma.castellano: 'No hay rutinas activas para este día',
      Idioma.ingles: 'No active routines for this day',
    },
    'lunes_corto': {
      Idioma.valenciano: 'Dl',
      Idioma.castellano: 'Lu',
      Idioma.ingles: 'Mo',
    },
    'martes_corto': {
      Idioma.valenciano: 'Dt',
      Idioma.castellano: 'Ma',
      Idioma.ingles: 'Tu',
    },
    'miercoles_corto': {
      Idioma.valenciano: 'Dc',
      Idioma.castellano: 'Mi',
      Idioma.ingles: 'We',
    },
    'jueves_corto': {
      Idioma.valenciano: 'Dj',
      Idioma.castellano: 'Ju',
      Idioma.ingles: 'Th',
    },
    'viernes_corto': {
      Idioma.valenciano: 'Dv',
      Idioma.castellano: 'Vi',
      Idioma.ingles: 'Fr',
    },
    'sabado_corto': {
      Idioma.valenciano: 'Ds',
      Idioma.castellano: 'Sa',
      Idioma.ingles: 'Sa',
    },
    'domingo_corto': {
      Idioma.valenciano: 'Dg',
      Idioma.castellano: 'Do',
      Idioma.ingles: 'Su',
    },
    'reajustar_horas': {
      Idioma.valenciano: 'Reajustar hores',
      Idioma.castellano: 'Reajustar horas',
      Idioma.ingles: 'Reschedule times',
    },
    'reajustar_horas_desc': {
      Idioma.valenciano: 'Les tasques pendents es reprogramaran a partir d\'ara. Vols continuar?',
      Idioma.castellano: 'Las tareas pendientes se reprogramarán a partir de ahora. ¿Quieres continuar?',
      Idioma.ingles: 'Pending tasks will be rescheduled starting now. Continue?',
    },
    'horas_reajustadas': {
      Idioma.valenciano: 'Hores reajustades',
      Idioma.castellano: 'Horas reajustadas',
      Idioma.ingles: 'Times rescheduled',
    },
    'tarea_hora_fija': {
      Idioma.valenciano: 'Tasca d\'hora fixa',
      Idioma.castellano: 'Tarea de hora fija',
      Idioma.ingles: 'Fixed-time task',
    },
    'tarea_hora_fija_desc': {
      Idioma.valenciano: 'Serà inamovible; la resta de tasques s\'adaptaran a ella',
      Idioma.castellano: 'Será inamovible; el resto de tareas se adaptarán a ella',
      Idioma.ingles: 'It won\'t move; other tasks will adapt around it',
    },

    // --- Copia de seguridad ---
    'copia_seguridad': {
      Idioma.valenciano: 'Còpia de seguretat',
      Idioma.castellano: 'Copia de seguridad',
      Idioma.ingles: 'Backup',
    },
    'copiar_datos': {
      Idioma.valenciano: 'Copiar dades al porta-retalls',
      Idioma.castellano: 'Copiar datos al portapapeles',
      Idioma.ingles: 'Copy data to clipboard',
    },
    'restaurar_datos': {
      Idioma.valenciano: 'Restaurar des del porta-retalls',
      Idioma.castellano: 'Restaurar desde el portapapeles',
      Idioma.ingles: 'Restore from clipboard',
    },
    'datos_copiados': {
      Idioma.valenciano: 'Dades copiades al porta-retalls',
      Idioma.castellano: 'Datos copiados al portapapeles',
      Idioma.ingles: 'Data copied to clipboard',
    },
    'confirmar_restaurar': {
      Idioma.valenciano: 'Restaurar dades',
      Idioma.castellano: 'Restaurar datos',
      Idioma.ingles: 'Restore data',
    },
    'confirmar_restaurar_desc': {
      Idioma.valenciano: 'Això substituirà les teues dades actuals per les del porta-retalls. Vols continuar?',
      Idioma.castellano: 'Esto sustituirá tus datos actuales por los del portapapeles. ¿Quieres continuar?',
      Idioma.ingles: 'This will replace your current data with what\'s in the clipboard. Continue?',
    },
    'restaurar_exito': {
      Idioma.valenciano: 'Dades restaurades correctament',
      Idioma.castellano: 'Datos restaurados correctamente',
      Idioma.ingles: 'Data restored successfully',
    },
    'restaurar_error': {
      Idioma.valenciano: 'El porta-retalls no conté una còpia de seguretat vàlida',
      Idioma.castellano: 'El portapapeles no contiene una copia de seguridad válida',
      Idioma.ingles: 'The clipboard doesn\'t contain a valid backup',
    },

    // --- Deshacer al borrar ---
    'deshacer': {
      Idioma.valenciano: 'Desfer',
      Idioma.castellano: 'Deshacer',
      Idioma.ingles: 'Undo',
    },
    'tarea_eliminada': {
      Idioma.valenciano: 'Tasca eliminada',
      Idioma.castellano: 'Tarea eliminada',
      Idioma.ingles: 'Task deleted',
    },
    'dia_eliminado': {
      Idioma.valenciano: 'Dia eliminat',
      Idioma.castellano: 'Día eliminado',
      Idioma.ingles: 'Day deleted',
    },

    // --- Ocultar completadas ---
    'ocultar_completadas': {
      Idioma.valenciano: 'Ocultar completades',
      Idioma.castellano: 'Ocultar completadas',
      Idioma.ingles: 'Hide completed',
    },
    'mostrar_completadas': {
      Idioma.valenciano: 'Mostrar completades',
      Idioma.castellano: 'Mostrar completadas',
      Idioma.ingles: 'Show completed',
    },

    // --- Vista calendario ---
    'vista_calendario': {
      Idioma.valenciano: 'Vista calendari',
      Idioma.castellano: 'Vista calendario',
      Idioma.ingles: 'Calendar view',
    },
    'vista_lista': {
      Idioma.valenciano: 'Vista llista',
      Idioma.castellano: 'Vista lista',
      Idioma.ingles: 'List view',
    },

    // --- Buscador ---
    'buscar_tareas': {
      Idioma.valenciano: 'Cercar tasques',
      Idioma.castellano: 'Buscar tareas',
      Idioma.ingles: 'Search tasks',
    },
    'buscar_tareas_hint': {
      Idioma.valenciano: 'Nom de la tasca o categoria...',
      Idioma.castellano: 'Nombre de la tarea o categoría...',
      Idioma.ingles: 'Task name or category...',
    },
    'sin_resultados_busqueda': {
      Idioma.valenciano: 'Sense resultats',
      Idioma.castellano: 'Sin resultados',
      Idioma.ingles: 'No results',
    },
  };

  static String t(Idioma idioma, String clave) {
    return _textos[clave]?[idioma] ?? clave;
  }

  // --- Nombres de meses y días de la semana, por idioma ---
  static const Map<Idioma, List<String>> _meses = {
    Idioma.castellano: ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'],
    Idioma.valenciano: ['gen', 'feb', 'mar', 'abr', 'maig', 'jun', 'jul', 'ago', 'set', 'oct', 'nov', 'des'],
    Idioma.ingles: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
  };

  static const Map<Idioma, List<String>> _diasSemana = {
    Idioma.castellano: ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'],
    Idioma.valenciano: ['dl', 'dt', 'dc', 'dj', 'dv', 'ds', 'dg'],
    Idioma.ingles: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
  };

  static String mes(Idioma idioma, int mesNumero1a12) => _meses[idioma]![mesNumero1a12 - 1];
  static String diaSemana(Idioma idioma, int weekday1a7) => _diasSemana[idioma]![weekday1a7 - 1];
}
