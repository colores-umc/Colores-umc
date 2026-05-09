# Setup inicial para los dueños

Este archivo documenta los pasos que tenés que hacer **una sola vez** para dejar todo configurado. Los dueños nunca deberían tener que hacer esto — con que vos lo dejes listo, ellos solo abren Claude Code y piden cambios.

---

## 1. Configurar permisos auto-aprobados de Claude Code

Para que los dueños no tengan que aprobar cada acción, hay que crear el archivo `.claude/settings.json` dentro de este repo, con la siguiente configuración:

**Ruta**: `.claude/settings.json` (dentro de `Colores-umc/`)

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Write",
      "Edit",
      "Glob",
      "Grep",
      "TodoWrite",
      "WebFetch",
      "WebSearch",
      "Bash(git status*)",
      "Bash(git diff*)",
      "Bash(git log*)",
      "Bash(git add*)",
      "Bash(git commit*)",
      "Bash(git push*)",
      "Bash(git pull*)",
      "Bash(git fetch*)",
      "Bash(git branch*)",
      "Bash(git checkout*)",
      "Bash(git revert*)",
      "Bash(git restore*)",
      "Bash(git stash*)",
      "Bash(python -m http.server*)",
      "Bash(start *)",
      "Bash(ls*)",
      "Bash(echo*)",
      "PowerShell(git status*)",
      "PowerShell(git diff*)",
      "PowerShell(git log*)",
      "PowerShell(git add*)",
      "PowerShell(git commit*)",
      "PowerShell(git push*)",
      "PowerShell(git pull*)",
      "PowerShell(git fetch*)",
      "PowerShell(git branch*)",
      "PowerShell(git checkout*)",
      "PowerShell(git revert*)",
      "PowerShell(git restore*)",
      "PowerShell(Start-Process*)"
    ],
    "deny": [
      "Bash(git push --force*)",
      "Bash(git reset --hard*)",
      "Bash(rm -rf*)",
      "Bash(git branch -D*)",
      "Bash(git config*)",
      "PowerShell(git push --force*)",
      "PowerShell(git reset --hard*)",
      "PowerShell(Remove-Item -Recurse -Force*)",
      "PowerShell(git branch -D*)",
      "PowerShell(git config*)"
    ]
  }
}
```

**Por qué esta config**:
- Permite todo lo que Claude necesita para editar archivos y hacer commit + push sin pedir confirmación.
- **Bloquea** acciones destructivas (`push --force`, `reset --hard`, `rm -rf`, borrar branches, modificar git config) — si Claude alguna vez las intenta, va a frenar y pedir aprobación.

> Claude Code no puede crear este archivo automáticamente porque modifica sus propios permisos. Tenés que crearlo a mano.

---

## 2. Hook opcional: auto-commit + auto-push al terminar

Este hook hace que después de cada respuesta de Claude se haga commit + push automáticamente, así los dueños no tienen que pedirlo cada vez.

Agregá esto al `settings.json` dentro de `permissions`, al mismo nivel:

```json
{
  "permissions": { ... },
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "powershell -NoProfile -Command \"if ((git status --porcelain).Length -gt 0) { git add -A; git commit -m 'auto: cambios desde Claude Code'; git push }\""
          }
        ]
      }
    ]
  }
}
```

**Pros**: cero fricción, los cambios se publican solos.
**Contras**: si Claude se equivoca, el error queda pusheado al toque. **Mitigación**: los dueños siempre pueden decir "deshacé el último cambio" y Claude hace `git revert`.

**Mi recomendación**: en lugar del hook, dejá que Claude haga el commit + push como parte de cada respuesta (ya está documentado en CLAUDE.md). Eso te permite que Claude elija un mensaje de commit descriptivo en español, en vez de "auto: cambios". Si querés el hook igual, agregalo.

---

## 3. Hosting

Actualmente la página está en **GitHub Pages** apuntando a `colores.ar` (ver archivo CNAME). Tenés tres opciones:

### Opción A — Quedarse con GitHub Pages (lo más simple)
- Ya funciona. Cualquier push a `main` se publica en pocos minutos.
- No tiene preview deploys ni rollback con un click, pero sí está el `git revert` que ya documentamos.
- **Cero setup adicional.**

### Opción B — Migrar a Vercel
1. Ir a https://vercel.com → "New Project" → conectar el repo `colores-umc/Colores-umc`.
2. Framework preset: "Other" (es estático).
3. Build command: dejar vacío. Output directory: dejar `.` (raíz).
4. Configurar dominio `colores.ar` desde el dashboard de Vercel y actualizar los DNS.
5. Borrar el archivo `CNAME` del repo (ya no hace falta para GitHub Pages).

**Ventajas de Vercel**: preview URLs por cada branch, rollback con un click, mejor analytics, CDN global.
**Desventaja**: tenés que migrar los DNS — el sitio puede estar 5-30 min sin servicio durante el cambio.

### Opción C — Cloudflare Pages
Similar a Vercel, gratis, integra bien con dominios `.ar` (Cloudflare es popular para AR). Mismo flujo: conectás el repo, configurás el dominio.

**Mi recomendación**: como dijiste "deploy directo a producción", **quedate con GitHub Pages por ahora**. Cero migración, ya funciona. Si más adelante querés preview deploys, migrar a Vercel toma 15 minutos.

---

## 4. MCPs recomendados

Los MCPs (Model Context Protocol) son extensiones que le dan a Claude más capacidades.

### GitHub MCP (oficial)
**Para qué**: ver issues, PRs, estado del repo desde Claude sin usar `git` por CLI. Útil si en algún momento abrís PRs o usás issues.

**Cómo instalar** (una vez, en la PC de los dueños):
```powershell
claude mcp add github -- npx -y @modelcontextprotocol/server-github
```
Luego configurar el `GITHUB_TOKEN` en variables de entorno (un Personal Access Token de GitHub con permisos de repo).

### Vercel MCP (si elegís Vercel)
**Para qué**: ver estado de deploys, hacer rollback, ver logs.
```powershell
claude mcp add vercel -- npx -y @vercel/mcp-server
```

### Playwright MCP (muy recomendado)
**Para qué**: que Claude pueda **ver** la página antes de pushear. Esto es oro para cambios visuales.
```powershell
claude mcp add playwright -- npx -y @playwright/mcp@latest
```

Con esto, después de cambiar algo Claude puede abrir el sitio local, sacar un screenshot, verificar que se ve bien, y recién ahí pushear.

**Mi recomendación**: instalá **Playwright primero**. Es el que más valor da para este caso de uso.

---

## 5. Acceso directo en el escritorio

Hay un script `abrir-claude.bat` en la raíz del repo. Para crear el acceso directo:

1. Click derecho en `abrir-claude.bat` → "Crear acceso directo".
2. Mover el acceso directo al escritorio.
3. Click derecho → "Propiedades" → cambiar el ícono a algo identificable (un pincel, un corazón, lo que sea).
4. Renombrarlo a algo claro: "Modificar página Colores".

Cuando los dueños hagan doble click, se les abre PowerShell con Claude Code listo en la carpeta del repo.

---

## 6. Probar el flujo end-to-end

Antes de dejarlo en producción para los dueños, hacé esta prueba:

1. Abrí Claude Code en este repo.
2. Pedile: "cambiá el banner principal de la home con un mensaje de bienvenida navideño, sin tocar el resto".
3. Verificá que:
   - Hizo el cambio en `index.html`.
   - No te pidió aprobación para nada.
   - Hizo `git commit` con un mensaje claro en español.
   - Hizo `git push` automáticamente.
4. Esperá unos minutos y revisá `colores.ar` para confirmar que el cambio se publicó.
5. Pedile: "deshacé el último cambio".
6. Verificá que hizo `git revert` + `git push` y el sitio volvió al estado anterior.

Si pasa los dos tests, el flujo está listo.

---

## 7. Instrucciones para los dueños

Una vez que todo esté configurado, mandales esto:

> **Para modificar la página:**
> 1. Hacer doble click en el acceso directo "Modificar página Colores".
> 2. Escribir lo que querés cambiar, en castellano normal. Ejemplos:
>    - "Cambiá la página con tema navideño"
>    - "Subí esta foto al banner: ..." (arrastrar la foto a la ventana)
>    - "Cambiá el horario de atención a 9 a 18"
>    - "Agregá una promoción de fin de año"
> 3. Esperar a que Claude termine. Te va a decir qué cambió y que ya se publicó.
> 4. Esperar 2-3 minutos y revisar `colores.ar` para verlo en vivo.
>
> **Si algo salió mal**, escribir: "deshacé el último cambio" o "volvé como estaba antes".
