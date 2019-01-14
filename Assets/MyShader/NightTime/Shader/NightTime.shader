Shader "Custom/NightTime"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _NightTime("Night time", Range(0.001, 1)) = 1
        _NightColor("NightColor",Color)=(1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
                #pragma fragment frag
                
            #include "UnityCG.cginc"
                
            struct appdata
            {
                float4 vertex : POSITION; 
                float2 uv : TEXCOORD0; 
            }; 
            
            struct v2f
            {
                float2 uv : TEXCOORD0; 
                float4 vertex : SV_POSITION; 
            }; 
            
            v2f vert(appdata v)
            {
                v2f o; 
                o.vertex = UnityObjectToClipPos(v.vertex); 
                o.uv = v.uv; 
                return o; 
            }
            
            sampler2D _MainTex; 
            float _NightTime; 
            fixed4 _NightColor;
            
//   目标：图片泛蓝、饱和度降低、场景变暗
            fixed4 frag(v2f i) : SV_Target
            {
                /* 获取初始图片rgb颜色 */ 
                    fixed4 col = tex2D(_MainTex, i.uv); 
                /* 获取图片灰度色  */ 
                    fixed lum = Luminance(col.rgb); 
                    fixed4 output; 
                /* 让图片颜色会灰度色之间做线性插值 */ 
                    output.rgb = lerp(col.rgb, fixed3(lum, lum, lum), _NightTime); 
                    output.a = col.a; 
                /* 给图片添加一些蓝色 ， 另外乘上（1-_NightTime）使图像更暗 */ 
                    return(output + _NightTime * _NightColor) * (1 - _NightTime); 
            }
            ENDCG
        }
    }
}