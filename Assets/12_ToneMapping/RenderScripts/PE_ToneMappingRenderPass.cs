using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.RenderGraphModule.Util;
using UnityEngine.Rendering.Universal;

public class ToneMappingRenderPass : ScriptableRenderPass
{
    private Material material_ = null;

    public ToneMappingRenderPass(Material postEffectMaterial)
    {
        material_ = postEffectMaterial;
    }

    public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
    {
        if (material_ == null)
        {
            base.RecordRenderGraph(renderGraph, frameData);
            return;
        }

        UniversalResourceData resourceData = frameData.Get<UniversalResourceData>();

        // BackBufferは読めない
        if (resourceData.isActiveTargetBackBuffer)
        {
            base.RecordRenderGraph(renderGraph, frameData);
            return;
        }

        TextureHandle cameraTexture = resourceData.activeColorTexture;
        if (!cameraTexture.IsValid()) return;

        // カメラ情報を元に仮テクスチャを作る
        TextureDesc tempDesc = renderGraph.GetTextureDesc(cameraTexture);
        tempDesc.name = "_ToneMapping";
        tempDesc.depthBufferBits = 0;

        TextureHandle tempTexture = renderGraph.CreateTexture(tempDesc);

        // Blit
        var blitParams = new RenderGraphUtils.BlitMaterialParameters(
            cameraTexture, tempTexture, material_, 0);

        renderGraph.AddBlitPass(blitParams, "BlitToneMapping");
        renderGraph.AddCopyPass(tempTexture, cameraTexture, "CopyToneMapping");
    }
}

