// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/BurnDissolve" {
    Properties {
        _MainTex("Base (RGB)", 2D) = "white" {}
        _LightMulti("LightMulti", float) = 2
        _DissolveTex("Dissolve Texture", 2D) = "white" {}
        _DissolvePower("Dissolve Power", Range(0, 1)) = 0.2
        
        _BurnSize("Burn Size", Range(0.0, 1.0)) = 0.15
        _BurnRamp("Burn Ramp(RGB)", 2D) = "white" {}
        _BurnColor("Burn Color", Color) = (1, 1, 1, 1)
        
    }
    SubShader {
        Tags {"IgnoreProjector" = "True" "RenderType" = "TransparentCutout"}
        LOD 200
        
        Pass {
            Cull Back
            Lighting On
            LOD 200
            CGPROGRAM
            #pragma vertex vert
                #pragma fragment frag
                
            #include "UnityCG.cginc"
                
            sampler2D _MainTex; 
            sampler2D _BurnRamp; 
            sampler2D _DissolveTex; 
            fixed4 _MainTex_ST; 
            fixed _LightMulti; 
            fixed _DissolvePower; 
            fixed4 _BurnColor; 
            float _BurnSize; 
            
            struct a2v
            {
                fixed4 vertex : POSITION; 
                fixed3 normal : NORMAL; 
                fixed4 texcoord : TEXCOORD0; 
            }; 
            
            struct v2f
            {
                fixed4 pos : POSITION; 
                fixed2 uv : TEXCOORD0; 
                fixed3 color : COLOR; 
            }; 
            
            v2f vert(a2v v)
            {
                v2f o; 
                o.pos = UnityObjectToClipPos(v.vertex); 
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex); 
                return o; 
            }
            
            fixed4 frag(v2f i) : COLOR
            {
                fixed4 c = tex2D(_MainTex, i.uv); 
                c.rgb *=  _BurnColor; 
                half d = tex2D(_DissolveTex, i.uv).rgb - _DissolvePower; 
                fixed4 e = tex2D(_BurnRamp, i.uv); 
                clip(d); 
                
                if(d < _BurnSize && _DissolvePower > 0) {
                    c = tex2D(_BurnRamp, float2(d * (1 / _BurnSize), 0)) * _LightMulti; 
                }
                
                return c; 
            }
            
            ENDCG
        }
    }
    FallBack "Mobile/VertexLit"
}
