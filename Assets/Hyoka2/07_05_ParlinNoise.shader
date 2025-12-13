Shader "Unlit/07_05_PerlinNoise"
{
    Properties
    {
        _Density ("Noise Density", Float) = 10.0
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

                float2 uvFloor = floor(uvScaled);   // cell index
                float2 uvFrac  = frac(uvScaled);    // position in cell 0–1

                // random gradient at 4 corners
                float2 v00 = randomVec(uvFloor + float2(0,0));
                float2 v01 = randomVec(uvFloor + float2(0,1));
                float2 v10 = randomVec(uvFloor + float2(1,0));
                float2 v11 = randomVec(uvFloor + float2(1,1));

                // distance vectors from pixel to each corner
                float c00 = dot(v00, uvFrac - float2(0,0));
                float c01 = dot(v01, uvFrac - float2(0,1));
                float c10 = dot(v10, uvFrac - float2(1,0));
                float c11 = dot(v11, uvFrac - float2(1,1));

                // fade curve
                float2 u = uvFrac * uvFrac * (3.0 - 2.0 * uvFrac);

                // bilinear interpolation of corner contributions
                float v0010 = lerp(c00, c10, u.x);
                float v0111 = lerp(c01, c11, u.x);
                float perlin = lerp(v0010, v0111, u.y);

                // map from [-1,1] → [0,1]
                return perlin * 0.5 + 0.5;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float density = _Density;                      // like slide’s density
                float pn = PerlinNoise(density, i.uv);         // 0–1

                return fixed4(pn, pn, pn, 1);                  // grayscale Perlin noise
            }
            ENDCG
        }
    }
}
