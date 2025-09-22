
using UnityEngine;
using UnityEngine.Tilemaps;

[CreateAssetMenu(menuName="Ranarama/Biome", fileName="Biome_XXX")]
public class Biome : ScriptableObject {
    [Header("Visuals")] public string biomeName = "Unnamed";
    public Color ambientLight = Color.white;
    [Tooltip("Hue shift in degrees (-180..180) applied by the palette shader")] public float hueShift = 0f;
    [Range(0f,2f)] public float saturation = 1f;
    [Range(0f,2f)] public float value = 1f;

    [Header("Tiles")] public TileBase floorTile;
    public TileBase wallTile;

    [Header("Room weights")] [Range(0,1)] public float corridorBias = 0.3f;
    [Range(0,1)] public float arenaBias = 0.2f;
    [Range(0,1)] public float compactBias = 0.5f;
}
