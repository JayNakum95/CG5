Shader "Unlit/05_02_Blend"
{
    Properties
    {
        _MainTex ("Main Texture (Grass)", 2D) = "white" {}
        _SubTex  ("Sub Texture (Dirt)", 2D)  = "white" {}
        _MaskTex ("Mask Texture (R = Dirt)", 2D) = "black" {}
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 150

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv     : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uvMain : TEXCOORD0;
                float2 uvSub  : TEXCOORD1;
                float2 uvMask : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4    _MainTex_ST;
            sampler2D _SubTex;
            float4    _SubTex_ST;
            sampler2D _MaskTex;
            float4    _MaskTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uvMain = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvSub  = TRANSFORM_TEX(v.uv, _SubTex);
                o.uvMask = TRANSFORM_TEX(v.uv, _MaskTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 main = tex2D(_MainTex, i.uvMain); // 芝
                fixed4 sub  = tex2D(_SubTex,  i.uvSub);  // 荒地
                fixed4 mask = tex2D(_MaskTex, i.uvMask); // 赤い帯のマスク

                // 赤が強い部分 → sub（荒地）
                fixed4 col = mask.r * sub + (1 - mask.r) * main;
                // // あるいは： lerp(main, sub, mask.r);

                return col;
            }
            ENDCG
        }
    }
}
