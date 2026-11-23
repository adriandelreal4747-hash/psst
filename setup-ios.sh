#!/bin/bash
# Psst: crea (o actualiza) el proyecto de iPhone y lo abre en Xcode.
# Uso: pega en la Terminal de tu Mac:
#   curl -fsSL https://adriandelreal4747-hash.github.io/psst/setup-ios.sh | bash
set -e

echo ""
echo "🤫 Preparando Psst para iPhone…"
echo ""

if ! command -v node >/dev/null 2>&1; then
  echo "❌ Falta Node.js."
  echo "   1) Descárgalo de https://nodejs.org (botón 'LTS') e instálalo."
  echo "   2) Cierra y vuelve a abrir la Terminal."
  echo "   3) Vuelve a pegar el mismo comando."
  exit 1
fi

if ! xcodebuild -version >/dev/null 2>&1; then
  echo "❌ Xcode no está listo."
  echo "   Abre Xcode una vez, acepta la licencia y espera a que termine de instalar componentes."
  echo "   Si ya lo hiciste, corre:  sudo xcode-select -s /Applications/Xcode.app"
  exit 1
fi

BASE="https://adriandelreal4747-hash.github.io/psst"
DIR="$HOME/psst-ios"
mkdir -p "$DIR/www" "$DIR/assets"
cd "$DIR"

echo "⬇️  Descargando la versión más reciente de la app…"
for f in index.html config.js terminos.html privacidad.html manifest.webmanifest icon-192.png icon-512.png og.jpg; do
  curl -fsSL "$BASE/$f?nc=$(date +%s)" -o "www/$f"
done
curl -fsSL "$BASE/icon-1024.png" -o assets/icon-only.png
curl -fsSL "$BASE/splash-2732.png" -o assets/splash.png
cp assets/splash.png assets/splash-dark.png

if [ ! -f package.json ]; then
  npm init -y >/dev/null
fi

echo "📦 Instalando Capacitor (la primera vez tarda un par de minutos)…"
npm install --silent @capacitor/core @capacitor/cli @capacitor/ios @capacitor/share @capacitor/haptics @capacitor/filesystem
npm install --silent -D @capacitor/assets

if [ ! -f capacitor.config.json ] && [ ! -f capacitor.config.ts ]; then
  npx cap init "Psst" "com.adriandelreal.psst" --web-dir www
fi

if [ ! -d ios ]; then
  echo "📱 Creando el proyecto de iPhone…"
  npx cap add ios --packagemanager SPM
fi

echo "🎨 Generando íconos y pantalla de inicio…"
npx capacitor-assets generate --ios --iconBackgroundColor '#7c3aed' --splashBackgroundColor '#7c3aed' >/dev/null

npx cap sync ios

echo ""
echo "✅ ¡Listo! Abriendo Xcode con tu app…"
echo "   Carpeta del proyecto: $DIR"
npx cap open ios
