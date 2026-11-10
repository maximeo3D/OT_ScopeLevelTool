const assetConfiguration = {
  "models": {
    "part_model": {
      "name": "Modèle Part",
      "file": "part.bin",
      "format": "bin",
      "dataOffset": 66,
      "meshes": {
        "scopeleveltool": {
          "slots": [
            "ScoleLeveler",
            "angles",
            "OT"
          ],
          "engraving": false,
          "file": "part.bin"
        }
      },
      "files": [
        {
          "file": "part.bin",
          "format": "bin"
        }
      ]
    }
  },
  "rules": [
    {
      "id": "color",
      "label": "Couleur",
      "options": [
        {
          "id": "red",
          "label": "Black",
          "meshes": {
            "scopeleveltool": {
              "materials": {
                "ScoleLeveler": "scopeleveler_black",
                "angles": "scopeleveler_white",
                "OT": "ot"
              }
            }
          }
        },
        {
          "id": "red22",
          "label": "White",
          "meshes": {
            "scopeleveltool": {
              "materials": {
                "ScoleLeveler": "scopeleveler_white",
                "angles": "scopeleveler_black",
                "OT": "ot"
              }
            }
          }
        }
      ]
    }
  ],
  "defaults": {
    "rules": {
      "color": "red"
    },
    "engravingText": "Test",
    "engravingFont": "Stencil"
  },
  "fonts": [],
  "engravings": []
};
if (typeof module !== 'undefined' && module.exports) {
  module.exports = assetConfiguration;
} else {
  window.assetConfig = assetConfiguration;
}
