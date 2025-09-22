
using UnityEngine;
public static class RNG {
    public static System.Random r = new System.Random();
    public static void Seed(int s){ r = new System.Random(s);} 
    public static int Range(int a,int b)=> r.Next(a,b); 
    public static float Value()=> (float)r.NextDouble(); 
}
