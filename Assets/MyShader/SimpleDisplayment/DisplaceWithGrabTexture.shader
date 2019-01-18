Shader "Custom/DisplaceWithGrabTexture"
{
    Properties
    {
        _DisplacementMask("Displacement mask", 2D) = "white"
        _DisplacementAmount("Displacement amount", float) = 0
    }
    SubShader
    {
        Tags {"Queue" = "Transparent"}
        // No culling or depth
        Cull Off ZWrite Off ZTest Always
        
        GrabPass {"_GrabTexture"} //注意声明位置,用抓取图像作为主纹理
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
                #pragma fragment frag
                
            #include "UnityCG.cginc"
                
            sampler2D _GrabTexture; //注意
            sampler2D _DisplacementMask;
            float _DisplacementAmount;
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            
            struct v2f
            {
                float4 uv : TEXCOORD0; //注意使用tex2Dproj返回值是float4
                float4 vertex : SV_POSITION;
            };
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = ComputeGrabScreenPos(o.vertex); //计算uv对应的屏幕映射
                return o;
            }
            
            
            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 disp = tex2D(_DisplacementMask,i.uv);
                fixed4 disUV = i.uv + disp*_DisplacementAmount;
                fixed4 col = tex2Dproj(_GrabTexture, disUV); 
                return col;
            }
            ENDCG
        }
    }
}
