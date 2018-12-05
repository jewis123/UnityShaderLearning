// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 8/Alpha Test" {
	Properties {
		_Color ("Color Tint", Color) = (1, 1, 1, 1)  //定义覆盖的颜色
		_MainTex ("Main Tex", 2D) = "white" {}       //定义使用到的纹理
		_Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5  //定义裁剪阈值
	}
	SubShader {
		Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}  //通常使用透明度测试的shader都应该使用这三个标签
		
		Pass {
			Tags { "LightMode"="ForwardBase" }    //应为用到光照，所以要设置光照模式，前向渲染是较快的渲染方式应用在大多数情况下
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;    //ST分别对应纹理采样结果的Scale和Transform(即offset)
			fixed _Cutoff;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};
			
			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				//上面一句相当于 v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw。  这就是为什么要定义_MainTex_ST的原因
				
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				
				fixed4 texColor = tex2D(_MainTex, i.uv);  //tex2D就是对图像的UV坐标进行采样获取顶点颜色的过程
				
				// Alpha test
				clip (texColor.a - _Cutoff);   //结果小于0就裁剪
				// Equal to 
//				if ((texColor.a - _Cutoff) < 0.0) {
//					discard;
//				}
				
				fixed3 albedo = texColor.rgb * _Color.rgb;                //初始色值
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;   //环境光色值
				
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));//漫反射色值
				
				return fixed4(ambient + diffuse, 1.0);
			}
			
			ENDCG
		}
	} 
	// 使得alpha测试的物体能产生投影
	FallBack "Transparent/Cutout/VertexLit" 
}
