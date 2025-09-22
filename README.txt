README — Unity Ranarama-like (4 biomes + cluster/portal + palette swap)
--------------------------------------------------------------------------------
Unity version: 2021.3+ (URP or Built-in). Requires: 2D Tilemap package.

Install
1) Unzip into your project under Assets/  (final path: Assets/RanaramaLike/...)
2) Create a Room prefab and a Portal prefab as described below, or reuse yours.
3) Open/Make a Scene and add an empty GameObject 'Dungeon' with DungeonGen.
4) In DungeonGen inspector, assign:
   - roomPrefab (your Room prefab)
   - templates (10 RoomTemplate assets) — OR leave empty to auto-load ASCII at runtime
   - biomes (4 Biome assets) — OR leave empty to auto-create demo biomes at runtime
   - portalPrefab (your Portal prefab)
5) Press Play. Click Play again to regenerate, or toggle the component.

Minimal prefab setup
• Room prefab hierarchy:
  Room (Room.cs)
    Grid (Grid)
      Floor (Tilemap + TilemapRenderer)
      Walls (Tilemap + TilemapRenderer + TilemapCollider2D + CompositeCollider2D + Rigidbody2D[Static])
  In the Room component, drag Floor and Walls Tilemaps.

• Portal prefab:
  Portal (Portal.cs) + CircleCollider2D [isTrigger], optional SpriteRenderer.
  Set the Player tag on your player to use the trigger teleport.

Tiles
Assign any TileBase to Biome.floorTile and Biome.wallTile. If left null, the
generator still runs but rooms won't render tiles (you can add them later).

ScriptableObject assets
You can create Biome and RoomTemplate assets from the Create menu. If you leave
the arrays empty in DungeonGen, it will auto-build in-memory demo biomes and
templates from the ASCII included in code (no need to create assets immediately).

ASCII room templates
Legend: '.' floor, '#' wall, ' ' (space) empty, 'D' door marker (treated as floor).

