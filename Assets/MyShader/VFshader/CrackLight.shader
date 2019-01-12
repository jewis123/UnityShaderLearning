Shader "Custom/CrackLight" {
    Properties {
        [PerRendererData]_MainTex("MainTex",2D)="white"{}
        _CrackTex("CrackTex",2D) = "white"{}
        _LightFactor("LightFactor",Float) = 1
        _Color("Color",Color) = (0, 0, 0, 0) 
    }
    SubShader {
        Tags {
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
            "PreviewType" = "Plane"
            "CanUseSpriteAtlas" = "True"
        }
        pass {
            LOD 200
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _CrackTex;
            float4 _MainTex_ST;
            fixed _LightFactor;

            struct a2v {
                float4 vertex:POSITION;
                fixed4 texcoord:TEXCOORD0;
            };
            struct v2f {
                float4 pos:POSITION;
                float2 uv:TEXCOORD0;
            };
            v2f vert(a2v v) {
                v2f f;
                f.pos = UnityObjectToClipPos(v.vertex);
                f.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return f;
            }
            fixed4 frag(v2f f) : SV_TARGET {
                fixed4 c = tex2D(_MainTex,f.uv);
                fixed4 d = tex2D(_CrackTex,f.uv);
                d.rgb *=_LightFactor;
                c.rgb += d.rgb;
                return c;
            }
            ENDCG
        }
    }
    Fallback "Mobile/VertexLit"
}