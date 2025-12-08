Shader "Unlit/08_NormalMap"
{
    Properties
    {
        _MainTex   ("Albedo", 2D)        = "white" {}
        _NormalTex ("Normal Map", 2D)    = "bump"  {}
        _Tint      ("Tint", Color)       = (1,1,1,1)
        _SpecCol   ("Spec Color", Color) = (1,1,1,1)
        _Gloss     ("Shininess", Range(1,64)) = 16
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma vertex   vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex  : POSITION;
                float3 normal  : NORMAL;
                float4 tangent : TANGENT;
                float2 uv      : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos      : SV_POSITION;
                float2 uv       : TEXCOORD0;
                float3 tangent  : TEXCOORD1;
                float3 binormal : TEXCOORD2;
                float3 normal   : TEXCOORD3;
                float3 worldPos : TEXCOORD4;
            };

            sampler2D _MainTex;
            float4    _MainTex_ST;
            sampler2D _NormalTex;

            fixed4 _Tint;
            fixed4 _SpecCol;
            float  _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv  = TRANSFORM_TEX(v.uv, _MainTex);

                // Build TBN basis in world space
                float3 n = normalize(UnityObjectToWorldNormal(v.normal));
                float3 t = normalize(UnityObjectToWorldDir(v.tangent.xyz));
                float3 b = normalize(cross(n, t) * v.tangent.w);

                o.normal   = n;
                o.tangent  = t;
                o.binormal = b;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Albedo
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;

                // Normal map (tangent space → world space)
                float3 nTS = tex2D(_NormalTex, i.uv).xyz * 2.0 - 1.0;
                nTS = normalize(nTS);

                float3 nWS = normalize(
                    i.tangent  * nTS.x +
                    i.binormal * nTS.y +
                    i.normal   * nTS.z
                );

                float3 lightDir;
                if (_WorldSpaceLightPos0.w == 0) {
                    // directional light: vector already a direction
                    lightDir = normalize(_WorldSpaceLightPos0.xyz);
                } else {
                    // point / spot light: position - fragment position
                    lightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
                }

                float  NdotL = saturate(dot(nWS, lightDir));

                fixed3 diffuse = albedo * _LightColor0.rgb * NdotL;

                // Specular
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 halfDir = normalize(lightDir + viewDir);
                float  NdotH   = saturate(dot(nWS, halfDir));
                fixed3 spec    = _SpecCol.rgb * pow(NdotH, _Gloss) * _LightColor0.rgb;

                // Ambient
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;

                return fixed4(ambient + diffuse + spec, 1.0);
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}
