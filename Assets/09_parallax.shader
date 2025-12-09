Shader "Unlit/09_parallax"
{
    Properties
    {
        _MainTex        ("Albedo", 2D) = "white" {}
        _HeightTex      ("Height", 2D) = "black" {}

        _ParallaxShallow("Shallow Parallax Scale", Range(0, 0.5)) = 0.05
        _ParallaxDeep   ("Deep   Parallax Scale", Range(0, 0.5)) = 0.1
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 100


        Pass
        {
            CGPROGRAM
            #pragma vertex   vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _HeightTex;
            float4 _MainTex_ST;
            float4 _HeightTex_ST;

            float _ParallaxShallow;
            float _ParallaxDeep;

            struct appdata
            {
                float4 vertex  : POSITION;
                float2 uv      : TEXCOORD0;
                float3 normal  : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos       : SV_POSITION;
                float2 uv        : TEXCOORD0;
                float2 heightUV  : TEXCOORD1;
                float3 viewDirTS : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);

                o.uv       = TRANSFORM_TEX(v.uv, _MainTex);
                o.heightUV = TRANSFORM_TEX(v.uv, _HeightTex);

                float3 worldPos  = mul(unity_ObjectToWorld, v.vertex).xyz;
                float3 viewDirWS = _WorldSpaceCameraPos.xyz - worldPos;

                float3 t = normalize(mul((float3x3)unity_ObjectToWorld, v.tangent.xyz));
                float3 n = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
                float3 b = cross(n, t) * v.tangent.w;

                float3x3 TBN = float3x3(t, b, n);

                o.viewDirTS = mul(TBN, viewDirWS);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 viewDirTS = normalize(-i.viewDirTS);

                float height = tex2D(_HeightTex, i.heightUV).r;

                float2 shallowOffset = viewDirTS.xy * _ParallaxShallow;
                float2 deepOffset    = viewDirTS.xy * _ParallaxDeep;

                float2 offset = lerp(shallowOffset, deepOffset, height);

                float2 uv = i.uv + offset;

                return tex2D(_MainTex, uv);
            }
            ENDCG
        }
    }
}

