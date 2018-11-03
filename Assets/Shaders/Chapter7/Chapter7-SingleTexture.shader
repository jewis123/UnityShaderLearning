// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 7/Single Texture" {
	Properties {
		_Color("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex("Main Tex", 2D) = "white" {}
		_Specular("Specular", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Range(8.0, 256)) = 20
	}
	SubShader {
		Pass {
			Tags {"LightMode" = "ForwardBase"}
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
				
			#include "Lighting.cginc"
				
			fixed4 _Color; 
			sampler2D _MainTex; 
			float4 _MainTex_ST; //存放纹理属性，xy存缩放，zw存偏移
			fixed4 _Specular; 
			float _Gloss; 
			
			struct a2v {
				float4 vertex : POSITION; 
				float3 normal : NORMAL; 
				float4 texcoord : TEXCOORD0; //储存纹理坐标
			}; 
			
			struct v2f {
				float4 pos : SV_POSITION; 
				float3 worldNormal : TEXCOORD0; //第一组纹理坐标储存世界坐标下的法线
				float3 worldPos : TEXCOORD1; //第二组用来储存世界下的定点位置
				float2 uv : TEXCOORD2; //第三组用来储存UV坐标
			}; 
			
			v2f vert(a2v v) {
				v2f o; 
				o.pos = UnityObjectToClipPos(v.vertex); //将模型空间转换成切线空间
				
				o.worldNormal = UnityObjectToWorldNormal(v.normal); //获取法线
				
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz; //将原先的顶点坐标转换成世界坐标下的顶点坐标
				
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex); //获取纹理缩放，偏移属性
				//内部实现过程： o.uv = v.texcood.xy * _MainTex_ST.xy + _MainTex_ST.zw
				
				return o; 
			}
			
			fixed4 frag(v2f i) : SV_Target {
				fixed3 worldNormal = normalize(i.worldNormal); 
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos)); //仅可用于前向渲染中。输入一个世界空间中的顶点位置，返回世界空间中从该点到光源的光照方向
				
				// Use the texture to sample the diffuse color
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb; //纹理采样，颜色叠加：基础颜色
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo; //环境光部分颜色
				
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir)); //依据漫反射模型计算漫反射颜色
				
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos)); 
				fixed3 halfDir = normalize(worldLightDir + viewDir); 
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);   //pow： 指数次幂
				
				return fixed4(ambient + diffuse + specular, 1.0); 
			}
			
			ENDCG
		}
	}
	FallBack "Specular"
}
