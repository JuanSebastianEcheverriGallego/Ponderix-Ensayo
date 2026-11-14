# =============================================================================
# Ponderix · Crea el App Service de Azure (Linux, .NET 10) con Azure CLI.
# Responsable: Marbel Juliana Mejía Bedoya (@JULIANA-s22)
#
# Uso (PowerShell 7 o Windows PowerShell, con Azure CLI instalado):
#   az login
#   .\scripts\crear-recursos-azure.ps1 -AppName ponderix-equipo7 -Location brazilsouth -Sku F1
#
# Azure for Students suele limitar las regiones (p. ej. brazilsouth, canadacentral,
# chilecentral, francecentral, spaincentral). Consultar:
#   az policy assignment list --query "[?displayName=='Allowed resource deployment regions'].parameters"
#
# No guarda ni imprime credenciales.
# =============================================================================
param(
    [Parameter(Mandatory = $true)][string]$AppName,
    [string]$Location = "brazilsouth",
    [string]$Sku = "F1",
    [string]$ResourceGroup = "rg-ponderix",
    [string]$Plan = "asp-ponderix"
)

$ErrorActionPreference = "Stop"
$Runtime = "DOTNETCORE:10.0"

function Invoke-Az {
    az @args
    if ($LASTEXITCODE -ne 0) { throw "Falló: az $($args -join ' ')" }
}

Write-Host "Suscripción activa:"
Invoke-Az account show --query "{nombre:name, id:id}" -o table

Write-Host "1/5 Grupo de recursos $ResourceGroup en $Location"
Invoke-Az group create --name $ResourceGroup --location $Location -o none

Write-Host "2/5 Plan de App Service $Plan (Linux, $Sku)"
Invoke-Az appservice plan create --name $Plan --resource-group $ResourceGroup --is-linux --sku $Sku --location $Location -o none

Write-Host "3/5 Web App $AppName con runtime $Runtime"
Invoke-Az webapp create --name $AppName --resource-group $ResourceGroup --plan $Plan --runtime $Runtime -o none

Write-Host "4/5 Configuración: comando de inicio, TLS 1.2, FTP deshabilitado, HTTPS obligatorio"
Invoke-Az webapp config set --name $AppName --resource-group $ResourceGroup --startup-file "dotnet Ponderix.Api.dll" --min-tls-version 1.2 --ftps-state Disabled --http20-enabled true -o none
Invoke-Az webapp update --name $AppName --resource-group $ResourceGroup --https-only true -o none

Write-Host "5/5 Ruta de comprobación de salud /health"
# En PowerShell las comillas dobles internas se escapan con \" para que lleguen a az.
az webapp config set --name $AppName --resource-group $ResourceGroup --generic-configurations '{\"healthCheckPath\": \"/health\"}' -o none
if ($LASTEXITCODE -ne 0) { Write-Warning "No se pudo activar Health check en este plan; la CD igualmente valida /health." }

Write-Host ""
Write-Host "Listo. Datos para la pipeline de CD (no son secretos):"
Invoke-Az webapp show --name $AppName --resource-group $ResourceGroup --query "{webAppName:name, url:defaultHostName, estado:state, runtime:siteConfig.linuxFxVersion}" -o table
