/**
 * Organizador de tareas Pro - sincronización entre el móvil y la web.
 *
 * Guarda una copia de todos los datos de la app en un archivo de tu Google
 * Drive ("organizador_tareas_pro_datos.json"). La app la lee y la escribe.
 *
 * IMPORTANTE: cambia CLAVE por tu clave secreta (la misma que escribas en la
 * app, en Ajustes → Sincronización). Sin la clave nadie puede leer tus datos.
 */
const CLAVE = 'PON_AQUI_TU_CLAVE_SECRETA';
const NOMBRE_ARCHIVO = 'organizador_tareas_pro_datos.json';

function archivo_() {
  const archivos = DriveApp.getFilesByName(NOMBRE_ARCHIVO);
  return archivos.hasNext() ? archivos.next() : null;
}

function leer_() {
  const f = archivo_();
  if (!f) return { modificado: 0, datos: null };
  return JSON.parse(f.getBlob().getDataAsString());
}

function responder_(objeto) {
  return ContentService.createTextOutput(JSON.stringify(objeto))
    .setMimeType(ContentService.MimeType.JSON);
}

/** La app pide los datos guardados en la nube. */
function doGet(e) {
  if (!e || !e.parameter || e.parameter.clave !== CLAVE) {
    return responder_({ ok: false, error: 'clave incorrecta' });
  }
  const guardado = leer_();
  return responder_({ ok: true, modificado: guardado.modificado, datos: guardado.datos });
}

/** La app envía sus datos para guardarlos en la nube. */
function doPost(e) {
  const cuerpo = JSON.parse(e.postData.contents);
  if (cuerpo.clave !== CLAVE) {
    return responder_({ ok: false, error: 'clave incorrecta' });
  }
  const bloqueo = LockService.getScriptLock();
  bloqueo.waitLock(20000);
  try {
    const actual = leer_();
    // Si en la nube hay algo más reciente, no se pisa (salvo que se fuerce).
    if (!cuerpo.forzar && cuerpo.modificado < actual.modificado) {
      return responder_({ ok: false, error: 'antiguo', modificado: actual.modificado });
    }
    const contenido = JSON.stringify({ modificado: cuerpo.modificado, datos: cuerpo.datos });
    const f = archivo_();
    if (f) {
      f.setContent(contenido);
    } else {
      DriveApp.createFile(NOMBRE_ARCHIVO, contenido, MimeType.PLAIN_TEXT);
    }
    return responder_({ ok: true, modificado: cuerpo.modificado });
  } finally {
    bloqueo.releaseLock();
  }
}
