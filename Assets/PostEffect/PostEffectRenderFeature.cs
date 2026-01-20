// PostEffectRenderFeature.cs
using UnityEngine;
using UnityEngine.Rendering.Universal;

// URPにPostEffectRenderPassを渡すためのクラス
public class PostEffectRenderFeature : ScriptableRendererFeature
{
    // ポストエフェクト用マテリアル
    [SerializeField] private Material blurMaterial_;
    // Blit用マテリアル
    [SerializeField] private Material passThroughMaterial_;

    // URPに渡すRenderPass
    private PostEffectRenderPass renderPass_;

    // このクラスがURPによって生成されたときに呼ばれる関数
    public override void Create()
    {
        renderPass_ = new PostEffectRenderPass(
            blurMaterial_,
            passThroughMaterial_
        );

        // レンダリング完了後、他ポストエフェクトが適用される前
        renderPass_.renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
    }

    // パスを追加する関数
    public override void AddRenderPasses(
        ScriptableRenderer renderer,
        ref RenderingData renderingData)
    {
        if (renderer != null)
        {
            renderer.EnqueuePass(renderPass_);
        }
    }
}
