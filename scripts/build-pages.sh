#!/usr/bin/env bash
# Build a static site suitable for GitHub Pages (no PowerShell server needed).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="$ROOT/dist"

rm -rf "$DIST"
mkdir -p "$DIST/Assets" "$DIST/Textures"

cp "$ROOT/index.html" \
   "$ROOT/styles.css" \
   "$ROOT/scene.js" \
   "$ROOT/tweakpaneManager.js" \
   "$ROOT/engravingManager.js" \
   "$ROOT/studio.json" \
   "$DIST/"

cp "$ROOT/Assets/asset.js" "$ROOT/Assets/part.bin" "$DIST/Assets/"
cp "$ROOT/Textures/materials.json" "$DIST/Textures/"
# Copy texture images if present
shopt -s nullglob
cp "$ROOT"/Textures/*.{png,jpg,jpeg,webp} "$DIST/Textures/" 2>/dev/null || true
shopt -u nullglob

# Prevent Jekyll from processing the site on GitHub Pages
touch "$DIST/.nojekyll"

echo "Pages build ready in dist/"
