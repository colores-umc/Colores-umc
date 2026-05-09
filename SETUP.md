# Setup inicial para los dueños

Este archivo documenta los pasos que tenés que hacer **una sola vez** para dejar todo configurado. Los dueños nunca deberían tener que hacer esto — con que vos lo dejes listo, ellos solo abren el acceso directo y piden cambios.

---

## Cómo es el flujo (preview-first)

Cuando los dueños hagan doble click en el acceso directo:

1. Se levanta un **servidor local** en `http://localhost:8000` (en background).
2. Se abre el **navegador** mostrando la página tal como está hoy.
3. Se abre **VS Code** en la carpeta del repo (con la extensión de Claude Code).
4. Queda una ventana de PowerShell esperando una tecla — al apretarla se apaga el servidor local.

Una vez abierto, los dueños le piden cambios a Claude desde el panel de la extensión de VS Code. Cada vez que Claude hace un cambio, ellos refrescan el navegador (F5) y ven cómo queda.

**El cambio NO se publica automáticamente.** Solo cuando dicen explícitamente *"subilo"* o *"publicalo"*, Claude hace `git commit` + `git push` y el cambio sale a `colores-umc.github.io/Colores-umc/` en pocos minutos. Si no les gusta, dicen *"sacalo"* y Claude descarta el cambio sin tocar el sitio en producción.

Esto les da una red de seguridad: pueden iterar tranquilos antes de mandar nada al sitio real.

---

## 1. Configurar permisos auto-aprobados de Claude Code

Para que los dueños no tengan que aprobar cada acción, hay que crear el archivo `.claude/settings.json` dentro de este repo, con la configuración que ya pusiste vos al principio del setup.

> ✅ Este paso ya lo hiciste cuando creaste el `settings.json` al principio.

La config bloquea acciones destructivas (`push --force`, `reset --hard`, `rm -rf`, modificar `git config`) — si Claude alguna vez las intenta, va a frenar y pedir aprobación.

---

## 2. Hosting

El sitio está en **GitHub Pages** publicado en `https://colores-umc.github.io/Colores-umc/`. Cualquier push a `main` se publica en 1-3 minutos.

**Sobre el dominio `colores.ar`**: estaba pensado como dominio principal, pero cuando intentamos asignarlo a este repo, GitHub avisó que ya está reclamado por otra cuenta (un repo viejo del proyecto). Mientras esa persona no lo libere, el sitio vive en la URL nativa de GitHub Pages.

**Cuando se libere el dominio**, los pasos son:
1. Crear un archivo `CNAME` en la raíz del repo con el contenido `colores.ar`.
2. Commit y push.
3. Ir a Settings → Pages → "Custom domain" → escribir `colores.ar` → Save.

Si más adelante querés preview deploys más sofisticados, podés migrar a Vercel o Cloudflare Pages, pero no hace falta para este flujo.

---

## 3. MCPs recomendados (extensión de VS Code)

Los MCPs (Model Context Protocol) son extensiones que le dan a Claude más capacidades. **Importante**: como usás la extensión de VS Code, no se instalan con `claude mcp add` (eso es para el CLI). Se configuran desde la UI de la extensión o editando el archivo de configuración.

### Cómo agregar un MCP en la extensión de VS Code

Hay dos formas:

**Opción A — Desde la UI**: en VS Code, abrí el panel de Claude Code → ícono de configuración → "MCP servers" → "Add server".

**Opción B — Editando el archivo de config del usuario**: típicamente en `%USERPROFILE%\.claude\mcp.json` o se puede configurar a nivel proyecto en `.claude/mcp.json`. Con un contenido tipo:

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

> La ubicación exacta y formato pueden variar entre versiones de la extensión. Si tenés dudas, mirá la documentación interna de la extensión (busca "MCP" en el comando palette de VS Code: `Ctrl+Shift+P`).

### MCPs recomendados para este caso de uso

**Playwright MCP** (el más valioso): permite que Claude **vea** la página antes de aprobar cambios. Útil para cambios visuales — Claude puede sacar un screenshot del preview local y revisarlo antes de avisarte que está listo.

