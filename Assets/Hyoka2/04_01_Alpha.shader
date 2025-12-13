

Shader "Unlit/04_01_Alpha"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}  
        _Color ("Tint Color", Color) = (1, 1, 1, 1)  
        _Alpha ("Alpha", Range(0,1)) = 1       
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Cull Back

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;     
            fixed4 _Color;
            float _Alpha;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 texColor = tex2D(_MainTex, i.uv);
                fixed3 rgb = texColor.rgb * _Color.rgb;
                fixed alpha = texColor.a * _Color.a * _Alpha;
                return fixed4(rgb, alpha);
            }
            ENDCG
        }
    }
}
