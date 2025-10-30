Shader "Unlit/04_Phong"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MainTex_ST ("Tiling (X,Y) and Offset (Z,W)", Vector) = (1,1,0,0)
        _Color ("Base Color", Color) = (1,1,1,1)
        _AmbientStrength ("Ambient Strength", Range(0,1)) = 0.3
        _SpecularPower ("Specular Power", Range(1,128)) = 32
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST; 
            fixed4 _Color;
            float _AmbientStrength;
            float _SpecularPower;
            fixed4 _LightColor0;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
                float3 normal : TEXCOORD2;
                float2 uv : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.normal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));

                o.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 N = normalize(i.normal);
                float3 L = normalize(_WorldSpaceLightPos0.xyz);
                float3 V = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
                float3 R = reflect(-L, N);

                fixed4 ambient = _Color * _AmbientStrength;

                float diff = saturate(dot(N, L));
                fixed4 diffuse = _Color * diff;

                float spec = pow(saturate(dot(R, V)), _SpecularPower);
                fixed4 specular = spec;

                fixed4 texColor = tex2D(_MainTex, i.uv);

                fixed4 phong = texColor * (ambient + diffuse) + specular;
                return phong;
            }
            ENDCG
        }
    }
}
