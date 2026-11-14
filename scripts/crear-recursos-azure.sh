#!/usr/bin/env bash
# =============================================================================
# Ponderix · Crea el App Service de Azure (Linux, .NET 10) con Azure CLI.
# Responsable: Marbel Juliana Mejía Bedoya (@JULIANA-s22)
#
# Uso:
#   az login
#   ./scripts/crear-recursos-azure.sh <nombre-app-unico> [region] [sku] [grupo-recursos] [plan]
# Ejemplo:
#   ./scripts/crear-recursos-azure.sh ponderix-equipo7 brazilsouth F1
#
# Azure for Students suele limitar las regiones (p. ej. brazilsouth, canadacentral,
# chilecentral, francecentral, spaincentral). Consultar:
#   az policy assignment list --query "[?displayName=='Allowed resource deployment regions'].parameters"
#
# No guarda ni imprime credenciales. Es idempotente: si los recursos ya existen,
# az los actualiza o informa que existen.
# =============================================================================
set -euo pipefail

APP_NAME="${1:?Indique el nombre del App Service (único en todo Azure), p. ej. ponderix-equipo7}"
LOCATION="${2:-brazilsouth}"
SKU="${3:-F1}"
RESOURCE_GROUP="${4:-rg-ponderix}"
PLAN="${5:-asp-ponderix}"
RUNTIME="DOTNETCORE:10.0"

echo "Suscripción activa:"
az account show --query "{nombre:name, id:id}" -o table

echo "1/5 Grupo de recursos $RESOURCE_GROUP en $LOCATION"
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" -o none

echo "2/5 Plan de App Service $PLAN (Linux, $SKU)"
az appservice plan create --name "$PLAN" --resource-group "$RESOURCE_GROUP" \
  --is-linux --sku "$SKU" --location "$LOCATION" -o none

echo "3/5 Web App $APP_NAME con runtime $RUNTIME"
az webapp create --name "$APP_NAME" --resource-group "$RESOURCE_GROUP" \
  --plan "$PLAN" --runtime "$RUNTIME" -o none

echo "4/5 Configuración: comando de inicio, TLS 1.2, FTP deshabilitado, HTTPS obligatorio"
az webapp config set --name "$APP_NAME" --resource-group "$RESOURCE_GROUP" \
  --startup-file "dotnet Ponderix.Api.dll" \
  --min-tls-version 1.2 --ftps-state Disabled --http20-enabled true -o none
az webapp update --name "$APP_NAME" --resource-group "$RESOURCE_GROUP" --https-only true -o none

echo "5/5 Ruta de comprobación de salud /health"
az webapp config set --name "$APP_NAME" --resource-group "$RESOURCE_GROUP" \
  --generic-configurations '{"healthCheckPath": "/health"}' -o none \
  || echo "AVISO: no se pudo activar Health check en este plan; la CD igualmente valida /health."

echo
echo "Listo. Datos para la pipeline de CD (no son secretos):"
az webapp show --name "$APP_NAME" --resource-group "$RESOURCE_GROUP" \
  --query "{webAppName:name, url:defaultHostName, estado:state, runtime:siteConfig.linuxFxVersion}" -o table
