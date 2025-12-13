Shader "Unlit/06_Sten"
{
    Properties
    {
        _FrontColor ("Color (Not Occluded)", Color) = (1,0,0,1)   // 普通に見えている時
        _HiddenColor("Color (Through Occluder)", Color) = (0,1,0,1) // 遮蔽物越しに見える部分
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Stencil
            {
                Ref 1
                Comp NotEqual   // ステンシルが1と違う所だけ
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            fixed4 _FrontColor;

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return _FrontColor;   // 例：赤
            }
            ENDCG
        }

        Pass
        {
            // キューブより後のタイミングで描画
            Tags { "Queue"="Geometry+1" }

            Stencil
            {
                Ref 1
                Comp Equal      // ステンシルが1の所だけ（=キューブの部分）
            }

            ZTest Always       // 奥でも必ず描画（隠されない）

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            fixed4 _HiddenColor;

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return _HiddenColor;  // 例：緑
            }
            ENDCG
        }
    }
}
