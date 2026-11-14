# =============================================================================
# Ponderix · Busca credenciales subidas por error (archivos actuales + historial).
# Responsable: Marlon García Sepúlveda (@M3rl0n)
#
# Uso (desde la raíz del repositorio):  .\scripts\buscar-secretos.ps1
# Sale con código 1 si encuentra coincidencias sospechosas.
# =============================================================================
$ErrorActionPreference = "Continue"

$patrones = '(userPWD=|PublishProfile|<publishData|AccountKey=|SharedAccessKey=|DefaultEndpointsProtocol=|Password=[^;" ]+|client_secret|clientSecret|-----BEGIN [A-Z ]*PRIVATE KEY-----|ghp_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{30,}|AZURE_CLIENT_SECRET)'
$excluir = @(':(exclude)scripts/buscar-secretos.sh', ':(exclude)scripts/buscar-secretos.ps1')
$hallazgos = $false

Write-Host "1) Archivos prohibidos versionados (.env, perfiles de publicación, claves)"
$prohibidos = git ls-files | Where-Object {
    $_ -match '(^|/)\.env($|\.)|\.publishsettings$|\.pubxml\.user$|\.pfx$|\.pem$|\.key$|secrets\.json$' -and $_ -notmatch '\.env\.example$'
}
if ($prohibidos) { $prohibidos | Write-Host; $hallazgos = $true } else { Write-Host "  ninguno" }

Write-Host "2) Patrones de secretos en los archivos actuales"
$actuales = git grep -nIE $patrones -- . @excluir
if ($actuales) { $actuales | Write-Host; $hallazgos = $true } else { Write-Host "  ninguno" }

Write-Host "3) Patrones de secretos en TODO el historial de commits"
$historial = git log --all -p --no-color -- . @excluir | Select-String -Pattern "^\+.*$patrones"
if ($historial) { $historial | Select-Object -First 50 | ForEach-Object { Write-Host $_.Line }; $hallazgos = $true } else { Write-Host "  ninguno" }

Write-Host ""
if (-not $hallazgos) {
    Write-Host "RESULTADO: no se detectaron secretos." -ForegroundColor Green
} else {
    Write-Host "RESULTADO: revise las coincidencias. Si son secretos reales: revóquelos/rótelos PRIMERO y luego límpielos del historial (ver README, sección 15)." -ForegroundColor Red
    exit 1
}
