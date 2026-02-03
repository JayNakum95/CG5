using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.RenderGraphModule.Util;
using UnityEngine.Rendering.Universal;

public class DrawDepthRenderPass : ScriptableRenderPass
{
    // 深度抽出用マテリアル
    private Material depthTextureMaterial_;

    public DrawDepthRenderPass(Material depthTextureMaterial)
    {
        depthTextureMaterial_ = depthTextureMaterial;
    }

    public override void RecordRenderGraph(
        RenderGraph renderGraph,
        ContextContainer frameData
    )
    {
        // カメラ（描画予定）のテクスチャを取得
        UniversalResourceData resourceData =
            frameData.Get<UniversalResourceData>();
        TextureHandle cameraTexture =
            resourceData.activeColorTexture;

        // 深度テクスチャの設定
        TextureDesc depthTextureDesc =
            renderGraph.GetTextureDesc(cameraTexture);

        // 深度値用のテクスチャ
        depthTextureDesc.name = "_DepthTexture";

        // 深度値は使わない
        depthTextureDesc.depthBufferBits = 0;

        // 赤しか使っていないので情報量を最低限に
        depthTextureDesc.format =
            GraphicsFormat.R16_SFloat;

        // 赤しか使っていないので情報量を最低限に
        TextureHandle depthTexture =
            renderGraph.CreateTexture(depthTextureDesc);

        // 深度値を抽出する
        RenderGraphUtils.BlitMaterialParameters
            depthTextureBlitDesc =
                new RenderGraphUtils.BlitMaterialParameters(
                    cameraTexture,
                    depthTexture,
                    depthTextureMaterial_,
                    0
                );

        // その設定をURPに適用
        renderGraph.AddBlitPass(
            depthTextureBlitDesc,
            "DrawDepthBlit"
        );

        // cameraTextureに戻す
        renderGraph.AddCopyPass(
            depthTexture,
            cameraTexture,
            "CopyBlur"
        );
    }
}
