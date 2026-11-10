#!/usr/bin/env bash
# Build a static site suitable for GitHub Pages.
# Runtime code comes from the 3D-Viewer CDN; this repo only ships project assets.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="$ROOT/dist"

rm -rf "$DIST"
mkdir -p "$DIST/Assets" "$DIST/Textures"

cp "$ROOT/index.html" \
   "$ROOT/studio.json" \
   "$ROOT/api.json" \
   "$DIST/"

cp "$ROOT/Assets/asset.js" "$ROOT/Assets/part.bin" "$DIST/Assets/"
cp "$ROOT/Textures/materials.json" "$DIST/Textures/"

shopt -s nullglob
cp "$ROOT"/Textures/*.{png,jpg,jpeg,webp} "$DIST/Textures/" 2>/dev/null || true
shopt -u nullglob

# Prevent Jekyll from processing the site on GitHub Pages
touch "$DIST/.nojekyll"

echo "Pages build ready in dist/"
