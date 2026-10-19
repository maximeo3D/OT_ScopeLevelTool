# Textures GitHub Pages — instructions pour les autres viewers

À appliquer dans **le dépôt du produit** (la copie du template), pas seulement dans 3D-Viewer. Chaque viewer publie ses propres fichiers. 3D-Viewer n’est pas chargé au runtime.

Ne pas modifier `Textures/materials.json`, ni renommer les PNG. Les matériaux pointent déjà vers les bons fichiers. Le modèle est noir parce que l’éclairage d’environnement n’est pas publié, et la liste Tweakpane est fausse parce que le site statique n’a pas la route du serveur local.

## Symptôme

Sur `https://<user>.github.io/<repo>/` :

- le modèle PBR est noir ;
- la console affiche `GET .../Textures/HDR/default.env` en 404 ;
- la console affiche `GET .../api/textures` en 404, puis « Impossible de charger la liste des textures, utilisation de la liste par défaut » ;
- le menu Textures de Tweakpane ne contient que les noms du template : `color_grid.png`, `filament_albedo.png`, `filament_nm.png`, `alpha.png`, `RGB.png`.

En local avec `serve.ps1`, la route `api/textures` existe et le dossier `Textures/HDR/` est servi. Le problème n’apparaît qu’après le déploiement Pages.

## Cause

1. `scene.js` charge `Textures/HDR/default.env`. Le fichier est dans le dépôt, mais `scripts/build-pages.sh` ne copie pas `Textures/HDR/` dans `dist/`. Sans cette texture, Babylon garde une environment map vide et les matériaux PBR restent noirs. `CreateFromPrefilteredData` ne lève pas d’exception sur un 404, donc le repli sur une lumière hémisphérique ne s’exécute pas.
2. `tweakpaneManager.js` demande `api/textures`. Cette route n’existe que dans `serve.ps1`. GitHub Pages ne sert que `dist/`. En cas d’échec, `getDefaultImages()` renvoie la liste figée du template 3D-Viewer. Le navigateur ne va pas lire un autre dépôt : ces noms sont écrits dans le JavaScript de ce dépôt.

Les PNG à la racine de `Textures/` sont déjà copiés par le script. Ne pas « corriger » le rendu en changeant les couleurs des matériaux.

## Modifications

Deux fichiers. Laisser `serve.ps1` tel quel : il reste la source de `api/textures` en local.

### 1. `scripts/build-pages.sh`

Garder les copies déjà présentes (`index.html`, scripts, `Assets/`, `Textures/materials.json`, PNG/JPG à la racine de `Textures/`). Ne pas remplacer les lignes `Assets/` : les noms de fichiers (`part.bin`, etc.) dépendent du projet.

Ajouter **après** la copie des images et **avant** `touch "$DIST/.nojekyll"` :

```bash
# Environment map. PBR materials render black when this file is missing on Pages.
if [ -d "$ROOT/Textures/HDR" ]; then
  mkdir -p "$DIST/Textures/HDR"
  cp -a "$ROOT/Textures/HDR/." "$DIST/Textures/HDR/"
fi

# Static texture index. GitHub Pages has no /api/textures (that route exists only in serve.ps1).
texture_list="$(mktemp)"
find "$ROOT/Textures" -maxdepth 1 -type f \
  \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.gif' -o -iname '*.bmp' -o -iname '*.tga' \) \
  -printf '%f\n' | sort -u > "$texture_list"

{
  printf '{\n  "images": ['
  first=1
  while IFS= read -r name || [ -n "$name" ]; do
    [ -z "$name" ] && continue
    escaped=${name//\\/\\\\}
    escaped=${escaped//\"/\\\"}
    if [ "$first" -eq 1 ]; then
      first=0
    else
      printf ','
    fi
    printf '\n    "%s"' "$escaped"
  done < "$texture_list"
  if [ "$first" -eq 0 ]; then
    printf '\n'
  fi
  printf '  ]\n}\n'
} > "$DIST/Textures/texture-list.json"
rm -f "$texture_list"
```

Le manifeste est généré depuis les fichiers de **ce** dépôt. Ne pas y coller la liste d’un autre projet.

### 2. `tweakpaneManager.js`

Remplacer `getAvailableImages()` par les deux méthodes ci-dessous. Ne pas réécrire `getDefaultImages()` avec les PNG du projet : cette liste n’est qu’un dernier recours, et elle ne répare ni le site statique ni l’objet noir.

```javascript
async getAvailableImages() {
    // serve.ps1 exposes /api/textures. GitHub Pages is static and publishes Textures/texture-list.json instead.
    const fromApi = await this.loadTextureIndex('api/textures');
    if (fromApi) {
        return fromApi;
    }

    const fromManifest = await this.loadTextureIndex('Textures/texture-list.json');
    if (fromManifest) {
        return fromManifest;
    }

    console.warn('⚠️ Impossible de charger la liste des textures, utilisation de la liste par défaut');
    return this.getDefaultImages();
}

async loadTextureIndex(url) {
    try {
        const response = await fetch(url);
        if (!response.ok) {
            return null;
        }
        const data = await response.json();
        if (!data || !Array.isArray(data.images)) {
            return null;
        }
        const images = {};
        // S'assurer que "None" est toujours en premier
        images['None'] = 'None';
        data.images.forEach(imageName => {
            if (imageName && imageName !== 'None') {
                images[imageName] = imageName;
            }
        });
        return images;
    } catch (_) {
        return null;
    }
}
```

Les chemins restent relatifs (`api/textures`, `Textures/texture-list.json`, `Textures/HDR/default.env`). Ne pas les préfixer par l’URL d’un autre dépôt.

## Vérification

Depuis la racine du dépôt produit :

```bash
bash scripts/build-pages.sh
```

Contrôler :

- `dist/Textures/HDR/default.env` existe (même taille que `Textures/HDR/default.env`) ;
- `dist/Textures/texture-list.json` liste les images à la racine de `Textures/` de ce projet, pas celles du template ;
- les PNG référencés par `Textures/materials.json` sont dans `dist/Textures/`.

Servir `dist/` (`python -m http.server 8000` lancé dans `dist/`) et ouvrir la page :

- `Textures/HDR/default.env` répond 200 ;
- `Textures/texture-list.json` répond 200 ;
- `api/textures` peut rester en 404 : le menu doit quand même afficher les textures de ce projet ;
- le modèle n’est plus noir.

`dist/` est ignoré par git. Pousser les deux fichiers sources sur la branche qui déclenche le workflow Pages (`master` dans le template). Le site publié ne change qu’après ce déploiement.
