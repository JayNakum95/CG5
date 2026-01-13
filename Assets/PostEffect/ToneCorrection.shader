Shader "PostEffect/ToneCorrection"
{
    Properties
    {
        saturation ("彩度", Range(0,1)) = 1
        contrast   ("コントラスト", Range(0,2)) = 1
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" }

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

            // Properties → HLSL に渡す（URPで重要）
            CBUFFER_START(UnityPerMaterial)
                half saturation;
                half contrast;
            CBUFFER_END

            half4 Frag(Varyings input) : SV_Target
            {
                half4 output =
                    SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearRepeat, input.texcoord);

                // grayscale
                half grayscale =
                    0.2126 * output.r +
                    0.7152 * output.g +
                    0.0722 * output.b;

                half4 monochromeColor = half4(grayscale, grayscale, grayscale, 1);

                // 彩度
                half4 outputColor = lerp(monochromeColor, output, saturation);

                // コントラスト（※RGBだけ）
                outputColor.rgb = (outputColor.rgb - 0.5) * contrast + 0.5;

                return outputColor;
            }
            ENDHLSL
        }
    }
}
