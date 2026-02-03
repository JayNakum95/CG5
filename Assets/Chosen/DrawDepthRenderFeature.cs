using UnityEngine;
using UnityEngine.Rendering.Universal;

public class DrawDepthRenderFeature : ScriptableRendererFeature
{
    [SerializeField] private Material depthTextureMaterial_;

    private DrawDepthRenderPass renderPass_;

    public override void Create()
    {
        renderPass_ = new DrawDepthRenderPass(depthTextureMaterial_);
        renderPass_.renderPassEvent =
            RenderPassEvent.AfterRenderingPostProcessing;
    }

    // パスを追加する関数
    public override void AddRenderPasses(
        ScriptableRenderer rendererPass,
        ref RenderingData renderingData
    )
    {
        // シーンビューカメラの場合はRenderPassを追加しない
        if (renderingData.cameraData.isSceneViewCamera)
        {
            return;
        }

        if (rendererPass != null)
        {
            rendererPass.EnqueuePass(renderPass_);
        }
    }
}
