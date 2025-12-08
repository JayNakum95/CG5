Shader "Unlit/07_02_MosaicNoise"
{
    Properties
    {
        _Blocks ("Blocks Per Axis", Float) = 10.0   
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

            float _Blocks;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv  = v.uv;     // normal 0–1 uv
                return o;
            }

            float random(float2 p)
            {
                return frac( sin( dot(p, float2(12.9898, 78.233)) ) * 43758.5453 );
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float density = _Blocks;   
                float2 mosaicUV = floor(i.uv * density) / density;

                // random brightness per block
                float r = random(mosaicUV);

                return fixed4(r, r, r, 1);   // grayscale block noise
            }
            ENDCG
        }
    }
}

