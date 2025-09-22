
using UnityEngine;

[CreateAssetMenu(menuName="Ranarama/RoomTemplate", fileName="RoomTemplate_XXX")]
public class RoomTemplate : ScriptableObject {
    [TextArea(4, 30)] public string ascii;
    [Tooltip("Legend: '.' floor, '#' wall, ' ' empty, 'D' door marker")] public string legend = ".# D";
    public enum Kind { Corridor, Compact, Arena, Special }
    public Kind kind = Kind.Compact;
    [Range(0f,1f)] public float weight = 1f;
}
