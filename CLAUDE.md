# Página web de Colores

Esta es la página web del comercio **Colores** (colores.ar). Es un sitio estático en HTML + CSS + JS, originalmente generado con Bootstrap Studio 4.

## Quién usa esto

Los dueños del comercio (Sandra y Daniel, +60) van a pedirte cambios en lenguaje natural. Ejemplos típicos:

- "Cambiá la página con tema navideño"
- "Ponele algo del mundial"
- "Subí esta foto nueva al banner"
- "Cambiá el horario de atención"
- "Agregá una promoción en la home"

**Tu objetivo es hacer los cambios pedidos sin que tengan que aprobar nada ni copiar comandos.** Después del cambio, hacé commit y push automáticamente.

## Cómo hablarles

- Explicá lo que hiciste en pocas palabras y en español rioplatense.
- No uses jerga técnica (decí "actualicé el banner principal", no "modifiqué el div .masthead").
- Si algo es ambiguo, hacé la suposición razonable y avisá qué asumiste. No los frenes con preguntas técnicas.
- Si algo puede romper el sitio, sí preguntá antes (ej: borrar páginas enteras, cambiar el dominio).

## Estructura del sitio

### Páginas (todas en la raíz)
- [index.html](index.html) — Home. Tiene el banner principal, lista de rubros, servicios, historia y contacto.
- [armado.html](armado.html) — Sección de armado de regalos.
- [artistica.html](artistica.html) — Sección artística (pinturas, materiales).
- [laneria.html](laneria.html) — Lanería.
- [merceria.html](merceria.html) — Mercería.
- [regaleria.html](regaleria.html) — Regalería.
- [talleres.html](talleres.html) — Talleres que se dictan.
- [FAQ.html](FAQ.html) — Preguntas frecuentes.
- [ubicacion.html](ubicacion.html) — Mapa y dirección.
- [mercado-pago.html](mercado-pago.html) — Información de pago con Mercado Pago.
- [404.html](404.html) — Página de error.

### Recursos
- [assets/css/](assets/css/) — Estilos. **El más importante es `design.css`** (estilos custom). El resto es Bootstrap y libs.
- [assets/img/](assets/img/) — Todas las imágenes. Cada rubro tiene su subcarpeta.
- [assets/js/](assets/js/) — Scripts.
- [popup.css](popup.css) y [popup.js](popup.js) — Sistema de popup promocional (actualmente desactivado en el HTML).
- [robotito.jpg](robotito.jpg) — Imagen suelta usada como ícono.

### Configuración
- [CNAME](CNAME) — Dominio: `colores.ar`. **NO TOCAR** salvo que se cambie de dominio.
- [Cambios.txt](Cambios.txt) — Bitácora histórica del proyecto.

## Colores e identidad visual

La marca usa estos colores:
- **Verde menta principal**: `rgb(142, 211, 194)` / `#8ED3C2`
- **Oscuro (texto y fondos)**: `rgb(33, 37, 41)` / `#212529`

Estos colores aparecen hardcoded en muchos `style="..."` de los HTML. Si te piden un cambio de paleta de toda la página, vas a tener que tocar varios archivos — usá `Grep` para encontrar todas las ocurrencias.

Las **fuentes principales** son:
- `Kaushan Script` para títulos decorativos (logo "colores").
- `Montserrat` para textos.

## Cómo hacer cambios temáticos (lo más pedido)

Cuando piden "cambiá la página con tema X" (navidad, mundial, día del niño, etc.):

1. **No reescribas todo de cero.** Modificá lo justo para que se note el tema.
2. **Cosas seguras de cambiar para un tema**:
   - Banner principal del [index.html](index.html) (sección `header.masthead`): texto del título, subtítulo, imagen de fondo si hay.
   - Colores secundarios (acentos, botones decorativos), pero **mantené el verde menta de la marca** salvo que pidan explícitamente lo contrario.
   - Agregar una imagen decorativa en la home (gorrito de Papá Noel, pelota de fútbol, etc.) — ponela en `assets/img/temporal/` y referenciala desde el HTML.
   - Mensaje promocional o de saludo arriba del banner.
3. **Cosas que NO debés hacer sin preguntar**:
   - Cambiar el logo "colores" o la fuente del logo.
   - Borrar secciones (rubros, servicios, contacto).
   - Cambiar links de navegación o nombres de páginas.
   - Tocar Bootstrap o jQuery (assets/bootstrap/, assets/js/jquery.min.js).
   - Modificar [CNAME](CNAME) o [robots.txt].

## Antes de pushear: chequeo visual

Si hiciste cambios visuales, **abrí la página localmente** para revisar que no se rompió nada antes del push.

Para eso podés correr:
```powershell
python -m http.server 8000
```
y abrir http://localhost:8000

Si ves algo claramente roto (imagen no carga, sección desaparecida, layout descuadrado), avisá y revertí en lugar de pushear.

## Cómo deshacer cambios

Si los dueños dicen "deshacé el último cambio", "no me gusta, volvé atrás", "rompiste algo", etc.:

1. `git log --oneline -5` para ver los últimos commits.
2. `git revert <hash> --no-edit` para deshacer el commit problemático.
3. `git push` para que se publique el rollback.

**Usá `revert`, no `reset --hard`**, así queda historial de la marcha atrás.

## Flujo automático de commit y push

Después de cada cambio significativo:
1. `git add -A`
2. `git commit -m "<mensaje claro en español de qué cambió>"`
3. `git push`

Mensajes de commit en español, claros, en una línea. Ejemplos:
- "Cambio el banner principal a tema navideño"
- "Actualizo el horario de atención en la home"
- "Agrego foto nueva de talleres"

NO incluyas líneas como "Co-Authored-By: Claude" ni emojis técnicos en los commits — los dueños van a ver el historial de git en GitHub y debe ser claro y en su idioma.

## Hosting

El sitio está hosteado en **GitHub Pages** apuntando al dominio `colores.ar` (ver [CNAME](CNAME)). Cualquier push a la rama `main` se publica automáticamente en pocos minutos.

(Pendiente de decidir: migrar a Vercel para tener preview deploys y rollback más visual.)
