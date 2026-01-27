Shader "Custom/14_01TextureComposite"
{
    Properties
    {
        // 合成用テクスチャ
        _OtherTexture("OtherTexture", 2D) = "black" {}
    }

    SubShader
    {
        // URP 用
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            HLSLPROGRAM

            // ===== pragma =====
            #pragma vertex Vert
            #pragma fragment Frag
            #pragma editor_sync_compilation

            // ===== include =====
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            // ===== 合成用テクスチャの定義 =====
            TEXTURE2D(_OtherTexture);
            SAMPLER(sampler_OtherTexture);

            // ===== フラグメント =====
            half4 Frag(Varyings IN) : SV_Target
            {
                // 一つ目のテクスチャをサンプリング（_BlitTexture）
                half4 blitColor =
                    SAMPLE_TEXTURE2D(
                        _BlitTexture,
                        sampler_LinearClamp,
                        IN.texcoord
                    );

                // 二つ目のテクスチャをサンプリング（_OtherTexture）
                half4 otherColor =
                    SAMPLE_TEXTURE2D(
                        _OtherTexture,
                        sampler_LinearClamp,
                        IN.texcoord
                    );

                // 二つの色を合成
                half4 output =
                    saturate(blitColor + otherColor);

                return output;
            }

            ENDHLSL
        }
    }
}
