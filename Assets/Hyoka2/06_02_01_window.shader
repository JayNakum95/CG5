Shader "Unlit/06_02_01_window"
{
    Properties
    {
        _Color ("Tint Color", Color) = (1,1,1,0.2)
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Geometry" }

        Pass
        {
            Stencil
            {
                Ref 1
                Comp Always
                Pass Replace
            }

            ZWrite On
            Blend SrcAlpha OneMinusSrcAlpha   

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

