# Hook Pre-Commit de Git para Rutas Compatibles con Windows

Este repositorio está diseñado para evitar commits que contengan rutas o nombres de archivo incompatibles con Windows.

Su componente principal es **pre-commit-windows-paths**: un hook reutilizable de Git que se ejecuta antes de un commit en los repositorios donde lo instales. Revisa solo los archivos en *staging* y bloquea el commit si detecta problemas comunes de compatibilidad con Windows, como:

* Caracteres prohibidos en nombres de archivo
* Nombres de archivo que terminan con un espacio o un punto
* Nombres reservados como `CON`, `AUX`, `COM1` y `LPT1`
* Segmentos de ruta demasiado largos
* Rutas relativas que exceden la longitud recomendada
* Rutas que, al clonarse en Windows, probablemente excedan la longitud máxima soportada

Esta es una herramienta para desarrolladores y equipos que trabajan en Linux y quieren detener archivos incompatibles con Windows en el momento del commit, evitando fallos posteriores de clonación o checkout en Windows.

## Contenido del Repositorio

- `pre-commit-windows-paths`: hook reutilizable principal
- `install-hook.sh`: lo instala en un repositorio objetivo
- `uninstall-hook.sh`: lo elimina de un repositorio objetivo
- `README.md`: instrucciones de uso en inglés
- `README_ES.md`: instrucciones de uso en español

## Por Qué Existe

Linux permite muchos nombres de archivos y carpetas que luego rompen `git clone` o `git checkout` en Windows.

Algunos fallos típicos incluyen:

- un directorio que termina en puntos, como `Acerca de...`
- un nombre reservado como `AUX.txt`
- nombres de archivos o carpetas demasiado largos
- rutas anidadas muy profundas que se vuelven demasiado largas solo al clonarse en una carpeta real de Windows como `C:\Users\Name\Documents\Projects\repo`

Este hook detiene esas rutas en el momento del commit y muestra el problema exacto para que el desarrollador pueda corregirlo antes de hacer push.

## Instalar en un Repositorio

Clona o descarga este repositorio en tu máquina Linux y luego ejecuta:

```bash
chmod +x install-hook.sh
./install-hook.sh /ruta/al/repositorio-objetivo
```

Ese instalador:

- marca el hook como ejecutable
- crea el directorio de hooks del repositorio objetivo si hace falta
- crea un enlace simbólico de `pre-commit-windows-paths` como `.git/hooks/pre-commit` dentro de ese repositorio

Después de eso, `git commit` ejecutará este hook solo en ese repositorio.

## Instalación Manual

Si prefieres instalarlo manualmente en un repositorio específico:

```bash
cd /ruta/al/repositorio-objetivo
mkdir -p .git/hooks
ln -sf /ruta/a/git-pre-commit-hook-windows-path-check/pre-commit-windows-paths .git/hooks/pre-commit
chmod +x /ruta/a/git-pre-commit-hook-windows-path-check/pre-commit-windows-paths
chmod +x .git/hooks/pre-commit
```

## Ajustes Opcionales

Puedes ajustar los límites y la ubicación estimada de clonación en Windows mediante variables de entorno:

```bash
export REPOPATH_SANITIZER_MAX_PATH=260
export REPOPATH_SANITIZER_MAX_SEGMENT=255
export REPOPATH_SANITIZER_CHECKOUT_ROOT='C:\Users\YourUser\Documents\Projects'
```

Reemplaza `YourUser` por el nombre real del usuario de Windows, o usa la carpeta base real donde normalmente se clona el repositorio en Windows.

Esta variable se usa solo para estimar la ruta final del checkout en Windows:

```text
<checkout_root>\<repo_name>\<relative_path>
```

Si quieres que estos valores estén siempre activos, colócalos en tu archivo de inicio del shell, como `~/.bashrc`.

## Cómo Se Comporta

Cuando una ruta en *staging* es problemática, el hook bloquea el commit y muestra:

- la ruta en *staging*
- el código del problema
- una explicación legible

Algunas categorías de ejemplo que puedes ver son:

- `TRAILING_SPACE_PERIOD`
- `RESERVED_DEVICE`
- `SEGMENT_TOO_LONG`
- `PATH_TOO_LONG`
- `CHECKOUT_PATH_TOO_LONG`

## Desinstalar

Si quieres eliminar el hook de un repositorio:

```bash
chmod +x uninstall-hook.sh
./uninstall-hook.sh /ruta/al/repositorio-objetivo
```

## Notas

- El hook revisa solo las rutas en **staging**, porque son las que están a punto de entrar en el historial.
- Es autocontenido y no depende de otra ruta local del proyecto.
- Funciona de manera independiente de cualquier aplicación gráfica.
