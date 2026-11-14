# Evidencias

Capturas **reales** tomadas de GitHub, Azure DevOps y Azure. Formato PNG, legibles (ventana completa, zoom 100 %, URL del navegador visible). Nombre: `NN-descripcion-corta.png`.

> No se publican capturas que muestren IDs de suscripción completos, correos personales, tokens ni claves. Si aparecen, se recortan o se difuminan antes de subirlas.

## 01-repositorio/ — GitHub y equipo

| Archivo | Qué debe mostrar | Responsable |
|---|---|---|
| `01-repositorio-nombre-y-main.png` | Página principal del repo: nombre `ponderix`, rama `main`, README | Juan Sebastián |
| `02-colaboradores-oalarconpe.png` | Settings → Collaborators con `oalarconpe` (estado aceptado o invitación pendiente) | Juan Sebastián |
| `03-proteccion-main.png` | Regla de protección de `main` (PR obligatorio, 1 aprobación, check de CI) | Juan Sebastián |
| `04-historial-commits.png` | `Commits` de `main` con mensajes descriptivos y varios autores | Marlon |
| `05-pull-requests-cerrados.png` | Lista de PR fusionados de los cinco integrantes | Marlon |

## 02-ci/ — Integración Continua

| Archivo | Qué debe mostrar | Responsable |
|---|---|---|
| `01-pruebas-locales.png` | `dotnet test` local con todas las pruebas superadas | David |
| `02-pruebas-en-pipeline.png` | Pestaña *Tests* de una ejecución de CI (100 % superadas) | David |
| `03-conexion-github.png` | Service connection / GitHub App que vincula Azure DevOps con el repo | Jhon |
| `04-pipeline-ci-yaml.png` | Pipeline `ponderix-ci` apuntando a `/pipelines/azure-pipelines-ci.yml` | Jhon |
| `05-disparador-automatico.png` | Ejecución con motivo *Individual CI* / *Continuous integration* y el commit de `main` | Jhon |
| `06-etapas-ci.png` | Diagrama de etapas Validar → Empaquetar en verde | Jhon |
| `07-artefacto-webapp.png` | Artefacto `webapp` con `ponderix-<build>.zip` y `buildinfo.json` | Jhon |
| `08-validacion-pr.png` | Check de CI ejecutado en un Pull Request de GitHub | Jhon |

## 03-cd/ — Entrega Continua

| Archivo | Qué debe mostrar | Responsable |
|---|---|---|
| `01-app-service-overview.png` | Overview del App Service (Linux, .NET 10, estado Running, URL) | Marbel |
| `02-app-service-configuracion.png` | Configuration → General settings (pila, comando de inicio, HTTPS Only) | Marbel |
| `03-service-connection.png` | Service connection `sc-azure-ponderix` (sin datos sensibles visibles) | Marbel |
| `04-entorno-produccion.png` | Environment `ponderix-produccion` con su historial de despliegues | Marbel |
| `05-pipeline-cd-recurso.png` | Ejecución de CD mostrando el recurso `ci` y la ejecución de CI que la disparó | Marbel |
| `06-despliegue-exitoso.png` | Log del paso «Desplegar .zip en App Service» en verde | Marbel |
| `07-prueba-humo.png` | Log de la prueba de humo con el commit publicado | Marbel |

## 04-extremo-a-extremo/ — Mismo cambio de GitHub a Azure

| Archivo | Qué debe mostrar | Responsable |
|---|---|---|
| `01-app-antes-v1-0-0.png` | URL pública con versión 1.0.0 (antes del cambio) | Marlon |
| `02-pr-cambio-visible.png` | PR del cambio a v1.1.0 aprobado y fusionado | Marlon |
| `03-commit-en-main.png` | Commit de fusión en `main` con su SHA | Marlon |
| `04-ci-del-commit.png` | Ejecución de CI del mismo SHA (motivo automático) | Marlon |
| `05-cd-de-esa-ci.png` | Ejecución de CD «CD de CI <build>» disparada por esa CI | Marlon |
| `06-app-despues-v1-1-0.png` | URL pública con la versión 1.1.0 y la novedad visible | Marlon |
| `07-api-version-mismo-commit.png` | `/api/version` mostrando el mismo SHA y build | Marlon |
| `08-script-verificacion.png` | Salida de `verificar-despliegue` con «verificación superada» | Marlon |

## 05-equipo/

| Archivo | Qué debe mostrar | Responsable |
|---|---|---|
| `01-insights-contributors.png` | Insights → Contributors del repositorio | Marlon |
| `02-buscar-secretos.png` | Salida de `buscar-secretos` sin hallazgos | Marlon |
