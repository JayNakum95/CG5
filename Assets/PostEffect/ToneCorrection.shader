Shader "PostEffect/ToneCorrection"
{
    Properties
    {
        _Saturation ("彩度", Range(0,1)) = 1
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

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            CBUFFER_START(UnityPerMaterial)
                half _Saturation;
            CBUFFER_END

            half4 Frag(Varyings input) : SV_Target
            {
                half4 output = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearRepeat, input.texcoord);

                half grayscale =
                    0.2126 * output.r +
                    0.7152 * output.g +
                    0.0722 * output.b;

                half4 monochromeColor = half4(grayscale, grayscale, grayscale, 1);

                // 彩度: 0=モノクロ, 1=元の色
                half4 outputColor = lerp(monochromeColor, output, _Saturation);

                return outputColor;
            }
            ENDHLSL
        }
    }
}
