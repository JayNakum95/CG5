using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.RenderGraphModule.Util;
using UnityEngine.Rendering.Universal;

public class s14_BloomRenderPass : ScriptableRenderPass
{
    // ブラー用マテリアル
    private Material blurMaterial_ = null;
    // 輝度抽出用マテリアル
    private Material luminanceExtractMaterial_ = null;
    // テクスチャ合成用マテリアル
    private Material compositeTextureMaterial_ = null;

    // シェーダ内で定義されている変数の取得
    static readonly int luminanceBlurTextureId =
        Shader.PropertyToID("_OtherTexture");

    // 自作Blitに必要なデータ
    class CompositePassData
    {
        // _BlitTextureに渡されるテクスチャ
        public TextureHandle sourceTexture;
        // 合成用のテクスチャ
        public TextureHandle otherTexture;
        // 出力先
        public TextureHandle destination;
        // 適用するマテリアル
        public Material material;
    }

    // 各マテリアルをRenderFeatureから受け取る
    public s14_BloomRenderPass(
        Material luminanceExtractMaterial,
        Material blurMaterial,
        Material compositeTextureMaterial
    )
    {
        // コンストラクタ引数からマテリアルを取得
        blurMaterial_ = blurMaterial;
        compositeTextureMaterial_ = compositeTextureMaterial;
        luminanceExtractMaterial_ = luminanceExtractMaterial;
    }

    // RenderGraphへの描画設定や描画実行など一連の操作
    public override void RecordRenderGraph(
        RenderGraph renderGraph,
        ContextContainer frameData
    )
    {
        // nullチェックも欠かさずに
        // どれかのマテリアルがnullであれば
        if (blurMaterial_ == null ||
            compositeTextureMaterial_ == null ||
            luminanceExtractMaterial_ == null)
        {
            // 従来通りの描画を行なう
            base.RecordRenderGraph(renderGraph, frameData);
            return;
        }

        // このフレームの描画リソースを取得する。
        UniversalResourceData resourceData =
            frameData.Get<UniversalResourceData>();

        // 取得したResourceDataがBackBufferであれば
        // 仕様上読み込み不可なので早期リターン。
        if (resourceData.isActiveTargetBackBuffer)
        {
            base.RecordRenderGraph(renderGraph, frameData);
            return;
        }

        // カメラ（描画予定）のテクスチャを取得
        TextureHandle cameraTexture =
            resourceData.activeColorTexture;

        // ポストエフェクトを適用したテクスチャを作るために
        // カメラの情報を取得する
        TextureDesc originalTextureDesc =
            renderGraph.GetTextureDesc(cameraTexture);

        // 元サイズの一時テクスチャ。
        originalTextureDesc.name = "_OriginalTexture";
        // 深度値は使わない
        originalTextureDesc.depthBufferBits = 0;

        TextureHandle origTempTexture =
            renderGraph.CreateTexture(originalTextureDesc);

        // 縮小サイズの一時テクスチャ
        // 輝度抽出とそのブラーの計算に使用する
        TextureDesc luminanceTextureDesc =
            originalTextureDesc;
        luminanceTextureDesc.name = "_SmallTempTexture";

        // 縮小を行なう
        int div = 4;
        luminanceTextureDesc.width /= div;
        luminanceTextureDesc.height /= div;

        // 明るさ情報から作成するマスクなので、0-1の範囲に丸める
        luminanceTextureDesc.format =
            UnityEngine.Experimental.Rendering.GraphicsFormat.R8G8B8A8_UNorm;

        // 輝度抽出テクスチャ
        TextureHandle luminanceTexture =
            renderGraph.CreateTexture(luminanceTextureDesc);

        // 抽出した輝度にブラーを掛けるテクスチャ
        TextureHandle luminanceBlurTexture =
            renderGraph.CreateTexture(luminanceTextureDesc);

        // 輝度を抽出する
        RenderGraphUtils.BlitMaterialParameters
            luminanceExtractBlitMaterialParameters =
                new RenderGraphUtils.BlitMaterialParameters(
                    cameraTexture,
                    luminanceTexture,
                    luminanceExtractMaterial_,
                    0
                );

        // その設定をURPに適用
        renderGraph.AddBlitPass(
            luminanceExtractBlitMaterialParameters,
            "LuminanceExtractBlit"
        );

        // 輝度にブラーをかける
        RenderGraphUtils.BlitMaterialParameters
            brightnessBlitMaterialParameters =
                new RenderGraphUtils.BlitMaterialParameters(
                    luminanceTexture,
                    luminanceBlurTexture,
                    blurMaterial_,
                    0
                );

        // その設定をURPに適用
        renderGraph.AddBlitPass(
            brightnessBlitMaterialParameters,
            "BrightnessBlit"
        );

        
        using (IRasterRenderGraphBuilder builder =
            renderGraph.AddRasterRenderPass(
                "BloomComposite",
                out CompositePassData passData
            ))
        {
            // 必要なデータを集める
            passData.sourceTexture = cameraTexture;
            passData.otherTexture = luminanceBlurTexture;
            passData.destination = origTempTexture;
            passData.material = compositeTextureMaterial_;

            // 何を読む/書くかを宣言
            builder.UseTexture(passData.sourceTexture, AccessFlags.Read);
            builder.UseTexture(passData.otherTexture, AccessFlags.Read);
            builder.SetRenderAttachment(passData.destination, 0, AccessFlags.Write);

            // 描画関数の登録
            builder.SetRenderFunc(
                (
                    CompositePassData data,
                    RasterGraphContext ctx
                ) =>
                {
                    // 合成用のテクスチャを「_OtherTexture」に渡す。
                    data.material.SetTexture(
                        luminanceBlurTextureId,
                        data.otherTexture
                    );

                    Blitter.BlitTexture(
                        ctx.cmd,
                        data.sourceTexture,
                        new Vector4(1, 1, 0, 0),
                        data.material,
                        0
                    );
                }
            );
        }

        // cameraTextureに戻す
        renderGraph.AddCopyPass(
            origTempTexture,
            cameraTexture,
            "CopyBloom"
        );
    }
}
