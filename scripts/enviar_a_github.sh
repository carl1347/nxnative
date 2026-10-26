#!/usr/bin/env bash
# Envía tu carpeta de juego (.nsp / .xci / .nsz) y tu archivo prod.keys
# directamente desde tu Linux al servidor macos-26 de GitHub Actions usando croc.
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Uso: $0 <carpeta_con_nsp_del_juego> <ruta_a_prod.keys>"
  echo "Ejemplo: $0 ~/Downloads/MarioWonder ~/Downloads/prod.keys"
  exit 1
fi

GAME_DIR="$1"
KEYS_FILE="$2"

if [ ! -d "$GAME_DIR" ]; then
  echo "Error: No existe la carpeta '$GAME_DIR'"
  exit 1
fi

if [ ! -f "$KEYS_FILE" ]; then
  echo "Error: No existe el archivo '$KEYS_FILE'"
  exit 1
fi

if ! command -v croc >/dev/null 2>&1; then
  echo "Instalando croc para envío cifrado directo..."
  curl https://getcroc.schollz.com | bash
fi

export PATH="$HOME/.local/bin:$PATH"

CODE="nxnative-mario-$(tr -dc 'a-z0-9' </dev/urandom | head -c 8)"
echo "=================================================================="
echo " CÓDIGO SECRETO PARA GITHUB ACTIONS:"
echo ""
echo "   $CODE"
echo "=================================================================="

if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  echo "🚀 Lanzando automáticamente el workflow en GitHub Actions (carl1347/nxnative)..."
  gh workflow run build-ipa.yml -R carl1347/nxnative -f transfer_mode=croc -f croc_code="$CODE"
  echo "✅ Workflow iniciado en https://github.com/carl1347/nxnative/actions"
else
  echo " 1. Ve a https://github.com/carl1347/nxnative/actions"
  echo " 2. Selecciona 'Build Switch IPA (A14 / A15 Compatible)'"
  echo " 3. Haz clic en 'Run workflow', pega el código de arriba en 'croc_code'"
  echo "    y presiona el botón verde 'Run workflow'."
fi

echo ""
echo "Esperando a que el runner macos-26 de GitHub Actions reciba los archivos..."

CROC_SECRET="$CODE" croc send "$GAME_DIR" "$KEYS_FILE"
