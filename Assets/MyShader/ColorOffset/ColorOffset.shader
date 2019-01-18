Shader "Custom/ColorOffset"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Offset("Offset Factor",Float)  = 0
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

            sampler2D _MainTex;
            fixed4 _MainTex_ST;                  //pass语句顺序执行，所以_MainTex_ST一定要在TRANSFORM_TEX用到之前申明
            float _Offset;

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
                o.uv = TRANSFORM_TEX(v.uv,_MainTex);
                return o;
            }

            

            fixed4 frag (v2f i) : SV_Target
            {
                //失败一：偏移一样就没有色差了  = =。
                // float r = tex2D(_MainTex,float2(i.uv.x-_Offset,i.uv.y-_Offset)).r;
                // float g = tex2D(_MainTex,float2(i.uv.x-_Offset,i.uv.y-_Offset)).g;
                // float b = tex2D(_MainTex,float2(i.uv.x-_Offset,i.uv.y-_Offset)).b;

                float r = tex2D(_MainTex,float2(i.uv.x-_Offset,i.uv.y-_Offset)).r;
                float g = tex2D(_MainTex,i.uv).g;
                float b = tex2D(_MainTex,float2(i.uv.x+_Offset,i.uv.y+_Offset)).b;
                return fixed4(r,g,b,1);
            }
            ENDCG
        }
    }
}
