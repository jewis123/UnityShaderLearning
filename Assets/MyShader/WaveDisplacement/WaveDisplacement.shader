Shader "Custom/WaveDisplacement" {
    Properties {
        _MainTex("MainTEX", 2D) = "white"
        _DisMap("DisTex", 2D) = "white"
        _Offset("Offset", Float) = 0
    }
    SubShader {
        Tags {"Queue" = "Transparent"}
        pass {
            CGPROGRAM
            #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"
                
            sampler2D _MainTex;
            sampler2D _DisMap;
            fixed _Offset;
            float4 _DisMap_ST;
            
            struct a2v {
                float2 uv : TEXCOORD0;
                float4 vertex : POSITION;
            };
            struct v2f {
                float2 texcoord : TEXCOORD0;
                float4 pos : SV_POSITION;
            };
            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.texcoord = v.uv;
                return o;
            }
            fixed4 frag(v2f f) : SV_TARGET {
                fixed2 changingUV = f.texcoord + _Time.x * 2; //定义噪声图的采样UV
                fixed2 displ = tex2D(_DisMap, changingUV).xy; //获取采样色值的红、绿色值.红色控制X轴偏量，绿色控制Y轴偏量
                displ = ((displ * 2) - 1); //为了呈现波动感将色值范围【0，1】映射到【-1，1】
                displ *= _Offset; //乘上幅度
                fixed4 col = tex2D(_MainTex, f.texcoord + displ); //重新对主纹理进行采样获得最终效果
                return col;
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}