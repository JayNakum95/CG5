Shader "Unlit/02_03RimLight"
{
    Properties
    {
        _BaseMap ("Base Texture", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1,1,1,1)

        // Rim-light controls
        _RimColor ("Rim Color", Color) = (0.35,0.55,1.0,1)
        _RimIntensity ("Rim Intensity", Range(0,3)) = 1.2
        _RimWidth ("Rim Width (threshold)", Range(0,1)) = 0.35
        _RimFeather ("Rim Feather (soft band)", Range(0,0.5)) = 0.04
        _RimPower ("Rim Tighten (pow)", Range(1,16)) = 6.0
        [Toggle] _HardEdge ("Use Hard Edge (step)", Float) = 1
        [Toggle] _BacksideOnly ("Backside Only (silhouette)", Float) = 0
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }

        Pass
        {
            Name "RimLight"
            Tags { "LightMode"="UniversalForward" }
            Cull Back ZWrite On

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float2 uv         : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv          : TEXCOORD0;
                float3 normalWS    : TEXCOORD1;
                float3 posWS       : TEXCOORD2;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            float4 _BaseMap_ST;
            float4 _BaseColor;

            float4 _RimColor;
            float _RimIntensity, _RimWidth, _RimFeather, _RimPower;
            float _HardEdge, _BacksideOnly;

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.posWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half3 N = normalize(IN.normalWS);
                half3 V = normalize(_WorldSpaceCameraPos - IN.posWS);
                half ndv = saturate(dot(N, V));

                // Base color 
                half4 baseCol = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv) * _BaseColor;

                // Rim factor: bright near silhouette, dark at center
                half rim = 1.0h - ndv;
                rim = pow(rim, _RimPower);

                // Optional backside-only gating
                if (_BacksideOnly >= 0.5h)
                {
                    half facing = step(0.0h, -dot(N, V));
                    rim *= facing;
                }

                // Edge hardness
                half rimMask;
                if (_HardEdge >= 0.5h)
                {
                    rimMask = step(_RimWidth, rim);
                }
                else
                {
                    rimMask = smoothstep(_RimWidth - _RimFeather, _RimWidth + _RimFeather, rim);
                }

                // Fade inner surface so rim stands out
                half baseFade = saturate(1.0h - rim * 2.0h);
                half3 rimCol = _RimColor.rgb * rimMask * _RimIntensity;

                half3 finalCol = baseCol.rgb * baseFade + rimCol;
                return half4(finalCol, baseCol.a);
            }
            ENDHLSL
        }
    }

    FallBack Off
}