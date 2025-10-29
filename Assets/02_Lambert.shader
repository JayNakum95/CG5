Shader "Unlit/02_Lambert"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
              float4 vertex : POSITION;
              float3 normal : NORMAL;
            };

           

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
               float intensity=saturate(dot(normalize(i.normal), _WorldSpaceLightPos0));
               fixed4 color=fixed4(intensity, intensity, intensity, 1.0);
               fixed4 diffuse= color*intensity*_LightColor0;
               return diffuse;
            }
            ENDCG
        }
    }
}
