
        using UnityEngine;
        using UnityEngine.Tilemaps;
        using System.Collections.Generic;
        using System.Linq;

        public class DungeonGen : MonoBehaviour {
            [Header("Grid size")] public int cols = 9; public int rows = 7; public Vector2 roomWorldSize = new(18,12);
            [Header("Clusters & Biomes")] public int clusterCount = 4; public Biome[] biomes;
            [Header("Rooms")] public Room roomPrefab; public RoomTemplate[] templates; public Transform roomsRoot;
            [Header("Portals")] public Portal portalPrefab; public int portalsBetweenClusters = 3;
            [Header("Seed")] public int seed = 12345; public bool randomizeSeed = true;

            private Room[,] grid; private int[,] clusterIdx; private List<List<Vector2Int>> clusters = new();

            void Start(){ if(randomizeSeed) seed = UnityEngine.Random.Range(0,int.MaxValue); RNG.Seed(seed); Generate(); }

            public void Generate(){
                Clear();
                grid = new Room[cols,rows]; clusterIdx = new int[cols,rows]; for(int x=0;x<cols;x++) for(int y=0;y<rows;y++) clusterIdx[x,y]=-1;

                // Ensure root
                if (roomsRoot == null) roomsRoot = this.transform;

                // 0) If no assets assigned, auto-create in-memory demo data
                EnsureBiomes(); EnsureTemplates();

                // 1) Choose active cells via main path + branches
                var active = CarveLayout();
                // 2) Cluster active cells (k-means lite)
                Clusterize(active);
                // 3) Place rooms and build from templates with biome colors
                BuildRooms(active);
                // 4) Link clusters with portals
                PlacePortals();
            }

            void Clear(){ if (roomsRoot==null) roomsRoot = this.transform; for(int i=roomsRoot.childCount-1;i>=0;i--) DestroyImmediate(roomsRoot.GetChild(i).gameObject); clusters.Clear(); }

            HashSet<Vector2Int> CarveLayout(){
                var act = new HashSet<Vector2Int>();
                Vector2Int start = new Vector2Int(RNG.Range(0,cols), RNG.Range(0,rows));
                var stack = new Stack<Vector2Int>(); stack.Push(start); act.Add(start);
                var visited = new HashSet<Vector2Int>(); visited.Add(start);
                Vector2Int[] dirs = {Vector2Int.up, Vector2Int.right, Vector2Int.down, Vector2Int.left};
                int target = Mathf.Max( (int)(cols*rows*0.45f), 8 );
                while(stack.Count>0 && act.Count<target){
                    var c = stack.Peek();
                    var neigh = dirs.Select(d=>c+d).Where(n=>n.x>=0 && n.x<cols && n.y>=0 && n.y<rows && !visited.Contains(n)).ToList();
                    if(neigh.Count==0){ stack.Pop(); continue; }
                    var n2 = neigh[RNG.Range(0,neigh.Count)]; act.Add(n2); visited.Add(n2); stack.Push(n2);
                }
                // branches
                int extra = Mathf.Max(4, (int)(act.Count*0.3f));
                for(int i=0;i<extra;i++){ var c = act.ElementAt(RNG.Range(0,act.Count)); int len = RNG.Range(2,5); var p=c; for(int k=0;k<len;k++){ var d = dirs[RNG.Range(0,4)]; var q = p+d; if(q.x<0||q.x>=cols||q.y<0||q.y>=rows) break; act.Add(q); p=q; } }
                return act;
            }

            void Clusterize(HashSet<Vector2Int> active){
                clusterCount = Mathf.Clamp(clusterCount, 2, Mathf.Min(8, active.Count));
                var seeds = active.OrderBy(_=>RNG.Value()).Take(clusterCount).ToList();
                var centers = seeds.Select(v=>new Vector2(v.x+0.5f,v.y+0.5f)).ToArray();
                for(int it=0; it<8; it++){
                    for(int x=0;x<cols;x++) for(int y=0;y<rows;y++) clusterIdx[x,y]=-1;
                    int[] counts = new int[clusterCount]; Vector2[] sum = new Vector2[clusterCount];
                    foreach(var cell in active){
                        int ci = Closest(centers, new Vector2(cell.x+0.5f, cell.y+0.5f));
                        clusterIdx[cell.x,cell.y]=ci; counts[ci]++; sum[ci]+= new Vector2(cell.x+0.5f, cell.y+0.5f);
                    }
                    for(int i=0;i<clusterCount;i++){ if(counts[i]>0) centers[i]=sum[i]/counts[i]; }
                }
                clusters = Enumerable.Range(0, clusterCount).Select(_=>new List<Vector2Int>()).ToList();
                for(int x=0;x<cols;x++) for(int y=0;y<rows;y++) if(clusterIdx[x,y]>=0) clusters[clusterIdx[x,y]].Add(new Vector2Int(x,y));
            }

            int Closest(Vector2[] c, Vector2 p){ int idx=0; float bd=float.MaxValue; for(int i=0;i<c.Length;i++){ float d=(c[i]-p).sqrMagnitude; if(d<bd){bd=d; idx=i;} } return idx; }

            void BuildRooms(HashSet<Vector2Int> active){
                var biomeByCluster = new Biome[clusterCount];
                for(int i=0;i<clusterCount;i++){ biomeByCluster[i] = biomes[i % biomes.Length]; }
                foreach(var cell in active){
                    var b = biomeByCluster[clusterIdx[cell.x,cell.y]];
                    var t = PickTemplateForBiome(b);
                    var roomGO = Instantiate(roomPrefab, CellToWorld(cell), Quaternion.identity, roomsRoot);
                    roomGO.gridPos = new Vector2Int(cell.x, cell.y); roomGO.template = t; roomGO.Build(b);
                    grid[cell.x,cell.y] = roomGO;
                }
                // doors flags (open to neighbors)
                Vector2Int[] dirs = {Vector2Int.up, Vector2Int.right, Vector2Int.down, Vector2Int.left};
                foreach(var cell in active){
                    var r = grid[cell.x,cell.y]; if (!r) continue;
                    for(int i=0;i<4;i++){ var n = cell + dirs[i]; if(n.x<0||n.x>=cols||n.y<0||n.y>=rows) continue; if (grid[n.x,n.y]) r.doors[i]=true; }
                }
            }

            RoomTemplate PickTemplateForBiome(Biome b){
                var list = new List<RoomTemplate>();
                foreach(var t in templates){
                    float w = t.weight;
                    if (t.kind == RoomTemplate.Kind.Corridor) w *= Mathf.Lerp(0.5f, 1.5f, b.corridorBias);
                    if (t.kind == RoomTemplate.Kind.Compact) w *= Mathf.Lerp(0.5f, 1.5f, b.compactBias);
                    if (t.kind == RoomTemplate.Kind.Arena)   w *= Mathf.Lerp(0.5f, 1.5f, b.arenaBias);
                    int copies = Mathf.Max(1, Mathf.RoundToInt(w*3f)); for(int i=0;i<copies;i++) list.Add(t);
                }
                return list[ RNG.Range(0, list.Count) ];
            }

            void PlacePortals(){
                if (!portalPrefab) return;
                var borders = new List<(Vector2Int from, Vector2Int to, int ci, int cj)>();
                Vector2Int[] dirs = {Vector2Int.up, Vector2Int.right, Vector2Int.down, Vector2Int.left};
                for(int x=0;x<cols;x++) for(int y=0;y<rows;y++){
                    if (grid[x,y]==null) continue; int ci = clusterIdx[x,y];
                    for(int d=0; d<4; d++){
                        var n = new Vector2Int(x,y)+dirs[d]; if(n.x<0||n.x>=cols||n.y<0||n.y>=rows) continue; if(grid[n.x,n.y]==null) continue; int cj = clusterIdx[n.x,n.y]; if (ci!=cj){ borders.Add((new Vector2Int(x,y), n, ci, cj)); }
                    }
                }
                borders = borders.OrderBy(_=>RNG.Value()).ToList(); int placed = 0; var usedPairs = new HashSet<string>();
                foreach(var b in borders){ if (placed>=portalsBetweenClusters) break; string key = b.ci < b.cj ? $"{b.ci}-{b.cj}" : $"{b.cj}-{b.ci}"; if (usedPairs.Contains(key)) continue; usedPairs.Add(key);
                    var A = grid[b.from.x,b.from.y]; var B = grid[b.to.x,b.to.y];
                    var p1 = Instantiate(portalPrefab, A.transform.position + new Vector3(roomWorldSize.x*0.4f,0,0), Quaternion.identity, roomsRoot);
                    var p2 = Instantiate(portalPrefab, B.transform.position - new Vector3(roomWorldSize.x*0.4f,0,0), Quaternion.identity, roomsRoot);
                    p1.target = p2; p2.target = p1; placed++;
                }
            }

            Vector3 CellToWorld(Vector2Int cell){ return new Vector3(cell.x*roomWorldSize.x, cell.y*roomWorldSize.y, 0f); }

            // ---------- Helpers to auto-provide demo assets ----------
            void EnsureBiomes(){
                if (biomes != null && biomes.Length > 0) return;
                biomes = new Biome[4];
                biomes[0] = ScriptableObject.CreateInstance<Biome>(); biomes[0].biomeName = "Blue";   biomes[0].hueShift = 200; biomes[0].saturation = 1.1f; biomes[0].value = 1.0f;
                biomes[1] = ScriptableObject.CreateInstance<Biome>(); biomes[1].biomeName = "Magenta";biomes[1].hueShift = -150;biomes[1].saturation = 1.2f; biomes[1].value = 0.95f;
                biomes[2] = ScriptableObject.CreateInstance<Biome>(); biomes[2].biomeName = "Green";  biomes[2].hueShift = 100; biomes[2].saturation = 1.0f; biomes[2].value = 1.05f;
                biomes[3] = ScriptableObject.CreateInstance<Biome>(); biomes[3].biomeName = "Yellow"; biomes[3].hueShift = 50;  biomes[3].saturation = 1.1f; biomes[3].value = 1.1f;
            }

            void EnsureTemplates(){
                if (templates != null && templates.Length > 0) return;
                // Build default 10 templates from ASCII
                string[] ascii = DefaultAsciiRooms();
                RoomTemplate.Kind[] kinds = {
                    RoomTemplate.Kind.Corridor, RoomTemplate.Kind.Corridor, RoomTemplate.Kind.Compact, RoomTemplate.Kind.Compact,
                    RoomTemplate.Kind.Arena, RoomTemplate.Kind.Arena, RoomTemplate.Kind.Special, RoomTemplate.Kind.Special,
                    RoomTemplate.Kind.Corridor, RoomTemplate.Kind.Special
                };
                float[] weights = {1f,1f,1f,1f,1f,1f,0.8f,0.6f,0.9f,0.7f};
                templates = new RoomTemplate[ascii.Length];
                for(int i=0;i<ascii.Length;i++){
                    var t = ScriptableObject.CreateInstance<RoomTemplate>();
                    t.ascii = ascii[i]; t.kind = kinds[i]; t.weight = weights[i];
                    templates[i] = t;
                }
            }

            string[] DefaultAsciiRooms(){
                return new string[]{ @"
.................
.###############.
.#.............#.
.#.............#.
.#.............#.
.#.....DDDD....#.
.#.............#.
.#.............#.
.#.............#.
.###############.
.................
", @"
.................
.#########.......
.#.......#.......
.#.......#######.
.#.............#.
.#.....DDDD....#.
.#.............#.
.#######.......#.
.......#.......#.
.......#########.
.................
", @"
.................
.###############.
.#.............#.
.#...#######...#.
.#...#.....#...#.
.#...#DDDD.#...#.
.#...#.....#...#.
.#...#######...#.
.#.............#.
.###############.
.................
", @"
.................
.###############.
.#..#####......#.
.#..#...#......#.
.#..#...####..##.
.#..#DDDD..#..#..
.#..#......#..#..
.#..######.#..#..
.#........#..#..
.##############..
.................
", @"
.................
.###############.
.#.............#.
.#..#########..#.
.#..#.......#..#.
.#DD#.......#DD#.
.#..#.......#..#.
.#..#########..#.
.#.............#.
.###############.
.................
", @"
.................
.###############.
.#.....###.....#.
.#.....###.....#.
.#DDDD#####DDDD#.
.#.....###.....#.
.#.....###.....#.
.#.....###.....#.
.#.............#.
.###############.
.................
", @"
.................
.###############.
.#.....###.....#.
.#.....###.....#.
.#.....###.....#.
.#DDD..###..DDD#.
.#.....###.....#.
.#.....###.....#.
.#.....###.....#.
.###############.
.................
", @"
.................
.###############.
.#.............#.
.#...#######...#.
.#...#.....#...#.
.#...#..D..#...#.
.#...#.....#...#.
.#...#######...#.
.#.............#.
.###############.
.................
", @"
.................
.#######.........
.#.....#.........
.#.###.#.#######.
.#.#...#.#.....#.
.#.#.DDD.#.###.#.
.#.#.....#.#...#.
.#.#######.#.###.
.#.........#....
.###########.##.
................
", @"
.................
.###############.
.#.............#.
.#..#########..#.
.#..#..###..#..#.
.#DD#..###..#DD#.
.#..#..###..#..#.
.#..#########..#.
.#.............#.
.###############.
.................
" };
            }
        }
