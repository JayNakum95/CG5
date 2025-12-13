Shader "Unlit/07_04_ValueNoise"
{
    Properties
    {
        _Density ("Blocks Per Axis", Float) = 10.0
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

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv  = v.uv;
                return o;
            }

            float random(float2 fact)
            {
                return frac( sin( dot(fact, float2(12.9898, 78.233)) ) * 43758.5453 );
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float density = _Density;

                float2 cell = floor(i.uv * density);

                float v00 = random((cell + float2(0,0)) / density);
                float v01 = random((cell + float2(0,1)) / density);
                float v10 = random((cell + float2(1,0)) / density);
                float v11 = random((cell + float2(1,1)) / density);

                float2 p = frac(i.uv * density);

                float2 v = p * p * (3.0 - 2.0 * p);

                float v0010 = lerp(v00, v10, v.x);
                float v0111 = lerp(v01, v11, v.x);

                float valueNoise = lerp(v0010, v0111, v.y);

                return fixed4(valueNoise, valueNoise, valueNoise, 1);
            }
            ENDCG
        }
    }
}
