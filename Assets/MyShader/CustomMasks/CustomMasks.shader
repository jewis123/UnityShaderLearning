Shader "Custom/DiscMask"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Radius("Radius", float) = 1.0
        _CenterX("CenterX", float) = 0.5
        _CenterY("CenterY", float) = 0.5
        _SizeX("SizeX", float) = 1
        _SizeY("SizeY", float) = 1
        _Hardness("Harndess", float) = 1.0
        _Invert("Invert", Range(-1.0, 1.0)) = 0
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always
 
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
 
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
             
            sampler2D _MainTex;
            float _Radius;
            float _Hardness;
            float _CenterX;
            float _CenterY;
            float _SizeX;
            float _SizeY;
            float _Invert;
 
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 orCol = tex2D(_MainTex, i.uv);
                float dist = length(float2(i.uv.x - _CenterX, i.uv.y - _CenterY) * float2(_SizeX,_SizeY));  //获取每个像素距离“中心”的距离再分别乘以X，Y的系数获得控制圆的横纵比例
                float circle = saturate(dist/_Radius);  //saturate将结果控制再【0，1】之间，限制距离比半径大的情况，circle可以直接替换CircleAlpha。dist/Radius的作用是为了后面获得平滑的过速效果
                //如果不关心平滑问题可以直接这样写： circle = dist<_Radius?0:1;
                float circleAlpha = pow(circle, pow(_Hardness, 2));//控制圆的“刚性”，即中心到边缘是否有色度过渡，_Hardness控制
                float a = (_Invert > 0) ? circleAlpha * _Invert : (1 - circleAlpha) * (-_Invert);//控制圆中心到边缘的a变化，_invert控制
                half4 col = (orCol.rgb, a * orCol.a);//将算出来的a通道加入输出，这里应用A通道的原因，获取黑白值
                return col;
            }
            ENDCG
        }
    }
}