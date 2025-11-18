Shader "Unlit/06_02_01_window"
{
    Properties
    {
        _Color ("Debug Color (optional)", Color) = (1,1,1,0.1)
    }

    SubShader
    {
        // draw with normal geometry timing
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }

        Pass
        {
            // Write 1 into stencil wherever the cube is
            Stencil
            {
                Ref 1          // value to write
                Comp Always    // always pass
                Pass Replace   // write Ref into stencil
            }

            // write depth, but not color (cube itself invisible)
            ZWrite On
            ColorMask 0

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            fixed4 _Color; // not really used (ColorMask 0)

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
                return _Color; // wonÅft be drawn because ColorMask 0
            }
            ENDCG
        }
    }
}

