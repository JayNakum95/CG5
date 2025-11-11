Shader "Unlit/04_02_Discard"
{
    Properties
    {
        _BaseMap ("Texture", 2D) = "white" {}
        _BaseColor ("Tint (RGBA)", Color) = (1,1,1,1)
        _Cutoff ("Cutoff (discard if <=)", Range(0,1)) = 0.5

        [KeywordEnum(Alpha, Red, Green, Blue, Luminance)]
        _MaskChannel ("Mask Channel", Float) = 0
    }
    SubShader
    {
        Tags{
            "Queue"="AlphaTest"
            "RenderType"="TransparentCutout"
            "RenderPipeline"="UniversalPipeline"
            "IgnoreProjector"="True"
        }


        LOD 100
        Cull Back
        ZWrite On
        AlphaToMask On
        Blend Off

        Pass
        {
            Name "ForwardUnlit"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex   vert
            #pragma fragment frag
            #pragma target 3.0

            #pragma shader_feature _MASKCHANNEL_ALPHA _MASKCHANNEL_RED _MASKCHANNEL_GREEN _MASKCHANNEL_BLUE _MASKCHANNEL_LUMINANCE

            // URP includes
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                float4 _BaseColor;
                float  _Cutoff;
            CBUFFER_END

            struct Attributes {
                float3 positionOS : POSITION;
                float2 uv         : TEXCOORD0;
            };
            struct Varyings {
                float4 positionHCS : SV_POSITION;
                float2 uv          : TEXCOORD0;
            };

            Varyings vert (Attributes v)
            {
                Varyings o;
                o.positionHCS = TransformObjectToHClip(v.positionOS);
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
                return o;
            }

            half4 frag (Varyings i) : SV_Target
            {
                half4 tex = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
                half4 col = tex * _BaseColor;

                half mask;
                #if   defined(_MASKCHANNEL_RED)
                    mask = col.r;
                #elif defined(_MASKCHANNEL_GREEN)
                    mask = col.g;
                #elif defined(_MASKCHANNEL_BLUE)
                    mask = col.b;
                #elif defined(_MASKCHANNEL_LUMINANCE)
                    mask = dot(col.rgb, half3(0.299h, 0.587h, 0.114h));
                #else
                    mask = col.a; 
                #endif

                clip(mask - _Cutoff);
                return col;
            }
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags{ "LightMode"="ShadowCaster" }

            Cull Back
            ZWrite On
            ZTest LEqual

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #pragma shader_feature _MASKCHANNEL_ALPHA _MASKCHANNEL_RED _MASKCHANNEL_GREEN _MASKCHANNEL_BLUE _MASKCHANNEL_LUMINANCE

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"


            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                float4 _BaseColor;
                float  _Cutoff;
            CBUFFER_END

            struct Attributes {
                float3 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float2 uv         : TEXCOORD0;
            };
            struct Varyings {
                float4 positionHCS : SV_POSITION;
                float2 uv          : TEXCOORD0;
            };

            Varyings vert (Attributes v)
            {
                Varyings o;
                float3 posWS = TransformObjectToWorld(v.positionOS);
                float3 normalWS = TransformObjectToWorldNormal(v.normalOS);
                o.positionHCS = TransformWorldToHClip(ApplyShadowBias(posWS, normalWS, 0.0));
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
                return o;
            }

            half4 frag (Varyings i) : SV_Target
            {
                half4 tex = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
                half4 col = tex * _BaseColor;

                half mask;
                #if   defined(_MASKCHANNEL_RED)
                    mask = col.r;
                #elif defined(_MASKCHANNEL_GREEN)
                    mask = col.g;
                #elif defined(_MASKCHANNEL_BLUE)
                    mask = col.b;
                #elif defined(_MASKCHANNEL_LUMINANCE)
                    mask = dot(col.rgb, half3(0.299h, 0.587h, 0.114h));
                #else
                    mask = col.a;
                #endif

                clip(mask - _Cutoff);
                return 0;
            }
            ENDHLSL
        }
    }
    Fallback Off
}
