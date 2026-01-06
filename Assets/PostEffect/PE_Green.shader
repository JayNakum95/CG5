Shader "PostEffect/Green"
{
    SubShader
    {
        // URP用であると記述
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            // ポストエフェクトでは不要な機能を切る
            ZWrite Off
            ZTest Always
            Blend Off
            Cull Off

            HLSLPROGRAM
            #pragma vertex   Vert
            #pragma fragment Frag
            #pragma editor_sync_compilation

            // URP用のシェーダの機能群
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            // ポストエフェクト用の機能群（Vert / Varyings / _BlitTexture など）
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            // vert は Blit.hlsl に書いてあるので不要
            // Frag（ピクセルシェーダ）のみ記述する

            half4 Frag(Varyings input) : SV_Target
            {
                // テクスチャの読み込み
                half4 output = SAMPLE_TEXTURE2D(
                    _BlitTexture, sampler_LinearRepeat,
                    input.texcoord
                );

                // 赤成分と青成分を無くす（緑だけ残す）
                output.r = 0;
                output.b = 0;

                return output;
            }
            ENDHLSL
        }
    }
}
