Shader "Unlit/01_Simple"
{
     Properties{
        _Color("Color", Color) = (1,0.25,0,1)    
        // _AlphaValue ("AlphaValue", Float) = 0.8
        // _WaveScale("WaveScale", Range(0.02,0.15)) = 0.07
        // _ReflDistort("Reflection Distort", Range(0,1.5)) = 0.5
        // _RefColor("Reflection Color", Color) = (0.34,0.85,0.92,1)
        // _ReflectionTex("Environment Reflection",2D)=""{}
        
        }
    SubShader
    {
       
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag        
            #include "UnityCG.cginc"
            fixed4 _Color;
           float4 vert(float4 v : POSITION) : SV_POSITION{
               float4 o;
               o = UnityObjectToClipPos(v);
               return o;           
           }

            
            fixed4 frag (float4 i:SV_POSITION ) : SV_Target
            {
                fixed4 o = _Color;
                return o;
            }
            ENDCG
        }
    }
}
