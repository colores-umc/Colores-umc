# Setup inicial para los dueños

Este archivo documenta los pasos que tenés que hacer **una sola vez** para dejar todo configurado. Los dueños nunca deberían tener que hacer esto — con que vos lo dejes listo, ellos solo abren el acceso directo y piden cambios.

---

## Cómo es el flujo (preview-first)

Cuando los dueños hagan doble click en el acceso directo:

1. Se chequea que **Node.js** y **VS Code** estén instalados.
2. Si es la primera vez, corre `npm install` para bajar las dependencias (Astro + Tailwind, ~30-60 segundos).
3. Se levanta el **dev server de Astro** en `http://localhost:4321/` (en background).
4. Se abre el **navegador** mostrando la página.
5. Se abre **VS Code** en la carpeta del repo.
6. Queda una ventana de PowerShell esperando una tecla — al apretarla se apaga el dev server.

Una vez abierto, los dueños le piden cambios a Claude desde el panel de la extensión de VS Code. Cada vez que Claude hace un cambio, **Astro tiene hot reload**, así que el navegador se actualiza solo (o con F5 si no).

**El cambio NO se publica automáticamente.** Solo cuando dicen *"subilo"* / *"publicalo"*, Claude hace `git commit` + `git push`. Eso dispara el workflow de **GitHub Actions** ([.github/workflows/deploy.yml](.github/workflows/deploy.yml)) que buildea con `npm run build` y publica `dist/` en GitHub Pages. Total: 2-3 minutos hasta verlo en `colores.ar`.

Si no les gusta, dicen *"sacalo"* y Claude descarta el cambio sin tocar el sitio en producción.

---

## 1. Instalar Node.js (requisito nuevo)

Astro necesita Node.js. **Esto es lo único que cambió respecto del setup viejo.**

