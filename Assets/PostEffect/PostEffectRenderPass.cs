using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.RenderGraphModule.Util;
using UnityEngine.Rendering.Universal;

public class PostEffectRenderPass : ScriptableRenderPass
{
    // ポストエフェクト用マテリアル
    private Material blurMaterial_ = null;
    // Blit用のパススルーマテリアル
    private Material passThroughMaterial_ = null;

    public PostEffectRenderPass(
        Material blurMaterial,
        Material passThroughMaterial)
    {
        blurMaterial_ = blurMaterial;
        passThroughMaterial_ = passThroughMaterial;
    }

    public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
    {
        // どちらかのマテリアルがnullであれば
        if (blurMaterial_ == null || passThroughMaterial_ == null)
        {
            base.RecordRenderGraph(renderGraph, frameData);
            return;
        }

        // このフレームの描画リソースを取得する
        UniversalResourceData resourceData = frameData.Get<UniversalResourceData>();

        // 取得したResourceDataがBackBufferであれば仕様上読み込み不可能なので早期リターン
        if (resourceData.isActiveTargetBackBuffer)
        {
            base.RecordRenderGraph(renderGraph, frameData);
            return;
        }

        // カメラ（描画予定）のテクスチャを取得
        TextureHandle cameraTexture = resourceData.activeColorTexture;

        // ポストエフェクトを適用したテクスチャを作るためにカメラの情報を取得する
        TextureDesc tempDesc = renderGraph.GetTextureDesc(cameraTexture);

        // 元サイズの一時テクスチャ
        tempDesc.name = "_OrigTempTexture";
        tempDesc.depthBufferBits = 0;
        TextureHandle origTempTexture = renderGraph.CreateTexture(tempDesc);

        // 縮小サイズの一時テクスチャ
        tempDesc.name = "_SmallTempTexture";
        int div = 2;
        tempDesc.width /= div;
        tempDesc.height /= div;
        TextureHandle smallTempTexture = renderGraph.CreateTexture(tempDesc);

        // cameraTexture -> smallTempTexture（縮小しながらブラー適用）
        RenderGraphUtils.BlitMaterialParameters downSampleBlitMaterialParameters =
            new RenderGraphUtils.BlitMaterialParameters(
                cameraTexture,
                smallTempTexture,
                blurMaterial_,
                0
            );
        renderGraph.AddBlitPass(
            downSampleBlitMaterialParameters,
            "DownSamplingBlitBlur"
        );

        // smallTempTexture -> origTempTexture（パススルーで元サイズへ）
        RenderGraphUtils.BlitMaterialParameters upSampleBlitMaterialParameters =
            new RenderGraphUtils.BlitMaterialParameters(
                smallTempTexture,
                origTempTexture,
                passThroughMaterial_,
                0
            );
        renderGraph.AddBlitPass(
            upSampleBlitMaterialParameters,
            "UpSamplingBlitBlur"
        );

        // origTempTexture -> cameraTexture（カメラへ戻す）
        renderGraph.AddCopyPass(
            origTempTexture,
            cameraTexture,
            "CopyBlur"
        );
    }
}
