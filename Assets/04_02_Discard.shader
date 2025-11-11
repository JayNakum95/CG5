

Shader "Unlit/04_02_Discard"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color   ("Tint", Color) = (1,1,1,1)
        _Cutoff  ("Cutoff (discard if <=)", Range(0,1)) = 0.5

        [KeywordEnum(Alpha, Red, Green, Blue, Luminance)]
        _MaskChannel ("Mask Channel", Float) = 0
    }

    SubShader
    {
        Tags { "Queue"="AlphaTest" "RenderType"="TransparentCutout" }
        LOD 100

        Cull Back
        ZWrite On
        Blend Off
        AlphaToMask On    

        Pass
        {
            CGPROGRAM
            #pragma vertex   vert
            #pragma fragment frag
            #pragma target 3.0

            #pragma shader_feature _MASKCHANNEL_ALPHA _MASKCHANNEL_RED _MASKCHANNEL_GREEN _MASKCHANNEL_BLUE _MASKCHANNEL_LUMINANCE

            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv     : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv  : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4    _MainTex_ST;
            fixed4    _Color;
            float     _Cutoff;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv  = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;

                fixed mask;
                #if   defined(_MASKCHANNEL_RED)
                    mask = col.r;
                #elif defined(_MASKCHANNEL_GREEN)
                    mask = col.g;
                #elif defined(_MASKCHANNEL_BLUE)
                    mask = col.b;
                #elif defined(_MASKCHANNEL_LUMINANCE)
                    mask = dot(col.rgb, fixed3(0.299, 0.587, 0.114));
                #else
                    mask = col.a;
                #endif

                if (mask <= _Cutoff) discard;

                return col;
            }
            ENDCG
        }

        UsePass "Legacy Shaders/Transparent/Cutout/VertexLit/SHADOWCASTER"
    }

    Fallback Off
}
