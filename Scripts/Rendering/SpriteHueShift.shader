
Shader "Ranarama/SpriteHueShift" {
    Properties { _MainTex ("Sprite", 2D) = "white" {} _HueShift ("Hue Shift (-180..180)", Range(-180,180)) = 0 _Saturation ("Saturation", Range(0,2)) = 1 _Value ("Value", Range(0,2)) = 1 }
    SubShader { Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "CanUseSpriteAtlas"="True" }
        Cull Off Lighting Off ZWrite Off Blend SrcAlpha OneMinusSrcAlpha
        Pass { CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            sampler2D _MainTex; float4 _MainTex_ST; float _HueShift; float _Saturation; float _Value;
            struct appdata { float4 vertex:POSITION; float2 uv:TEXCOORD0; float4 color:COLOR; };
            struct v2f { float4 pos:SV_POSITION; float2 uv:TEXCOORD0; float4 color:COLOR; };
            v2f vert (appdata v){ v2f o; o.pos = UnityObjectToClipPos(v.vertex); o.uv = TRANSFORM_TEX(v.uv,_MainTex); o.color=v.color; return o; }
            float3 rgb2hsv(float3 c){ float4 K = float4(0., -1./3., 2./3., -1.); float4 p = c.g < c.b ? float4(c.bg, K.wz) : float4(c.gb, K.xy); float4 q = c.r < p.x ? float4(p.xyw, c.r) : float4(c.r, p.yzx); float d = q.x - min(q.w, q.y); float e = 1e-10; return float3(abs(q.z + (q.w - q.y) / (6.*d + e)), d/(q.x+e), q.x); }
            float3 hsv2rgb(float3 c){ float4 K = float4(1., 2./3., 1./3., 3.); float3 p = abs(frac(c.xxx + K.xyz) * 6. - K.www); return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y); }
            fixed4 frag (v2f i):SV_Target { fixed4 col = tex2D(_MainTex, i.uv)*i.color; float3 hsv = rgb2hsv(col.rgb); hsv.x = frac(hsv.x + (_HueShift/360.0)); hsv.y *= _Saturation; hsv.z *= _Value; col.rgb = hsv2rgb(hsv); return col; }
        ENDCG }
    }
}
