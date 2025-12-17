Shader "Unlit/SkinShadderwith normal"
{
    Properties
    {
        _MainTex    ("Albedo (Texture)", 2D) = "white" {}
        _BaseColor  ("Base Color", Color) = (1,1,1,1)
        _UseTexture ("Texture Blend", Range(0,1)) = 1

        _NormalTex  ("Normal Map", 2D) = "bump" {}
        _NormalIntensity ("Normal Intensity", Range(0,2)) = 1

        // For skin: keep Metallic at 0 in the material
        _Metallic   ("Metallic (keep 0 for skin)", Range(0,1)) = 0

        // Roughness is easier to think for skin
        _Roughness  ("Roughness", Range(0,1)) = 0.6

        // Spec color tint (skin spec is slightly colored, not pure white)
        _SpecTint   ("Spec Tint", Color) = (1, 0.92, 0.85, 1)
        _SpecPower  ("Spec Power Max", Range(4,128)) = 64

        _EnvCube    ("Reflection Cubemap", CUBE) = "" {}
        _EnvIntensity ("Reflection Intensity", Range(0,1)) = 0.2
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

                float3 t : TEXCOORD2;
                float3 b : TEXCOORD3;
                float3 n : TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _NormalTex;

            fixed4 _BaseColor;
            float  _UseTexture;

            float  _NormalIntensity;

            float  _Metallic;
            float  _Roughness;

            fixed4 _SpecTint;
            float  _SpecPower;

            samplerCUBE _EnvCube;
            float  _EnvIntensity;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv  = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                float3 n = normalize(UnityObjectToWorldNormal(v.normal));
                float3 t = normalize(UnityObjectToWorldDir(v.tangent.xyz));

                float tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                float3 b = normalize(cross(n, t) * tangentSign);

                o.n = n; o.t = t; o.b = b;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 texCol  = tex2D(_MainTex, i.uv).rgb;
                fixed3 baseCol = _BaseColor.rgb;
                fixed3 albedo  = lerp(baseCol, texCol, _UseTexture);

                // --- Normal (Unity-correct) ---
                float3 nTS = UnpackNormal(tex2D(_NormalTex, i.uv));

                // Normal intensity: scale XY and re-normalize
                nTS.xy *= _NormalIntensity;
                nTS = normalize(nTS);

                float3 nWS = normalize(i.t * nTS.x + i.b * nTS.y + i.n * nTS.z);

                // --- Lighting vectors ---
                float3 lightDir = (_WorldSpaceLightPos0.w == 0)
                    ? normalize(_WorldSpaceLightPos0.xyz)
                    : normalize(_WorldSpaceLightPos0.xyz - i.worldPos);

                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

                float NdotL = saturate(dot(nWS, lightDir));

                // Diffuse (skin is not metallic)
                fixed3 diffuse = albedo * (1.0 - _Metallic) * _LightColor0.rgb * NdotL;

                // --- Specular (roughness -> wider highlight) ---
                float3 halfDir = normalize(lightDir + viewDir);
                float  NdotH   = saturate(dot(nWS, halfDir));

                // Convert roughness -> smoothness -> shininess feel
                float smoothness = 1.0 - _Roughness;

                // Use smoother highlight at low roughness, wider at high roughness
                float shininess = lerp(4.0, _SpecPower, smoothness);

                // Spec base: for dielectrics ~0.04, tint for skin
                fixed3 specColor = lerp(fixed3(0.04,0.04,0.04), _SpecTint.rgb, 0.75);

                fixed3 spec = specColor * pow(NdotH, shininess) * _LightColor0.rgb;

                // --- Simple reflection (keep low for skin) ---
                float3 reflDir = reflect(-viewDir, nWS);
                fixed3 env = texCUBE(_EnvCube, reflDir).rgb;
                fixed3 envTerm = env * _EnvIntensity * smoothness * (1.0 - _Roughness);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;

                fixed3 finalCol = ambient + diffuse + spec + envTerm;
                return fixed4(finalCol, 1);
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}