**GitHub MCP**: ver estado del repo, issues, PRs sin usar `git` por CLI. Nice-to-have.

**Mi recomendación**: instalá **Playwright primero**. Es el que más valor da para este caso de uso.

---

## 4. Acceso directo en el escritorio

Hay un script `abrir-claude.bat` (que invoca a `abrir-claude.ps1`) en la raíz del repo. Para crear el acceso directo en el escritorio:

```powershell
powershell -ExecutionPolicy Bypass -File "C:\Users\Sandra Packosky\Desktop\pagina\Colores-umc\crear-acceso-directo.ps1"
```

Esto crea **"Modificar pagina Colores.lnk"** en el escritorio. Cuando hacen doble click:
1. Levanta un mini servidor local en PowerShell puro ([serve-local.ps1](serve-local.ps1)) en `http://localhost:8000`. **No requiere Python, Node ni nada instalado** — usa `System.Net.HttpListener` que viene con Windows.
2. Abre el navegador mostrando la página local.
3. Abre VS Code en una ventana nueva apuntando a la carpeta del repo (con `--new-window`, así no se pega a una ventana ya abierta en otra carpeta y las settings de `.claude/settings.json` se aplican bien).
4. Deja una ventanita de PowerShell esperando tecla para apagar el preview cuando terminen.

> Si querés cambiar el ícono: click derecho sobre el shortcut → Propiedades → "Cambiar icono".

---

## 5. Probar el flujo end-to-end

Antes de dejarlo en producción para los dueños, hacé esta prueba:

1. Doble click en el acceso directo del escritorio.
2. Verificá que:
   - Se abrió el navegador en `localhost:8000` mostrando la página.
   - Se abrió VS Code en la carpeta correcta.
3. En VS Code, abrí el panel de Claude (Ctrl+Esc o el ícono lateral).
4. Pedile: *"cambiá el banner principal de la home con un mensaje de bienvenida navideño, sin tocar el resto"*.
5. Esperá a que termine. Refrescá el navegador (F5).
6. Verificá que:
   - El cambio se ve en el navegador.
   - **No** se hizo `git commit` ni `git push` (correr `git status` para confirmar que hay cambios sin commitear).
7. Pedile: *"subilo"*.
8. Verificá que ahora sí hizo `git commit` + `git push`. Esperá 2-3 minutos y revisá `colores-umc.github.io/Colores-umc/` para confirmar.
9. Pedile: *"deshacé el último cambio"*.
10. Verificá que hizo `git revert` + `git push` y el sitio volvió al estado anterior.

Si pasa los tres tests (preview, publicar, revertir), el flujo está listo.

---

## 6. Instrucciones para los dueños

Una vez que todo esté configurado, mandales esto:

> **Para modificar la página:**
>
> 1. Doble click en el ícono **"Modificar pagina Colores"** del escritorio.
> 2. Se abren tres cosas: el navegador con la página, VS Code, y una ventanita negra (PowerShell). No cierren la ventanita negra hasta el final.
> 3. En VS Code, abran el chat de Claude (panel lateral o `Ctrl+Esc`).
> 4. Escribí lo que querés cambiar, en castellano normal. Ejemplos:
>    - *"Cambiá la página con tema navideño"*
>    - *"Cambiá el horario de atención a 9 a 18"*
>    - *"Agregá una promoción de fin de año"*
> 5. Cuando Claude termine, **refrescá el navegador (F5)** para ver cómo quedó.
> 6. Si te gusta, decile a Claude: **"subilo"** (o "publicalo"). Va a hacer los pasos para que aparezca en `colores-umc.github.io/Colores-umc/` en 2-3 minutos.
> 7. Si **no** te gusta, decile: **"sacalo"** o "volvé como estaba". El cambio no llega al sitio público.
>
> **Cuando termines de trabajar:**
> - Cerrá VS Code y el navegador como cualquier otra ventana.
> - En la ventanita negra (PowerShell), apretá cualquier tecla para apagar el preview local.
>
> **Si algo salió mal y ya lo subiste**, abrí el ícono de nuevo y escribí: *"deshacé el último cambio"*.
