# Página web de Colores

Esta es la página web del comercio **Colores** (colores.ar). Es un sitio estático generado con **Astro + Tailwind CSS**.

## Quién usa esto

Los dueños del comercio (Sandra y Daniel, +60) van a pedirte cambios en lenguaje natural. Ejemplos típicos:

- "Cambiá la página con tema navideño"
- "Ponele algo del mundial"
- "Subí esta foto nueva al banner"
- "Cambiá el horario de atención"
- "Agregá una promoción en la home"

**Tu objetivo es hacer los cambios pedidos sin que tengan que aprobar nada ni copiar comandos.**

## Flujo de trabajo (IMPORTANTE)

Cuando se abre el acceso directo, además de Claude se levanta el dev server de Astro en `http://localhost:4321/Colores-umc/` y se abre el navegador con la página. **Los dueños pueden ver los cambios en vivo** — Astro tiene hot reload, así que muchas veces el cambio aparece sin tener que apretar F5. Si no se actualiza solo, refrescan con F5.

El flujo es **preview-first**: vos editás, ellos miran, recién publicás cuando aprueban.

### Después de cada cambio
- **NO hagas `git commit` ni `git push` automáticamente.**
- Avisá en una línea qué cambiaste y decile que mire el navegador.
  - Ejemplo: *"Listo, cambié el banner. Mirá el navegador (si no se actualizó solo, refrescá con F5). Si te gusta, decime 'subilo'."*

### Cuando dicen "subilo" / "publicalo" / "me gusta, dale" / "subí los cambios"
- Hacé `git add -A`, `git commit` con mensaje descriptivo en español, y `git push`.
- Avisá: *"Subido. En 2-3 minutos GitHub Actions buildea y publica en colores-umc.github.io/Colores-umc/."*

### Cuando dicen "no me gusta" / "sacalo" / "volvé como estaba" / "cancelalo"
- Si los cambios **no están commiteados todavía**: `git restore .` para descartar lo no commiteado, y `git clean -fd` solo si agregaste archivos nuevos en este turno (ojo de no borrar `node_modules/` accidentalmente — está en `.gitignore` así que `git clean` no debería tocarlo).
- Si **ya estaba pusheado**: `git revert <hash> --no-edit` y `git push`.

### Cuando dicen "deshacé el último cambio" después de haber subido algo
- `git log --oneline -5` para ver los commits.
- `git revert <hash> --no-edit` del commit problemático.
- `git push` para que el rollback se publique.

### Si no está claro si quieren "preview" o "subir"
- Si la frase es ambigua tipo "ahora cambialo de verdad", asumí que quieren publicarlo.
- Si están iterando ("ahora más rojo", "más grande"), no subas nada hasta que lo aprueben explícitamente.

## Cómo hablarles

- Explicá lo que hiciste en pocas palabras y en español rioplatense.
- No uses jerga técnica. Decí "actualicé el banner principal", no "modifiqué el componente Hero". Decí "cambié los colores de los botones", no "actualicé las clases de Tailwind".
- Si algo es ambiguo, hacé la suposición razonable y avisá qué asumiste. No los frenes con preguntas técnicas.
- Si algo puede romper el sitio, sí preguntá antes (ej: borrar páginas enteras, cambiar el dominio).

## Stack y arquitectura

