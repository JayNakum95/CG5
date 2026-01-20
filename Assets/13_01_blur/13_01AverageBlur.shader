Shader "Custom/13_01AverageBlur"
{
    Properties
    {
        // カーネルのピクセルごとの幅
        _StepWidth("ブラー密度", Range(0, 0.1)) = 0.01
        // カーネルの1辺の要素数
        _StepNums("ブラー強度", Range(0, 5)) = 3
    }

    SubShader
    {
        // URPの使用を宣言
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            // ポストエフェクトでは不要な機能を切る
            ZWrite Off
            ZTest Always
            Blend Off
            Cull Off

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            #pragma editor_sync_compilation

            // URPコアファイル
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            // ポストエフェクトに必要なファイル
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            // Propertiesで操作する変数はCBUFFERを使う
            CBUFFER_START(UnityPerMaterial)
                float _StepWidth;
                float _StepNums;
            CBUFFER_END

            half4 Frag(Varyings IN) : SV_Target
            {
                // 出力する色の初期値は0
                half4 output = half4(0, 0, 0, 0);

                // ループ回数カウンタ
                float loopCount = 0;

                // ステップ数の整数化
                _StepNums = floor(_StepNums);

                // 回り込み防止用にテクセルサイズの半分を取得
                float2 margin = _BlitTexture_TexelSize.xy / 2;

                // 2重for文で描画ピクセルの周りを走査する
                for (float y = -_StepNums / 2; y <= _StepNums / 2; y += 1.0)
                {
                    for (float x = -_StepNums / 2; x <= _StepNums / 2; x += 1.0)
                    {
                        // サンプリング座標
                        float2 pickUV = IN.texcoord + float2(x, y) * _StepWidth;

                        // 回り込み防止
                        pickUV = clamp(pickUV, margin, 1 - margin);

                        // サンプリング座標から色をサンプリングし、outputに加算
                        output += SAMPLE_TEXTURE2D(
                            _BlitTexture, sampler_LinearClamp,
                            pickUV
                        );

                        // カウンタに加算
                        loopCount += 1.0;
                    }
                }

                // すべての加算が終わったらループ回数で割る
                output /= loopCount;

                // アルファ値は1で固定
                output.a = 1;

                return output;
            }
            ENDHLSL
        }
    }
}
