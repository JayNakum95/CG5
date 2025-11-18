Shader "Unlit/06_Occludar"
{
    Properties
    {
        _Color ("Color", Color) = (1,0,0,1)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            // ステンシルに 1 を書き込む
            Stencil
            {
                Ref 1        // 書き込む値
                Comp always  // 常に
                Pass replace // 1を書き込む
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            fixed4 _Color;

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
                return _Color;
            }
            ENDCG
        }
    }
}
