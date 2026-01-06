Shader "Unlit/normalMapwithSpecular"
{
    Properties
    {
        _MainTex    ("Albedo (Texture)", 2D) = "white" {}
        _BaseColor  ("Base Color", Color) = (1,1,1,1)
        _UseTexture ("Texture Blend", Range(0,1)) = 1

        _NormalTex  ("Normal Map", 2D) = "bump" {}

        _Metallic   ("Metallic", Range(0,1)) = 1
        _Smoothness ("Smoothness", Range(0,1)) = 0.8
        _SpecPower  ("Specular Power", Range(4,128)) = 32

        _EnvCube    ("Reflection Cubemap", CUBE) = "" {}
        _EnvIntensity ("Reflection Intensity", Range(0,1)) = 0.5
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }

        Pass
        {
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
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
                float3 worldPos : TEXCOORD1;

                // World-space TBN basis
                float3 t : TEXCOORD2;
                float3 b : TEXCOORD3;
                float3 n : TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _NormalTex;

            fixed4 _BaseColor;
            float  _UseTexture;

            float  _Metallic;
            float  _Smoothness;
            float  _SpecPower;

            samplerCUBE _EnvCube;
            float  _EnvIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv  = TRANSFORM_TEX(v.uv, _MainTex);

                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                // Correct world normal & tangent
                float3 n = UnityObjectToWorldNormal(v.normal);
                float3 t = UnityObjectToWorldDir(v.tangent.xyz);

                n = normalize(n);
                t = normalize(t);

                float tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                float3 b = normalize(cross(n, t) * tangentSign);

                o.n = n;
                o.t = t;
                o.b = b;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 texCol  = tex2D(_MainTex, i.uv).rgb;
                fixed3 baseCol = _BaseColor.rgb;

                fixed3 albedo = lerp(baseCol, texCol, _UseTexture);

                float3 nTS = UnpackNormal(tex2D(_NormalTex, i.uv));
                float3 nWS = normalize(i.t * nTS.x + i.b * nTS.y + i.n * nTS.z);

                float3 lightDir = (_WorldSpaceLightPos0.w == 0)
                    ? normalize(_WorldSpaceLightPos0.xyz)
                    : normalize(_WorldSpaceLightPos0.xyz - i.worldPos);

                float NdotL = saturate(dot(nWS, lightDir));

                // Diffuse reduced by metallic
                fixed3 diffuse = albedo * (1.0 - _Metallic) * _LightColor0.rgb * NdotL;

                // View + half vector
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 halfDir = normalize(lightDir + viewDir);
                float  NdotH   = saturate(dot(nWS, halfDir));

                // Spec color: metallic pulls spec toward albedo
                fixed3 specColor = lerp(fixed3(0.04,0.04,0.04), albedo, _Metallic);

                // Smoothness -> shininess mapping
                float shininess = lerp(4.0, _SpecPower, _Smoothness);
                fixed3 spec = specColor * pow(NdotH, shininess) * _LightColor0.rgb;

                // Cubemap reflection (simple)
                float3 reflDir = reflect(-viewDir, nWS);
                fixed3 env = texCUBE(_EnvCube, reflDir).rgb;
                fixed3 envTerm = env * _EnvIntensity * _Metallic;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;

                fixed3 finalCol = ambient + diffuse + spec + envTerm;
                return fixed4(finalCol, 1);
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}


