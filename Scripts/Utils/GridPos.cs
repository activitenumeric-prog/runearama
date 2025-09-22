
using UnityEngine;
[System.Serializable]
public struct GridPos { public int x,y; public GridPos(int x,int y){this.x=x;this.y=y;} public static implicit operator Vector2Int(GridPos p)=>new(p.x,p.y); }
