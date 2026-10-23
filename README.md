# Organizador de tareas Pro

App de organización de tareas con comparativa de tiempo real y estimado,
hecha con Flutter. El mismo código se compila como:

- **APK de Android**: se descarga desde la pestaña **Actions** del repositorio
  (entra en la última ejecución de "Compilar APK y web" → apartado *Artifacts*).
- **Versión web**: se publica sola en GitHub Pages, en
  `https://<tu-usuario>.github.io/<nombre-del-repositorio>/`.

Cada vez que subes cambios a la rama `main`, GitHub Actions vuelve a generar
las dos versiones.

## Estructura

- `lib/models/` – Dia, Tarea, Categoria, Rutina, ListaFavorita, ConfiguracionApp.
- `lib/services/` – guardado de datos, copia de seguridad, estadísticas,
  planificador y rutinas.
- `lib/screens/` – pantallas de la app.
- `lib/i18n/` – traducciones.
- `android/`, `web/` – archivos propios de cada plataforma.
- `.github/workflows/compilar.yml` – compilación automática.

## Probar en tu ordenador

```
flutter pub get
flutter run -d chrome     # versión web
flutter run               # en el móvil o emulador conectado
```
