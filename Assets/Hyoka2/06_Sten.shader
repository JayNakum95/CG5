Shader "Unlit/06_Sten"
{
    Properties
    {
        _FrontColor ("Color (Not Occluded)", Color) = (1,0,0,1)   
        _HiddenColor("Color (Through Occluder)", Color) = (0,1,0,1) 
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Stencil
            {
                Ref 1
                Comp NotEqual  
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            fixed4 _FrontColor;

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
                return _FrontColor;  
            }
            ENDCG
        }

        Pass
        {
            Tags { "Queue"="Geometry+1" }

            Stencil
            {
                Ref 1
            }

            ZTest Always       

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            fixed4 _HiddenColor;

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
                return _HiddenColor;  
            }
            ENDCG
        }
    }
}
