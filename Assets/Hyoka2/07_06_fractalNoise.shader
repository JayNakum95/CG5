Shader "Unlit/07_06_fractalNoise"
{
    Properties
    {
        _BaseDensity ("Base Density", Float) = 10.0
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

            float _BaseDensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv  = v.uv;
                return o;
            }

            float2 randomVec(float2 fact)
            {
                float2 angle = float2(
                    dot(fact, float2(127.1, 311.7)),
                    dot(fact, float2(269.5, 183.3))
                );
                return frac(sin(angle) * 43758.5453123) * 2.0 - 1.0;
            }

            float PerlinNoise(float density, float2 uv)
            {
                float2 uvScaled = uv * density;

                float2 uvFloor = floor(uvScaled);  // cell index
                float2 uvFrac  = frac(uvScaled);   // position in cell

                // gradients at corners
                float2 v00 = randomVec(uvFloor + float2(0,0));
                float2 v01 = randomVec(uvFloor + float2(0,1));
                float2 v10 = randomVec(uvFloor + float2(1,0));
                float2 v11 = randomVec(uvFloor + float2(1,1));

                // distance vectors to corners
                float c00 = dot(v00, uvFrac - float2(0,0));
                float c01 = dot(v01, uvFrac - float2(0,1));
                float c10 = dot(v10, uvFrac - float2(1,0));
                float c11 = dot(v11, uvFrac - float2(1,1));

                // fade curve
                float2 u = uvFrac * uvFrac * (3.0 - 2.0 * uvFrac);

                // interpolate
                float v0010 = lerp(c00, c10, u.x);
                float v0111 = lerp(c01, c11, u.x);
                float perlin = lerp(v0010, v0111, u.y);

                // [-1,1] -> [0,1]
                return perlin * 0.5 + 0.5;
            }

            float FractalSumNoise(float density, float2 uv)
            {
                float fn = 0.0;

                fn  = PerlinNoise(density * 1.0, uv) * (1.0 /  2.0);
                fn += PerlinNoise(density * 2.0, uv) * (1.0 /  4.0);
                fn += PerlinNoise(density * 4.0, uv) * (1.0 /  8.0);
                fn += PerlinNoise(density * 8.0, uv) * (1.0 / 16.0);

                return fn; 
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float pn = FractalSumNoise(_BaseDensity, i.uv);
                return fixed4(pn, pn, pn, 1);  // grayscale ÅgsmokeÅh noise
            }
            ENDCG
        }
    }
}

