// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 7/Mask Texture" {
	Properties {
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_BumpMap ("Normal Map", 2D) = "bump" {}
		_BumpScale("Bump Scale", Float) = 1.0
		_SpecularMask ("Specular Mask", 2D) = "white" {}
		_SpecularScale ("Specular Scale", Float) = 1.0      //
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20
	}
	SubShader {
		Pass { 
			Tags { "LightMode"="ForwardBase" }
		
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			
			fixed4 _Color;
			sampler2D _MainTex;
			sampler2D _BumpMap;
			sampler2D _SpecularMask;
			float4 _MainTex_ST;              //3个采样器使用同一个纹理属性，节省插值寄存器
			float _BumpScale;
			float _SpecularScale;
			fixed4 _Specular;
			float _Gloss;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 lightDir: TEXCOORD1;
				float3 viewDir : TEXCOORD2;
			};
			
			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);    //获取_MainTex纹理属性到纹理坐标
				
				TANGENT_SPACE_ROTATION;  //计算转换到切空间的 3x3矩阵rotation 
				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;     //将模型空间的光线方向转换到切线空间下
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;       //将模型空间的视线方向转换到切线空间下
				
				
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
			 	fixed3 tangentLightDir = normalize(i.lightDir);  //归一化
				fixed3 tangentViewDir = normalize(i.viewDir);    //归一化

				fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv));
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));
				
			 	fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
			 	// Get the mask value
			 	fixed specularMask = tex2D(_SpecularMask, i.uv).r * _SpecularScale;
			 	// Compute specular term with the specular mask
			 	fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss) * specularMask;
			
				return fixed4(ambient + diffuse + specular, 1.0);
			}
			
			ENDCG
		}
	} 
	FallBack "Specular"
}
