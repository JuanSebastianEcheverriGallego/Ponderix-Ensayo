#!/usr/bin/env bash
# =============================================================================
# Ponderix · Busca credenciales subidas por error (archivos actuales + historial).
# Responsable: Marlon García Sepúlveda (@M3rl0n)
#
# Uso (desde la raíz del repositorio):  ./scripts/buscar-secretos.sh
# Sale con código 1 si encuentra coincidencias sospechosas.
# Es una comprobación básica; complementa el "secret scanning" de GitHub.
# =============================================================================
set -uo pipefail

PATRONES='(userPWD=|PublishProfile|<publishData|AccountKey=|SharedAccessKey=|DefaultEndpointsProtocol=|Password=[^;" ]+|client_secret|clientSecret|-----BEGIN [A-Z ]*PRIVATE KEY-----|ghp_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{30,}|AZURE_CLIENT_SECRET)'
EXCLUIR=':(exclude)scripts/buscar-secretos.sh :(exclude)scripts/buscar-secretos.ps1'
HALLAZGOS=0

echo "1) Archivos prohibidos versionados (.env, perfiles de publicación, claves)"
PROHIBIDOS=`git ls-files | grep -Ei '(^|/)\.env($|\.)|\.publishsettings$|\.pubxml\.user$|\.pfx$|\.pem$|\.key$|secrets\.json$' | grep -v '\.env\.example$' || true`
if [ -n "$PROHIBIDOS" ]; then echo "$PROHIBIDOS"; HALLAZGOS=1; else echo "  ninguno"; fi

echo "2) Patrones de secretos en los archivos actuales"
# shellcheck disable=SC2086
if git grep -nIE "$PATRONES" -- . $EXCLUIR; then HALLAZGOS=1; else echo "  ninguno"; fi

echo "3) Patrones de secretos en TODO el historial de commits"
# shellcheck disable=SC2086
HIST=`git log --all -p --no-color -- . $EXCLUIR | grep -nIE "^\+.*$PATRONES" || true`
if [ -n "$HIST" ]; then echo "$HIST" | head -50; HALLAZGOS=1; else echo "  ninguno"; fi

echo
if [ "$HALLAZGOS" -eq 0 ]; then
  echo "RESULTADO: no se detectaron secretos."
else
  echo "RESULTADO: revise las coincidencias. Si son secretos reales: revóquelos/rótelos en Azure o GitHub"
  echo "PRIMERO y luego límpielos del historial (ver README, sección 15)."
  exit 1
fi
