using UnityEngine;
using UnityEngine.Rendering.Universal;

// URPにPostEffectRenderPassを渡すためのクラス
public class PostEffectRenderFeature : ScriptableRendererFeature
{
    // ポストエフェクト計算用のマテリアル
    [SerializeField]
    private Material postEffectMaterial_;

    // URPに渡すRenderPass
    private PostEffectRenderPass renderPass_;

    // このクラスがURPによって生成されたときに呼ばれる関数
    public override void Create()
    {
        renderPass_ = new PostEffectRenderPass(postEffectMaterial_);

        // レンダリング完了後、他ポストエフェクトが適用される前
        renderPass_.renderPassEvent =
            RenderPassEvent.BeforeRenderingPostProcessing;
    }

    // パスを追加する関数
    public override void AddRenderPasses(
        ScriptableRenderer rendererPass,
        ref RenderingData renderingData)
    {
        if (rendererPass != null)
        {
            rendererPass.EnqueuePass(renderPass_);
        }
    }
}
