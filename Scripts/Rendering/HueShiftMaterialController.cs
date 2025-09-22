
using UnityEngine;

[ExecuteAlways]
public class HueShiftMaterialController : MonoBehaviour {
    public Biome biome; public SpriteRenderer[] renderers;
    void Update(){
        if (!biome || renderers==null) return;
        foreach(var r in renderers){
            if(!r || !r.sharedMaterial) continue;
            r.sharedMaterial.SetFloat("_HueShift", biome.hueShift);
            r.sharedMaterial.SetFloat("_Saturation", biome.saturation);
            r.sharedMaterial.SetFloat("_Value", biome.value);
        }
    }
}
