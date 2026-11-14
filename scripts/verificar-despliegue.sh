#!/usr/bin/env bash
# =============================================================================
# Ponderix · Verificación funcional de la aplicación publicada.
# Responsable: Marlon García Sepúlveda (@M3rl0n)
#
# Uso:
#   ./scripts/verificar-despliegue.sh <url-base> [commit-esperado]
# Ejemplos:
#   ./scripts/verificar-despliegue.sh https://ponderix-equipo7.azurewebsites.net
#   ./scripts/verificar-despliegue.sh http://localhost:5080 local
#
# Si no se indica el commit esperado, se usa el último commit de origin/main.
# Requiere: curl y sed (incluidos en Git Bash, Linux y macOS).
# =============================================================================
set -euo pipefail

URL="${1:?Indique la URL base, p. ej. https://ponderix-equipo7.azurewebsites.net}"
URL="${URL%/}"
ESPERADO="${2:-}"
if [ -z "$ESPERADO" ]; then
  git fetch origin main --quiet
  ESPERADO=`git rev-parse origin/main`
fi

leer_json() { # $1 = campo de primer nivel (texto o número). Sin dependencias: solo sed.
  sed -n 's/.*"'"$1"'":"\{0,1\}\([^",}]*\).*/\1/p' | head -1
}

FALLOS=0
ok()   { echo "  [OK]    $1"; }
fallo(){ echo "  [FALLO] $1"; FALLOS=$((FALLOS+1)); }

echo "Verificando $URL"
echo "Commit esperado: $ESPERADO"
echo

echo "1) Comprobación de salud (GET /health)"
SALUD=`curl -fsS --max-time 30 "$URL/health" || echo "sin respuesta"`
[ "$SALUD" = "Healthy" ] && ok "/health = Healthy" || fallo "/health = $SALUD"

echo "2) Versión y trazabilidad (GET /api/version)"
VERSION_JSON=`curl -fsS --max-time 30 "$URL/api/version" || echo '{}'`
echo "$VERSION_JSON"
VERSION=`echo "$VERSION_JSON" | leer_json version || echo "?"`
BUILD=`echo "$VERSION_JSON" | leer_json build || echo "?"`
COMMIT=`echo "$VERSION_JSON" | leer_json commit || echo "?"`
ok "versión publicada: $VERSION · build de CI: $BUILD"
[ "$COMMIT" = "$ESPERADO" ] && ok "commit publicado = commit esperado" || fallo "commit publicado ($COMMIT) distinto del esperado ($ESPERADO)"

echo "3) Funcionalidad real (POST /api/notas/calcular)"
RESP=`curl -fsS --max-time 30 -H "Content-Type: application/json" \
  -d '{"criterios":[{"nombre":"Nota CI","peso":50,"nota":4.5},{"nombre":"Nota CD","peso":50,"nota":5.0}]}' \
  "$URL/api/notas/calcular" || echo '{}'`
echo "$RESP"
NOTA=`echo "$RESP" | leer_json notaFinal || echo "?"`
case "$NOTA" in 4.75|4.750) ok "nota calculada = 4.75 (Excelente)";; *) fallo "nota calculada = $NOTA (se esperaba 4.75)";; esac

echo "4) Validación de errores (pesos que no suman 100 → HTTP 400)"
CODIGO=`curl -s -o /dev/null -w "%{http_code}" --max-time 30 -H "Content-Type: application/json" \
  -d '{"criterios":[{"nombre":"A","peso":10,"nota":4}]}' "$URL/api/notas/calcular"`
[ "$CODIGO" = "400" ] && ok "HTTP 400 ante datos inválidos" || fallo "HTTP $CODIGO ante datos inválidos"

echo "5) Página web (GET /)"
curl -fsS --max-time 30 "$URL/" | grep -q "Ponderix" && ok "la página principal carga" || fallo "la página principal no carga"

echo
if [ "$FALLOS" -eq 0 ]; then
  echo "RESULTADO: verificación superada."
else
  echo "RESULTADO: $FALLOS comprobación(es) fallida(s)."
  exit 1
fi
