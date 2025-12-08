Shader "Unlit/07_01_RandomNoise"
{
    Properties
    {
        _Density ("Noise Density", Float) = 50.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
                float2 uv  : TEXCOORD0;
            };

            float _Density;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv * _Density;
                return o;
            }

          
            float random(float2 fact)
            {
                return frac(sin(dot(fact, float2(12.9898, 78.233))) * 43758.5453);
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float r = random(i.uv);  

                return fixed4(r, r, r, 1);  
            }
            ENDCG
        }
    }
}
