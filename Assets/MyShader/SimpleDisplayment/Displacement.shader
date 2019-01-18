Shader "Custom/SimpleDisplacement" {
    Properties {
        _MainTex("Texture", 2D) = "white" {}
        _DisplacementMask("Displacement mask", 2D) = "white"
        _DisplacementAmount("Displacement amount", float) = 0
        _EffectRadius("EffectRadius",float) = 0
    }
    SubShader {
        Tags {"Queue" = "Transparent"}
        pass {
            CGPROGRAM
            
            #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"
                
            sampler2D _MainTex; 
            sampler2D _DisplacementMask; 
            float _DisplacementAmount; 
            fixed _EffectRadius;
            
            struct a2v {
                float4 vertex : POSITION; 
                float2 uv : TEXCOORD0; 
            }; 
            struct v2f {
                float2 uv : TEXCOORD0; 
                float4 vertex : SV_POSITION; 
            }; 
            v2f vert(a2v v) {
                v2f o; 
                o.vertex = UnityObjectToClipPos(v.vertex); 
                o.uv = v.uv; 
                return o; 
            }
            fixed4 frag(v2f f):SV_TARGET {
                fixed4 disl = tex2D(_DisplacementMask,f.uv);
                float2 displ_uv = f.uv + disl * _DisplacementAmount;
                fixed4 distortedCol = tex2D(_MainTex, displ_uv);
                return distortedCol;
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}