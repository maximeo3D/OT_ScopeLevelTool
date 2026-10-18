const assetConfiguration = {
  models: {
    "part_model": {
      name: "Scope Level Tool",
      file: "part.glb",
      format: "bin",
      dataOffset: 66,
      meshes: {
        "scopeleveltool": {
          materialSlots: ["slot1", "slot2"],
          tags: ["base"]
        }
      }
    }
  },
  materialConfigs: {
    "scopeleveltool": {
      "black": {
        "slot1": "scopeleveler_black",
        "slot2": "ot"
      },
      "grey": {
        "slot1": "scopeleveler_grey",
        "slot2": "ot"
      },
      "white": {
        "slot1": "scopeleveler_white",
        "slot2": "ot"
      }
    }
  }
};
if (typeof module !== 'undefined' && module.exports) {
  module.exports = assetConfiguration;
} else {
  window.assetConfig = assetConfiguration;
}
