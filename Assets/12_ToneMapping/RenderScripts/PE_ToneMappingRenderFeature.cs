using UnityEngine;
using UnityEngine.Rendering.Universal;

public class ToneMappingRenderFeature : ScriptableRendererFeature
{
    [SerializeField]
    private Material postEffectMaterial_;

    private ToneMappingRenderPass renderPass_;

    public override void Create()
    {
        renderPass_ = new ToneMappingRenderPass(postEffectMaterial_);
        renderPass_.renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
    }

    public override void AddRenderPasses(ScriptableRenderer rendererPass, ref RenderingData renderingData)
    {
        // ‚±‚ê‚ª–³‚¢‚Æu‰½‚à‹N‚«‚È‚¢vŒ´ˆö‚É‚È‚è‚â‚·‚¢
        if (postEffectMaterial_ == null) return;
        if (renderPass_ == null) return;

        rendererPass.EnqueuePass(renderPass_);
    }
}
