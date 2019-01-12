﻿// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "UI/Hero_Dissolve"
{
    Properties
    {
        [PerRendererData]_MainTex("Sprite Texture", 2D) = "white" {}
        _Color("Tint", Color) = (1, 1, 1, 1)
        _ExposeColor("Expose", Color) = (1, 1, 1, 1)
        _Ins("Ins", Float) = 0
        _DisSpeed("DisSpeed", Float) = 1.2
        _DisIntensity("DisIntensity", Float) = 0.2
        _Dis("Dis", 2D) = "white" {}
        
        _StencilComp("Stencil Comparison", Float) = 8
        _Stencil("Stencil ID", Float) = 0
        _StencilOp("Stencil Operation", Float) = 0
        _StencilWriteMask("Stencil Write Mask", Float) = 255
        _StencilReadMask("Stencil Read Mask", Float) = 255
        
        _ColorMask("Color Mask", Float) = 15
        
        [Toggle(UNITY_UI_ALPHACLIP)]_UseUIAlphaClip("Use Alpha Clip", Float) = 0
    }
    
    SubShader
    {
        Tags {
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
            "PreviewType" = "Plane"
            "CanUseSpriteAtlas" = "True"
        }
        
        Stencil
        {
            Ref[_Stencil]
            Comp[_StencilComp]
            Pass[_StencilOp]
            ReadMask[_StencilReadMask]
            WriteMask[_StencilWriteMask]
        }
        
        Cull Back
        Lighting Off
        ZWrite Off
        LOD 200
        ZTest[unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask[_ColorMask]
        
        Pass
        {
            Name "Default"
            CGPROGRAM
            #pragma vertex vert
                #pragma fragment frag
                #pragma target 2.0
                
            #include "UnityCG.cginc"
                #include "UnityUI.cginc"
                
            #pragma multi_compile __ UNITY_UI_CLIP_RECT
                #pragma multi_compile __ UNITY_UI_ALPHACLIP
                
            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            fixed4 _ExposeColor;
            fixed _Ins;
            fixed _DisSpeed;
            fixed _DisIntensity;
            
            
            sampler2D _Dis;
            
            struct appdata_t
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                };
            
            struct v2f
            {
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
                float2 texcoord : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
                };
            
            
            
            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.worldPosition = v.vertex;
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);
                
                OUT.texcoord = v.texcoord;
                
                OUT.color = v.color * _Color;
                return OUT;
            }
            
            
            fixed4 frag(v2f IN) : SV_Target
            {
                fixed4 dis = tex2D(_Dis, IN.texcoord - _Time.x * _DisSpeed);
                half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;
                fixed a = 1 - color.a;
                
                color = (tex2D(_MainTex, IN.texcoord + dis.xy * a * _DisIntensity) + _TextureSampleAdd) * IN.color;
                color.a = 1;
                // fixed l=length(color.rgb);
                color.rgb += _ExposeColor * _Ins;
                
                #ifdef UNITY_UI_CLIP_RECT
                    color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif
                    
                #ifdef UNITY_UI_ALPHACLIP
                    clip(color.a - 0.001);
                #endif
                    
                return color;
            }
            ENDCG
        }
    }
}
