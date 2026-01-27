Shader "Custom/14_01LuminanceExtract"
{
    Properties
    {
        _ThresholdMin("ThresholdMin", Range(0, 2)) = 1.0
        _ThresholdMax("ThresholdMax", Range(0, 2)) = 1.5
    }

    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            ZWrite Off
            ZTest Always
            Blend Off
            Cull Off

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            #pragma editor_sync_compilation

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float _ThresholdMin;
                float _ThresholdMax;
            CBUFFER_END

            half4 Frag(Varyings IN) : SV_Target
            {
                half4 color = SAMPLE_TEXTURE2D(
                    _BlitTexture, sampler_LinearRepeat,
                    IN.texcoord
                );

                half luminance =
                    color.r * 0.2126 +
                    color.g * 0.7152 +
                    color.b * 0.0722;

                luminance = smoothstep(
                    _ThresholdMin,
                    _ThresholdMax,
                    luminance
                );

                half4 output = color * luminance;
                output.a = 1;
                return output;
            }
            ENDHLSL
        }
    }
}
