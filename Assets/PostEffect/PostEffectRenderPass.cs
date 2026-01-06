using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.RenderGraphModule.Util;
using UnityEngine.Rendering.Universal;

public class PostEffectRenderPass : ScriptableRenderPass
{
    private Material material_ = null;

    public PostEffectRenderPass(Material postEffectMaterial)
    {
        material_ = postEffectMaterial;
    }

    // 
    public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
    {
        if (material_ == null)
        {
            base.RecordRenderGraph(renderGraph, frameData);
            return;
        }

        UniversalResourceData resourceData = frameData.Get<UniversalResourceData>();


        if (resourceData.isActiveTargetBackBuffer)
        {
            return;
        }

        TextureHandle cameraTexture = resourceData.activeColorTexture;

        TextureDesc tempDesc = renderGraph.GetTextureDesc(cameraTexture);

        tempDesc.name = "_GreenTexture";
        // 深度値は使わない
        tempDesc.depthBufferBits = 0;

        // 仮テクスチャを作成
        TextureHandle tempTexture = renderGraph.CreateTexture(tempDesc);

        // cameraTextureにmaterial_を適用し仮テクスチャに出力する設定を作成
        RenderGraphUtils.BlitMaterialParameters blitMaterialParameters =
            new RenderGraphUtils.BlitMaterialParameters(cameraTexture, tempTexture, material_, 0);

        // その設定をURPに適用
        renderGraph.AddBlitPass(blitMaterialParameters, "BlitGreenPostPostEffect");

        // URPがポストエフェクトをした元のカメラテクスチャにコピーする
        renderGraph.AddCopyPass(tempTexture, cameraTexture,"CopyGreenPostEffect");
    }
}