**Framework**: [Astro 5](https://astro.build) (sitio estático, output HTML).
**Estilos**: [Tailwind CSS 4](https://tailwindcss.com) (atomic classes inline en el markup).
**JS**: vanilla, mínimo. Sin jQuery, sin React, sin Bootstrap. Solo lo que Astro necesita + un IntersectionObserver para animaciones reveal-on-scroll y un lightbox con `<dialog>` nativo.

### Estructura del código

```
src/
├── layouts/
│   └── Layout.astro          # Wrapper de toda página: <html>, head, Header, slot, Footer, Lightbox
├── components/
│   ├── Header.astro          # Nav fija arriba (logo + menú con hamburguesa en mobile)
│   ├── Footer.astro          # Footer con redes y FAQ
│   ├── Lightbox.astro        # Modal nativo (<dialog>) que se abre al click en imágenes con clase .lightbox-trigger
│   ├── PageHero.astro        # Banner para páginas internas (título + subtítulo + opcional imagen de fondo)
│   ├── SectionDivider.astro  # Heading decorativo: línea — TÍTULO — línea
│   ├── ImageGrid.astro       # Grid responsivo de imágenes con captions opcionales (click → lightbox)
│   ├── CategorySection.astro # Sección típica de página categoría: divider + grid + opcional catálogo
│   └── CatalogEmbed.astro    # Iframe de Flipsnack
├── pages/                    # CADA archivo aquí es una URL
│   ├── index.astro           # Home (con hero, rubros, servicios, historia, equipo, marcas, contacto)
│   ├── armado.astro
│   ├── artistica.astro
│   ├── laneria.astro
│   ├── merceria.astro
│   ├── regaleria.astro
│   ├── talleres.astro
│   ├── FAQ.astro
│   ├── ubicacion.astro
│   ├── mercado-pago.astro
│   └── 404.astro             # Astro la sirve para cualquier URL no encontrada
└── styles/
    └── global.css            # Tailwind import + theme custom (colores marca, fuentes, animaciones)

public/                       # Archivos estáticos servidos tal cual (imágenes, etc.)
├── assets/
│   ├── img/                  # Todas las fotos del comercio. Organizadas por rubro.
│   ├── css/                  # CSS legacy (Bootstrap, design.css). NO se usa más, se puede borrar.
│   ├── fonts/                # Font Awesome legacy. NO se usa más.
│   ├── js/                   # JS legacy (jQuery, etc.). NO se usa más.
│   └── bootstrap/            # Bootstrap 4. NO se usa más.
├── popup.css, popup.js       # Sistema de popup que estaba desactivado. No se usa hoy.
└── robotito.jpg              # Imagen del 404
```

### Cómo agregar/cambiar contenido

**Cambiar texto, fotos o estilos en una página existente**: editá el `.astro` correspondiente en `src/pages/`. Los datos de cada página están en el frontmatter (entre `---`) como objetos JS. Por ejemplo, agregar una imagen a la sección "Acero Quirúrgico" en armado: editá [src/pages/armado.astro](src/pages/armado.astro), buscá la sección, agregá un objeto `{ src: img('acero/foto-nueva.jpg') }` al array `images`.

**Subir una foto nueva al sitio**: ponela en `public/assets/img/<rubro>/` y referenciala desde la página correspondiente. Astro las sirve automáticamente.

**Cambiar el menú**: editá `navItems` en [src/components/Header.astro](src/components/Header.astro).

**Cambiar el footer (teléfono, redes, etc.)**: editá [src/components/Footer.astro](src/components/Footer.astro).

**Cambiar colores de marca**: editá las variables CSS en `@theme` dentro de [src/styles/global.css](src/styles/global.css). Los nombres `mint`, `mint-soft`, `mint-deep`, `dark` después funcionan como clases Tailwind (`bg-mint`, `text-dark`, etc.) en cualquier `.astro`.

## Colores e identidad visual

La marca usa estos colores (definidos en [src/styles/global.css](src/styles/global.css)):
- **Verde menta principal**: `#8ED3C2` (clase `mint`)
- **Menta suave**: `#b8e2d4` (clase `mint-soft`)
- **Menta profundo**: `#5fb39d` (clase `mint-deep`)
- **Oscuro**: `#212529` (clase `dark`)

**Fuentes**:
- `Kaushan Script` para títulos decorativos (logo "colores", clase `font-script`)
- `Montserrat` para textos (default, viene de Tailwind)

## Cómo hacer cambios temáticos (lo más pedido)

Cuando piden "cambiá la página con tema X" (navidad, mundial, día del niño, etc.):

1. **No reescribas todo.** Modificá lo justo para que se note el tema.
2. **Cosas seguras de cambiar para un tema**:
   - Hero del [src/pages/index.astro](src/pages/index.astro): texto, gradient de fondo, agregar emoji o imagen decorativa.
   - Mensaje promocional encima del hero o en el footer.
   - Agregar una imagen decorativa: subila a `public/assets/img/temporal/` y referenciala con `${base}/assets/img/temporal/foo.jpg`.
   - Color secundario de algún botón. Pero **mantené el verde menta de la marca** salvo que pidan explícitamente lo contrario.
3. **Cosas que NO debés hacer sin preguntar**:
   - Cambiar el logo "colores" o la fuente del logo.
   - Borrar páginas o secciones enteras.
   - Renombrar archivos en `src/pages/` (cambia las URLs).
   - Modificar `astro.config.mjs` (especialmente `base` — eso cambia las URLs).
   - Crear o modificar `CNAME`, `robots.txt`, `.github/workflows/`, o los scripts del launcher (`abrir-claude.*`, `crear-acceso-directo.ps1`).

## Preview local

Cuando se abre el acceso directo, ya hay un **dev server de Astro** corriendo en `http://localhost:4321/Colores-umc/`. **No tenés que levantarlo vos.** Astro tiene hot reload — cuando editás un `.astro`, el navegador se actualiza solo. Si no, F5.

Si por alguna razón el server no está corriendo, podés sugerirles que cierren todo y abran el acceso directo del escritorio. **Vos no necesitás correr `npm run dev`** salvo que ellos lo pidan explícitamente.

Si tenés Playwright MCP disponible, después de un cambio visual navegá a `http://localhost:4321/Colores-umc/`, sacá un screenshot y revisalo antes de avisar que está listo. Si ves algo claramente roto (imagen no carga, sección desaparecida, layout descuadrado), avisá y descartá el cambio.

## Cómo deshacer cambios

Si los dueños dicen "deshacé el último cambio", "no me gusta, volvé atrás", "rompiste algo", etc.:

1. `git log --oneline -5` para ver los últimos commits.
2. `git revert <hash> --no-edit` para deshacer el commit problemático.
3. `git push` para que se publique el rollback.

**Usá `revert`, no `reset --hard`**, así queda historial de la marcha atrás.

## Flujo automático de commit y push

Después de cada cambio significativo (cuando aprueben):
1. `git add -A`
2. `git commit -m "<mensaje claro en español de qué cambió>"`
3. `git push`

Mensajes de commit en español, claros, en una línea. Ejemplos:
- "Cambio el banner principal a tema navideño"
- "Actualizo el horario de atención en la home"
- "Agrego foto nueva de talleres"

NO incluyas líneas como "Co-Authored-By: Claude" ni emojis técnicos en los commits — los dueños van a ver el historial de git en GitHub y debe ser claro y en su idioma.

## Hosting

El sitio está hosteado en **GitHub Pages** y se publica en `https://colores-umc.github.io/Colores-umc/`. **El deploy NO es directo desde main** — corre [.github/workflows/deploy.yml](.github/workflows/deploy.yml) en cada push: instala deps, hace `npm run build`, y publica el output `dist/`. Tarda 2-3 minutos.

> El dominio `colores.ar` está reclamado por otra cuenta de GitHub y por ahora no se puede usar. Cuando se libere, hay que crear un `CNAME` con el contenido `colores.ar`, ajustar `site` y `base` en [astro.config.mjs](astro.config.mjs) (probablemente `site: 'https://colores.ar'` y `base: '/'`), y configurar el custom domain en Settings → Pages. Mientras tanto, cuando avises que un cambio "ya se publicó", referite a `colores-umc.github.io/Colores-umc/`.

## Configuración y launcher

- **`CNAME`** — Actualmente **no existe** en el repo (ver "Hosting").
- [abrir-claude.bat](abrir-claude.bat), [abrir-claude.ps1](abrir-claude.ps1), [crear-acceso-directo.ps1](crear-acceso-directo.ps1) — Scripts del launcher. Ahora **requieren Node.js instalado**. **NO los modifiques sin avisar** — si se rompen, los dueños no pueden trabajar. Cualquier cambio probalo end-to-end antes de subirlo.
- [SETUP.md](SETUP.md) — Documenta el setup inicial (instalar Node, configurar GitHub Pages para deploy desde Actions, etc.). Para el desarrollador, no para los dueños.
- [astro.config.mjs](astro.config.mjs) — Config de Astro. **No modifiques** `site` ni `base` sin pensarlo bien — cambian las URLs del sitio.
- [package.json](package.json) — Dependencias. No modifiques `scripts` (el launcher depende de `dev` y `build`).

## Archivos históricos (NO los uses como guía)

- [README.md](README.md) y [Cambios.txt](Cambios.txt) describen el flujo viejo basado en **Bootstrap Studio 4**, ya no se usa. No los leas como referencia. No los borres salvo que los dueños lo pidan.
- `public/assets/bootstrap/`, `public/assets/css/*.css`, `public/assets/js/*.js`, `public/assets/fonts/` — assets legacy del sitio Bootstrap. No los carga ninguna página actual. Se pueden borrar si ocupan espacio (~10MB), pero no urge.
- `public/popup.css`, `public/popup.js` — sistema de popup que nunca llegó a producción. No se usa.
