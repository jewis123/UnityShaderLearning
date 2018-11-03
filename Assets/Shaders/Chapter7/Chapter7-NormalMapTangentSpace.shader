// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 7/Normal Map In Tangent Space" {
	Properties {
		_MainTex ("Main Tex", 2D) = "white" {}
		_BumpMap ("Normal Map", 2D) = "bump" {}
		_BumpScale ("Bump Scale", Float) = 1.0
	}
	SubShader {
		Pass { 
			Tags { "LightMode"="ForwardBase" }
		
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float3 lightDir: TEXCOORD1;
			};

			// Unity doesn't support the 'inverse' function in native shader
			// so we write one by our own
			// Note: this function is just a demonstration, not too confident on the math or the speed
			// Reference: http://answers.unity3d.com/questions/218333/shader-inversefloat4x4-function.html
			float4x4 inverse(float4x4 input) {
				#define minor(a,b,c) determinant(float3x3(input.a, input.b, input.c))
				
				float4x4 cofactors = float4x4(
				     minor(_22_23_24, _32_33_34, _42_43_44), 
				    -minor(_21_23_24, _31_33_34, _41_43_44),
				     minor(_21_22_24, _31_32_34, _41_42_44),
				    -minor(_21_22_23, _31_32_33, _41_42_43),
				    
				    -minor(_12_13_14, _32_33_34, _42_43_44),
				     minor(_11_13_14, _31_33_34, _41_43_44),
				    -minor(_11_12_14, _31_32_34, _41_42_44),
				     minor(_11_12_13, _31_32_33, _41_42_43),
				    
				     minor(_12_13_14, _22_23_24, _42_43_44),
				    -minor(_11_13_14, _21_23_24, _41_43_44),
				     minor(_11_12_14, _21_22_24, _41_42_44),
				    -minor(_11_12_13, _21_22_23, _41_42_43),
				    
				    -minor(_12_13_14, _22_23_24, _32_33_34),
				     minor(_11_13_14, _21_23_24, _31_33_34),
				    -minor(_11_12_14, _21_22_24, _31_32_34),
				     minor(_11_12_13, _21_22_23, _31_32_33)
				);
				#undef minor
				return transpose(cofactors) / determinant(input);
			}

			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				
				//分别用两个分量来储存两张图的纹理属性
				o.uv.xy = TRANSFORM_TEX(v.texcoord,_MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord,_BumpMap);

				///
				/// Note that the code below can handle both uniform and non-uniform scales
				///

				// 构造一个将顶点从 切线空间 转换成 世界空间 的矩阵
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);  
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);  
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;  //w分量决定法线方向 

				float4x4 tangentToWorld = float4x4(worldTangent.x, worldBinormal.x, worldNormal.x, 0.0,
												   worldTangent.y, worldBinormal.y, worldNormal.y, 0.0,
												   worldTangent.z, worldBinormal.z, worldNormal.z, 0.0,
												   0.0, 0.0, 0.0, 1.0);
				// The matrix that transforms from world space to tangent space is inverse of tangentToWorld
				float3x3 worldToTangent = inverse(tangentToWorld);

				// 将光线方向 从 世界空间 转换到 切线空间下
				o.lightDir = mul(worldToTangent, WorldSpaceLightDir(v.vertex));

				///
				/// Note that the code below can only handle uniform scales, not including non-uniform scales
				/// 

				// Compute the binormal
//				float3 binormal = cross( normalize(v.normal), normalize(v.tangent.xyz) ) * v.tangent.w;
//				// Construct a matrix which transform vectors from object space to tangent space
//				float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);
				// Or just use the built-in macro
//				TANGENT_SPACE_ROTATION;
//				
//				// Transform the light direction from object space to tangent space
//				o.lightDir = mul(rotation, normalize(ObjSpaceLightDir(v.vertex))).xyz;
//				// Transform the view direction from object space to tangent space
//				o.viewDir = mul(rotation, normalize(ObjSpaceViewDir(v.vertex))).xyz;
				
				return o;
			}
			
			fixed3 frag(v2f i) : SV_Target {				
				fixed3 tangentLightDir = normalize(i.lightDir);
				
				//采样存储到UV的zw分量
				fixed3 packedNormal = tex2D(_BumpMap, i.uv.zw);
				fixed3 tangentNormal;

				//如果图片不是"Normal map"，要手动做如下处理
//				tangentNormal.xy = (packedNormal.xy * 2 - 1) * _BumpScale;
//				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
				
				// 否则直接用如下内置函数
				tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
				
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb;
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));

				return fixed3(ambient+diffuse);
			}
			
			ENDCG
		}
	} 
	FallBack "Specular"
}
