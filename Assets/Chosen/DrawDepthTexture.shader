Shader "Custom/_DrawDepthTexture"
{
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" }
        Pass
        {
            Name "DrawDepthTexture"
            ZWrite Off
            ZTest Always
            Cull Off

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            half4 Frag(Varyings IN) : SV_Target
            {
                // シーン深度を取得（0..1 に正規化）
                float rawDepth = SampleSceneDepth(IN.texcoord);
                float depth01 = Linear01Depth(rawDepth, _ZBufferParams);

                // 深度を赤に出す（R16_SFloatで十分）
                return half4(depth01, 0, 0, 1);
            }
            ENDHLSL
        }
    }
}
