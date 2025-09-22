
using UnityEngine;
using UnityEngine.Tilemaps;

public class Room : MonoBehaviour {
    public Tilemap floorTM; public Tilemap wallTM; public RoomTemplate template;
    public Vector2Int gridPos; public bool[] doors = new bool[4]; // N,E,S,W
    public Door[] doorObjs;

    public void Build(Biome biome) {
        if (!template) return;
        var lines = template.ascii.Replace("\r","\n").Split('\n');
        if (floorTM) floorTM.ClearAllTiles();
        if (wallTM) wallTM.ClearAllTiles();
        int ry = 0;
        for (int y = 0; y < lines.Length; y++) {
            var l = lines[y];
            if (string.IsNullOrEmpty(l)) continue;
            for (int x = 0; x < l.Length; x++) {
                char c = l[x];
                var p = new Vector3Int(x, -ry, 0);
                if (c == '.' || c == 'D') { if (biome && biome.floorTile && floorTM) floorTM.SetTile(p, biome.floorTile); }
                else if (c == '#') { if (biome && biome.wallTile && wallTM) wallTM.SetTile(p, biome.wallTile); }
            }
            ry++;
        }
    }

    public void SetLocked(bool locked){
        if (doorObjs == null) return; foreach (var d in doorObjs) if (d) d.SetLocked(locked);
    }
}
