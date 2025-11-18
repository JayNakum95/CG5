Shader "Unlit/06_02_02_Object"
{
    Properties
    {
        _MainTex   ("Base Texture", 2D) = "white" {}
        _Color     ("Base Color", Color) = (1,1,1,1)

        _MaskTex   ("Specular Mask (R)", 2D) = "black" {}
        _Shininess ("Shininess", Range(4,128)) = 32
    }

    SubShader
    {
        // draw after the window so stencil is already written
        Tags { "RenderType"="Opaque" "Queue"="Geometry+1" }
        LOD 200

        Pass
        {
            // ★★ ここがポイント ★★
            // Window が書き込んだ Stencil==1 の所だけ描画
            Stencil
            {
                Ref 1
                Comp Equal
            }

            // Cube に隠されても見えるように
            ZTest Always
            ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv     : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos        : SV_POSITION;
                float2 uvMain     : TEXCOORD0;
                float2 uvMask     : TEXCOORD1;
                float3 worldPos   : TEXCOORD2;
                float3 worldNormal: TEXCOORD3;
            };

            sampler2D _MainTex;
            float4    _MainTex_ST;
            sampler2D _MaskTex;
            float4    _MaskTex_ST;

            fixed4 _Color;
            float  _Shininess;   // _SpecColor は Lighting.cginc 側を利用

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.uvMain = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvMask = TRANSFORM_TEX(v.uv, _MaskTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // base color
                fixed3 albedo = tex2D(_MainTex, i.uvMain).rgb * _Color.rgb;

                // lighting vectors
                fixed3 N = normalize(i.worldNormal);
                fixed3 L = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 V = normalize(_WorldSpaceCameraPos - i.worldPos);
                fixed3 H = normalize(L + V);

                // diffuse
                fixed NdotL = max(0, dot(N, L));
                fixed3 diffuse = albedo * _LightColor0.rgb * NdotL;

                // specular mask from mask texture (R channel)
                fixed specMask = tex2D(_MaskTex, i.uvMask).r;

                // Blinn-Phong specular (uses global _SpecColor)
                fixed NdotH = max(0, dot(N, H));
                fixed3 specular = _SpecColor.rgb * pow(NdotH, _Shininess) * specMask * _LightColor0.rgb;

                // ambient
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;

                fixed3 col = ambient + diffuse + specular;
                return fixed4(col, 1.0);
            }
            ENDCG
        }
    }
}


