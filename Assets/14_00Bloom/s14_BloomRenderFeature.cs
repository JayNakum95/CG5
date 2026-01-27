using UnityEngine;
using UnityEngine.Rendering.Universal;

public class s14_BloomRenderFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class Settings
    {
        public Material luminanceExtractMaterial;
        public Material blurMaterial;
        public Material compositeTextureMaterial;

        // どのタイミングで描くか（基本はAfterRendering）
        public RenderPassEvent passEvent = RenderPassEvent.AfterRendering;
    }

    public Settings settings = new Settings();

    s14_BloomRenderPass pass_;

    public override void Create()
    {
        pass_ = new s14_BloomRenderPass(
            settings.luminanceExtractMaterial,
            settings.blurMaterial,
            settings.compositeTextureMaterial
        );

        pass_.renderPassEvent = settings.passEvent;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        // Materialが未設定なら何もしない
        if (settings.luminanceExtractMaterial == null ||
            settings.blurMaterial == null ||
            settings.compositeTextureMaterial == null)
        {
            return;
        }

        renderer.EnqueuePass(pass_);
    }
}
