/* 
说明：
    这个shader实现的效果是将材质所附物体覆盖的画面显示出来
    ComputeGrabScreenPos来获取物体在屏幕中的位置
    tex2Dproj对屏幕该位置的图像进行采样
    如此一来，效果是：像一块玻璃，在玻璃范围内可以增加shader来处理该区域效果
 */
Shader "Custom/GrabTexture"
{
    Properties
    {
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" }
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        GrabPass{"_GrabTexture"}            //注意声明位置,用抓取图像作为主纹理

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _GrabTexture;         //注意


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;      //注意使用tex2Dproj返回值是float4
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = ComputeGrabScreenPos(o.vertex);  //计算uv对应的屏幕映射
                return o;
            }


            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2Dproj(_GrabTexture, i.uv);  //tex2Dproj一般使用计算到的屏幕映射坐标
                // just invert the colors
                col.rgb = 1 - col.rgb;
                return col;
            }
            ENDCG
        }
    }
}
