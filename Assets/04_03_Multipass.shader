Shader "Unlit/04_03_Multipass"
{
    Properties
    {
        _MaskTex  ("Dissolve Mask (R)", 2D) = "white" {}
        _Dissolve ("Dissolve (t)", Range(0,1)) = 0.5
    }

    SubShader
    {
        Tags
        {
            "Queue"="AlphaTest"
            "RenderType"="TransparentCutout"
        }

        // ---------- shared program for both passes ----------
        CGINCLUDE
        #include "UnityCG.cginc"

        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv     : TEXCOORD0;
        };

        struct v2f
        {
            float4 vertex : SV_POSITION;
            float2 uv     : TEXCOORD0;
        };

        sampler2D _MaskTex;
        float4    _MaskTex_ST;
        float     _Dissolve;

        v2f vert (appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv     = TRANSFORM_TEX(v.uv, _MaskTex);
            return o;
        }

        // Back-face color (cyan)
        fixed4 fragBack (v2f i) : SV_Target
        {
            fixed4 mask = tex2D(_MaskTex, i.uv);
            clip(mask.r - _Dissolve);        // dissolve
            return fixed4(0, 1, 1, 1);       // cyan
        }

        // Front-face color (use mask texture = red stripes)
        fixed4 fragFront (v2f i) : SV_Target
        {
            fixed4 mask = tex2D(_MaskTex, i.uv);
            clip(mask.r - _Dissolve);        // dissolve
            return mask;                     // red textured result
        }
        ENDCG
        // ---------- end shared program ----------

        // 1st pass: draw back faces (cyan)
        Pass
        {
            Cull Front                  // draw back faces
            CGPROGRAM
            #pragma vertex   vert
            #pragma fragment fragBack
            ENDCG
        }

        // 2nd pass: draw front faces (red)
        Pass
        {
            Cull Back                   // draw front faces
            CGPROGRAM
            #pragma vertex   vert
            #pragma fragment fragFront
            ENDCG
        }
    }

    Fallback Off
}
