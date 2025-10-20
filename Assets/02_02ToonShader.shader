Shader "Unlit/02_02ToonShader"
{
    Properties
    {
        _BaseMap ("Base Texture", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1,1,1,1)

        // Diffuse control
        _Threshold ("Shadow Threshold", Range(0,1)) = 0.5
        _Feather ("Edge Feather (0 = hard)", Range(0,0.1)) = 0.03
        _ShadowTint ("Shadow Tint (0=black,1=no darken)", Range(0,1)) = 0.6

        // Specular
        _SpecColor ("Specular Color", Color) = (1,1,1,1)
        _SpecPower ("Specular Sharpness", Range(2,128)) = 40
        _SpecThreshold ("Specular Threshold", Range(0,1)) = 0.5
        _SpecIntensity ("Specular Intensity", Range(0,2)) = 0.6

        // Outline
        _OutlineColor ("Outline Color", Color) = (0,0,0,1)
        _OutlineWidth ("Outline Width", Range(0,0.05)) = 0.02
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }

        // --------- Toon Lighting ---------
        Pass
        {
            Name "ToonForward"
            Tags { "LightMode"="UniversalForward" }
            Cull Back ZWrite On ZTest LEqual

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _SHADOWS_SOFT

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

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

            float _Threshold;
            float _Feather;
            float _ShadowTint;

            float4 _SpecColor;
            float  _SpecPower;
            float  _SpecThreshold;
            float  _SpecIntensity;

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.posWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                return OUT;
            }

            half4 frag (Varyings IN) : SV_Target
            {
                half3 N = normalize(IN.normalWS);
                half3 V = normalize(_WorldSpaceCameraPos - IN.posWS);

                Light mainLight = GetMainLight();
                half3 L = normalize(mainLight.direction);

                half ndl = saturate(dot(N, L));

                // Ambient
                half3 ambient = SampleSH(N);

                // Toon diffuse band
                half edge = (_Feather > 0.0001)
                    ? smoothstep(_Threshold - _Feather, _Threshold + _Feather, ndl)
                    : step(_Threshold, ndl);
                half diffuseTerm = lerp(_ShadowTint, 1.0, edge);

                // Toon specular band
                half3 H = normalize(L + V);
                half ndh = saturate(dot(N, H));
                half phong = pow(ndh, _SpecPower);
                half specStep = step(_SpecThreshold, phong);
                half3 specular = _SpecColor.rgb * specStep * _SpecIntensity;

                half4 baseCol = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv) * _BaseColor;

                half3 litColor = ambient + diffuseTerm;
                half3 finalRGB = baseCol.rgb * litColor + specular;

                return half4(finalRGB, baseCol.a);
            }
            ENDHLSL
        }

        // --------- Outline Pass ---------
        Pass
        {
            Name "Outline"
            Tags { "LightMode"="SRPDefaultUnlit" }
            Cull Front ZWrite On ZTest LEqual

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float4 color : COLOR;
            };

            float4 _OutlineColor;
            float  _OutlineWidth;

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                float3 posWS = TransformObjectToWorld(IN.positionOS.xyz);
                float3 normWS = TransformObjectToWorldNormal(IN.normalOS);
                posWS += normWS * _OutlineWidth;
                OUT.positionHCS = TransformWorldToHClip(posWS);
                OUT.color = _OutlineColor;
                return OUT;
            }

            half4 frag (Varyings IN) : SV_Target
            {
                return IN.color;
            }
            ENDHLSL
        }
    }


    FallBack Off
}