1. Andá a **[nodejs.org](https://nodejs.org)**.
2. Bajá la versión **LTS** (debería decir algo como "v24.x.x LTS"). Si la página tiene selectores, pedí: Versión = LTS, Sistema operativo = Windows, Arquitectura = x64, Instalador = .msi.
3. Doble click al `.msi`. Next, Next, Next, Install. Dejá todas las opciones por default (especialmente "Add to PATH" tildado).
4. **Cerrá y reabrí cualquier terminal o VS Code** que tengas abierto, así toman el nuevo PATH.
5. Para verificar: abrí una terminal y corré `node --version`. Tiene que mostrar algo como `v24.x.x`.

### Sobre PowerShell ExecutionPolicy

Por default, Windows tiene la ExecutionPolicy en `Restricted`, lo que impide correr `npm.ps1`. **El launcher usa `npm.cmd` que no se ve afectado**, así que **probablemente no haga falta tocar la política**. Pero si querés que `npm` funcione directo desde la terminal:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

Lo corrés una vez en una terminal de PowerShell, decís `Y` cuando pregunte, y ya queda. Es la config recomendada por Microsoft para devs.

---

## 2. Configurar permisos auto-aprobados de Claude Code

Para que los dueños no tengan que aprobar cada acción, hay que crear `.claude/settings.json` dentro del repo con la config que ya pusiste vos al principio del setup.

> ✅ Este paso ya lo hiciste cuando creaste el `settings.json` al principio.

La config bloquea acciones destructivas (`push --force`, `reset --hard`, `rm -rf`, modificar `git config`) — si Claude alguna vez las intenta, va a frenar y pedir aprobación.

---

## 3. Hosting y deploy

El sitio está en **GitHub Pages** con dominio custom **`https://colores.ar`** (configurado vía DNS en NIC.ar/Cloudflare + archivo [public/CNAME](public/CNAME) en el repo).

**Importante: el modo de deploy cambió.** Antes GitHub Pages servía los `.html` del root de la rama `main` directamente. Ahora hay un build step (Astro genera `dist/`), entonces GitHub Pages tiene que estar configurado para **deploy desde GitHub Actions**, no desde una rama.

### Configurar GitHub Pages para Actions (una vez)

1. Andá a **Settings → Pages** en el repo de GitHub: `https://github.com/coloresumc/Colores-umc/settings/pages`
2. En **"Build and deployment"** → **"Source"**: elegí **"GitHub Actions"** (en vez de "Deploy from a branch").
3. Guardar.
4. La próxima vez que se haga `git push` a `main`, el workflow [.github/workflows/deploy.yml](.github/workflows/deploy.yml) corre, buildea y publica.

### Sobre el dominio `colores.ar`

Ya está activo y configurado. Vive en [public/CNAME](public/CNAME) (Astro lo copia a `dist/` durante el build), y `astro.config.mjs` tiene `site: 'https://colores.ar'` + `base: '/'`.

**Si por alguna razón el dominio dejara de funcionar** y tuvieras que volver a la URL nativa de GitHub Pages (`colores-umc.github.io/Colores-umc/`):
1. Borrar `public/CNAME`.
2. Editar `astro.config.mjs`: `site: 'https://colores-umc.github.io'` y `base: '/Colores-umc'`.
3. Commit + push.
4. Settings → Pages → quitar custom domain.

---

## 4. MCPs recomendados (extensión de VS Code)

Los MCPs (Model Context Protocol) son extensiones que le dan a Claude más capacidades. **Importante**: como usás la extensión de VS Code, no se instalan con `claude mcp add` (eso es para el CLI). Se configuran desde la UI de la extensión o editando el archivo de configuración.

### Cómo agregar un MCP en la extensión de VS Code

**Opción A — Desde la UI**: en VS Code, abrí el panel de Claude Code → ícono de configuración → "MCP servers" → "Add server".

**Opción B — Editando el archivo de config del usuario**: típicamente en `%USERPROFILE%\.claude\mcp.json` o a nivel proyecto en `.claude/mcp.json`. Con un contenido tipo:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp@latest"]
    }
  }
}
```

### MCPs recomendados

**Playwright MCP** (el más valioso): permite que Claude **vea** la página antes de aprobar cambios. Útil para cambios visuales — Claude saca un screenshot del preview local y lo revisa antes de avisarte que está listo.

**GitHub MCP**: ver estado del repo, issues, PRs sin usar `git` por CLI. Nice-to-have.

**Mi recomendación**: instalá **Playwright primero**.

---

## 5. Acceso directo en el escritorio

Hay un script `abrir-claude.bat` (que invoca a `abrir-claude.ps1`) en la raíz del repo. Para crear el acceso directo en el escritorio:

```powershell
powershell -ExecutionPolicy Bypass -File "C:\Users\Sandra Packosky\Desktop\pagina\Colores-umc\crear-acceso-directo.ps1"
```

Esto crea **"Modificar pagina Colores.lnk"** en el escritorio. Cuando hacen doble click, ver el flujo arriba.

> Si querés cambiar el ícono: click derecho sobre el shortcut → Propiedades → "Cambiar icono".

---

## 6. Probar el flujo end-to-end

Antes de dejarlo en producción, hacé esta prueba:

1. Doble click en el acceso directo del escritorio.
2. La primera vez, esperá a que termine `npm install` (mensaje "Dependencias instaladas").
3. Verificá que:
   - Se abrió el navegador en `localhost:4321/` mostrando la página.
   - Se abrió VS Code en la carpeta correcta.
4. En VS Code, abrí el panel de Claude (Ctrl+Esc o el ícono lateral).
5. Pedile: *"cambiá el banner principal de la home con un mensaje de bienvenida navideño"*.
6. Esperá a que termine. El navegador debería actualizarse solo (Astro hot reload). Si no, F5.
7. Verificá que:
   - El cambio se ve.
   - **No** se hizo `git commit` ni `git push` (correr `git status` para confirmar).
8. Pedile: *"subilo"*.
9. Verificá que ahora sí hizo `git commit` + `git push`. Andá a `https://github.com/coloresumc/Colores-umc/actions` y mirá que el workflow "Deploy a GitHub Pages" esté corriendo. Esperá 2-3 minutos y revisá `colores.ar` para confirmar.
10. Pedile: *"deshacé el último cambio"*.
11. Verificá que hizo `git revert` + `git push` y se relanzó el workflow → el sitio vuelve al estado anterior.

Si pasa los tres tests (preview, publicar, revertir), el flujo está listo.

---

## 7. Instrucciones para los dueños

Una vez que todo esté configurado, mandales esto:

> **Para modificar la página:**
>
> 1. Doble click en el ícono **"Modificar pagina Colores"** del escritorio.
> 2. Se abren tres cosas: el navegador con la página, VS Code, y una ventanita negra (PowerShell). No cierren la ventanita negra hasta el final.
>    - **La primera vez tarda un minuto extra** porque baja unas cosas que necesita. Después es rápido.
> 3. En VS Code, abran el chat de Claude (panel lateral o `Ctrl+Esc`).
> 4. Escribí lo que querés cambiar, en castellano normal. Ejemplos:
>    - *"Cambiá la página con tema navideño"*
>    - *"Cambiá el horario de atención a 9 a 18"*
>    - *"Agregá una promoción de fin de año"*
> 5. Cuando Claude termine, **mirá el navegador** — debería actualizarse solo. Si no, F5.
> 6. Si te gusta, decile a Claude: **"subilo"** (o "publicalo"). Va a tardar 2-3 minutos en aparecer en `colores.ar`.
> 7. Si **no** te gusta, decile: **"sacalo"** o "volvé como estaba". El cambio no llega al sitio público.
>
> **Cuando termines de trabajar:**
> - Cerrá VS Code y el navegador como cualquier otra ventana.
> - En la ventanita negra (PowerShell), apretá cualquier tecla para apagar el preview local.
>
> **Si algo salió mal y ya lo subiste**, abrí el ícono de nuevo y escribí: *"deshacé el último cambio"*.
