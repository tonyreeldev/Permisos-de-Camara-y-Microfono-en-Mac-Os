# Permisos-de-Camara-y-Microfono-en-Mac-Os
Script para conceder permisos de **Cámara** o **Micrófono** a aplicaciones en macOS, usando `tccplus` para modificar directamente la base de datos TCC del sistema.
# Permisos-de-Camara-y-Microfono-en-Mac-Os
Script para conceder permisos de **Cámara** o **Micrófono** a aplicaciones en macOS, usando `tccplus` para modificar directamente la base de datos TCC del sistema.

# 🎥 tcc-permisos.command — Guía de uso

Script para conceder permisos de **Cámara** o **Micrófono** a aplicaciones en macOS, usando `tccplus` para modificar directamente la base de datos TCC del sistema.

---

## ¿Qué hace?

1. **Verifica si `tccplus` está instalado** en `~/Downloads/`. Si no existe, lo descarga automáticamente desde GitHub.
2. **Solicita permisos de administrador** (sudo) de forma automática al inicio — solo debes ingresar tu contraseña una vez.
3. **Escanea tus aplicaciones** instaladas en `/Applications`, `~/Applications` y `/System/Applications`, filtrando solo las que tienen el entitlement del permiso elegido.
4. **Muestra una lista numerada** con el nombre y Bundle ID de cada app encontrada.
5. **Aplica el permiso** seleccionado usando `tccplus` directamente, sin necesidad de ir a Configuración del Sistema.

---

## Requisitos

- macOS (probado en Tahoe 26)
- Conexión a internet (solo si `tccplus` no está descargado)
- Contraseña de administrador

---

## Instalación (primera vez)

### Paso 1 — Descargar el archivo

Descarga `tcc-permisos.command` y guárdalo en `~/Downloads/`.

https://github.com/jslegendre/tccplus

### Paso 2 — Dar permisos de ejecución

Abre **Terminal** y ejecuta:

```bash
chmod +x ~/Downloads/tcc-permisos.command
```

> 💡 **Truco:** Escribe `chmod +x ` en Terminal (con espacio al final) y arrastra el archivo directamente desde el Finder. Presiona Enter.

### Paso 3 — Primera ejecución (Gatekeeper)

La primera vez, macOS bloqueará el archivo por seguridad. Para saltarlo:

1. Click derecho sobre `tcc-permisos.command` en el Finder
2. Selecciona **Abrir**
3. En el diálogo de advertencia, haz click en **Abrir**

Después de esto, ya puedes hacer **doble clic** normal cada vez que quieras usarlo.

---

## Uso

1. **Doble clic** sobre `tcc-permisos.command`
2. Ingresa tu **contraseña de administrador** cuando se solicite
3. Elige el permiso:
   ```
   1) 🎥  Cámara
   2) 🎙  Micrófono
   ```
4. Selecciona el **número** de la app a la que quieres dar permiso
5. El permiso se aplica automáticamente
6. **Cierra y vuelve a abrir** la app para que tome efecto

---

## Ejemplo de ejecución

```
╔══════════════════════════════════════╗
║     🎥  Gestor de Permisos TCC       ║
║       Cámara & Micrófono — macOS     ║
╚══════════════════════════════════════╝

✓  tccplus encontrado en: ~/Downloads/tccplus

¿Qué permiso deseas conceder?

  1)  🎥  Cámara
  2)  🎙  Micrófono

Selecciona [1-2]: 1

🔍  Buscando apps con entitlement de Camera...

Apps encontradas con entitlement 🎥 Camera:
──────────────────────────────────────────────────────
   1)  FaceTime                       com.apple.facetime
   2)  Microsoft Edge                 com.microsoft.edgemac
   3)  Zoom                           us.zoom.xos
   4)  Discord                        com.hnc.Discord
──────────────────────────────────────────────────────

Selecciona el número de la app: 2

⚙  Concediendo permiso de Camera a Microsoft Edge...
   Bundle ID: com.microsoft.edgemac

✓  ¡Listo! Permiso de 🎥 Camera concedido a Microsoft Edge.

   Cierra y vuelve a abrir la app para que tome efecto.

Presiona Enter para cerrar...
```

---

## ¿Por qué no funciona el método normal?

macOS Sequoia y Tahoe tienen restricciones más estrictas en el subsistema **TCC** (Transparency, Consent and Control). En algunos casos, aunque des permiso desde **Configuración del Sistema → Privacidad y Seguridad**, la app no lo reconoce correctamente. `tccplus` escribe directamente en la base de datos TCC, forzando el permiso sin depender del flujo normal del sistema.

---

## Archivos involucrados

| Archivo | Ubicación | Descripción |
|---|---|---|
| `tcc-permisos.command` | `~/Downloads/` | Script principal |
| `tccplus` | `~/Downloads/` | Binario para modificar TCC |

---

## Créditos

- [`tccplus`](https://github.com/jslegendre/tccplus) por jslegendre

Si puedes regalame un caffe 

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ffdd00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://paypal.me/yaba09)
