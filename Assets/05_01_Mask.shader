Shader "Unlit/05_01_Mask"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _MaskTex ("Mask Texture (R > 0.5 visible)", 2D) = "black" {}
    }

    SubShader
    {
        Tags
        {
            "Queue"="AlphaTest"
            "RenderType"="TransparentCutout"
        }
        LOD 150

        Cull Back
        ZWrite On
        Blend Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv     : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uvMain : TEXCOORD0;
                float2 uvMask : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4    _MainTex_ST;
            sampler2D _MaskTex;
            float4    _MaskTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uvMain = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvMask = TRANSFORM_TEX(v.uv, _MaskTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col  = tex2D(_MainTex, i.uvMain);
                fixed4 mask = tex2D(_MaskTex, i.uvMask);

                // R > 0.5 ‚Ì•”•ª‚¾‚¯Žc‚·
                clip(0.5 - mask.r);

                return col;
            }
            ENDCG
        }
    }
}

