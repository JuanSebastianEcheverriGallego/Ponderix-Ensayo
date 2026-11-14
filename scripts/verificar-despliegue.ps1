# =============================================================================
# Ponderix · Verificación funcional de la aplicación publicada (PowerShell).
# Responsable: Marlon García Sepúlveda (@M3rl0n)
#
# Uso:
#   .\scripts\verificar-despliegue.ps1 -Url https://ponderix-equipo7.azurewebsites.net
#   .\scripts\verificar-despliegue.ps1 -Url http://localhost:5080 -CommitEsperado local
#
# Si no se indica -CommitEsperado, se usa el último commit de origin/main.
# =============================================================================
param(
    [Parameter(Mandatory = $true)][string]$Url,
    [string]$CommitEsperado
)

$ErrorActionPreference = "Stop"
$Url = $Url.TrimEnd("/")
if (-not $CommitEsperado) {
    git fetch origin main --quiet
    $CommitEsperado = (git rev-parse origin/main).Trim()
}

$script:Fallos = 0
function Ok($texto)    { Write-Host "  [OK]    $texto" -ForegroundColor Green }
function Fallo($texto) { Write-Host "  [FALLO] $texto" -ForegroundColor Red; $script:Fallos++ }

Write-Host "Verificando $Url"
Write-Host "Commit esperado: $CommitEsperado`n"

Write-Host "1) Comprobación de salud (GET /health)"
try { $salud = (Invoke-WebRequest "$Url/health" -TimeoutSec 30 -UseBasicParsing).Content } catch { $salud = "sin respuesta" }
if ($salud -eq "Healthy") { Ok "/health = Healthy" } else { Fallo "/health = $salud" }

Write-Host "2) Versión y trazabilidad (GET /api/version)"
try {
    $v = Invoke-RestMethod "$Url/api/version" -TimeoutSec 30
    $v | Format-List | Out-String | Write-Host
    Ok "versión publicada: $($v.version) · build de CI: $($v.build)"
    if ($v.commit -eq $CommitEsperado) { Ok "commit publicado = commit esperado" }
    else { Fallo "commit publicado ($($v.commit)) distinto del esperado ($CommitEsperado)" }
} catch { Fallo "/api/version no responde: $($_.Exception.Message)" }

Write-Host "3) Funcionalidad real (POST /api/notas/calcular)"
$cuerpo = '{"criterios":[{"nombre":"Nota CI","peso":50,"nota":4.5},{"nombre":"Nota CD","peso":50,"nota":5.0}]}'
try {
    $r = Invoke-RestMethod "$Url/api/notas/calcular" -Method Post -ContentType "application/json" -Body $cuerpo -TimeoutSec 30
    if ([decimal]$r.notaFinal -eq 4.75) { Ok "nota calculada = 4.75 ($($r.nivel))" } else { Fallo "nota calculada = $($r.notaFinal)" }
} catch { Fallo "POST /api/notas/calcular falló: $($_.Exception.Message)" }

Write-Host "4) Validación de errores (pesos que no suman 100 → HTTP 400)"
$codigo = 0
try {
    Invoke-WebRequest "$Url/api/notas/calcular" -Method Post -ContentType "application/json" `
        -Body '{"criterios":[{"nombre":"A","peso":10,"nota":4}]}' -TimeoutSec 30 -UseBasicParsing | Out-Null
    $codigo = 200
} catch { $codigo = [int]$_.Exception.Response.StatusCode }
if ($codigo -eq 400) { Ok "HTTP 400 ante datos inválidos" } else { Fallo "HTTP $codigo ante datos inválidos" }

Write-Host "5) Página web (GET /)"
try {
    $html = (Invoke-WebRequest "$Url/" -TimeoutSec 30 -UseBasicParsing).Content
    if ($html -match "Ponderix") { Ok "la página principal carga" } else { Fallo "la página no contiene 'Ponderix'" }
} catch { Fallo "la página principal no carga" }

Write-Host ""
if ($script:Fallos -eq 0) { Write-Host "RESULTADO: verificación superada." -ForegroundColor Green }
else { Write-Host "RESULTADO: $($script:Fallos) comprobación(es) fallida(s)." -ForegroundColor Red; exit 1 }
