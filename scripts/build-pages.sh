#!/usr/bin/env bash
# Build a static site suitable for GitHub Pages.
# Runtime code comes from the 3D-Viewer CDN; this repo only ships project assets.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="$ROOT/dist"

rm -rf "$DIST"
mkdir -p "$DIST/Assets" "$DIST/Textures/HDR"

cp "$ROOT/index.html" \
   "$ROOT/studio.json" \
   "$ROOT/api.json" \
   "$DIST/"

cp "$ROOT/Assets/asset.js" "$ROOT/Assets/part.bin" "$DIST/Assets/"
cp "$ROOT/Textures/materials.json" "$DIST/Textures/"

shopt -s nullglob
cp "$ROOT"/Textures/*.{png,jpg,jpeg,webp} "$DIST/Textures/" 2>/dev/null || true
# Environment map required by studio.json (object looks black without it)
cp "$ROOT"/Textures/HDR/*.{env,hdr} "$DIST/Textures/HDR/" 2>/dev/null || true
shopt -u nullglob

# Static texture index for GitHub Pages (replaces serve.ps1 /api/textures)
{
  echo '{'
  echo '  "images": ['
  first=1
  for f in "$DIST"/Textures/*.{png,jpg,jpeg,webp}; do
    [ -f "$f" ] || continue
    name=$(basename "$f")
    if [ "$first" -eq 1 ]; then
      first=0
    else
      echo ','
    fi
    printf '    "%s"' "$name"
  done
  echo
  echo '  ]'
  echo '}'
} > "$DIST/Textures/texture-list.json"

# Prevent Jekyll from processing the site on GitHub Pages
touch "$DIST/.nojekyll"

echo "Pages build ready in dist/"
