# Cómo contribuir a Ponderix

## Reglas del equipo

1. **Nadie hace push directo a `main`.** Todo cambio entra por Pull Request (PR).
2. Una rama por integrante y tarea: `feature/<nombre>-<tema>` (minúsculas, sin tildes).
3. Commits pequeños y descriptivos con el formato `tipo(ámbito): descripción en presente`.
4. Cada PR necesita **1 aprobación** de la persona revisora asignada y la CI en verde (cuando ya exista).
5. Se fusiona con **«Create a merge commit»** (no *squash*) para conservar cada commit con su autor.
6. Las ramas fusionadas **no se borran** hasta la entrega final (sirven de evidencia). Después del 23-nov-2026 pueden borrarse: el PR conserva commits, revisión y autoría.

## Ramas del equipo

| Integrante | Rama | Revisa |
|---|---|---|
| Juan Sebastián | `feature/juan-sebastian-base-aplicacion` | David |
| David | `feature/david-pruebas-automatizadas` | Juan Sebastián |
| Jhon | `feature/jhon-pipeline-ci` y `feature/jhon-insignia-ci` | Marbel |
| Marbel | `feature/marbel-pipeline-cd` | Jhon |
| Marlon | `feature/marlon-version-1-1` y `feature/marlon-evidencias` | Marbel (código) / Juan Sebastián (documentación) |

## Tipos de commit

| Tipo | Uso | Ejemplo |
|---|---|---|
| `feat` | Funcionalidad nueva | `feat(api): agregar endpoint /api/version con datos de build` |
| `test` | Pruebas | `test(api): agregar pruebas de integración de /health` |
| `ci` | Pipeline de CI | `ci: publicar artefacto webapp con buildinfo.json` |
| `cd` | Pipeline de CD | `cd: desplegar artefacto de CI en Azure App Service` |
| `docs` | Documentación | `docs(readme): documentar ejecución local` |
| `chore` | Configuración | `chore: agregar .gitignore para .NET` |
| `fix` | Corrección | `fix(ci): corregir ruta del archivo de solución` |

## Flujo con comandos

```bash
git switch main
git pull origin main                      # traer lo último
git switch -c feature/<nombre>-<tema>     # crear la rama
# ... cambios ...
git status                                # revisar QUÉ se va a subir
git add <archivos>
git commit -m "tipo(ámbito): descripción"
git push -u origin feature/<nombre>-<tema>
# Abrir el PR en GitHub hacia main, asignar revisor y completar la plantilla.
```

Si `main` avanzó mientras trabajabas:

```bash
git fetch origin
git merge origin/main          # resolver conflictos si aparecen
dotnet build Ponderix.slnx && dotnet test Ponderix.slnx
git push
```
