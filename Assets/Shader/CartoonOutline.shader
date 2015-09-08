Shader "VertexColor/CartoonOutline"
{
	Properties
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_OutlineColor ("Outline Color", Color) = (0.3,0.2,0.1,1)
		_OutlineWidth ("Outline width", Range(0,2)) = 0.25
		
		//> [add by Cool_J]
		//> 效果相关的属性
		//> -----------------------------------------------------------------
		//> 叠色
		_ColorEff 	("Additive Color", Color) 			= (0,0,0,0)
		
		//> 溶解
		_DissolveTex("Dissolve(RGB)", 2D) 				= "white" {}
		_Burn		("Burn Amount", Range(-0.25, 1.25)) = 1.0
		_LineWidth	("Burn Line Size", Range(0.0, 0.2)) = 0.1
		_BurnColor	("Burn Color", Color) 				= (1.0, 0.0, 0.0, 1.0)
		//> [end by Cool_J]
	}

	SubShader
	{
		//Tags { "Queue" = "Geometry-100"	"IgnoreProjector" = "True" "RenderType"="Opaque" }
		Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType"="Transparent" }
		
		LOD 200
		
		//Outline default
		Pass
		{
			Name "OUTLINE"

			Cull		Front
			Lighting 	Off
			ZWrite 		On
			Blend		SrcAlpha	OneMinusSrcAlpha
			
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				
				#include "UnityCG.cginc"
				
				struct a2v
				{
					float4 vertex 	: POSITION;
					float3 normal 	: NORMAL;
					float2 texcoord : TEXCOORD0;
				}; 
				
				struct v2f
				{
					float4 pos 		: POSITION;
					float2 texcoord : TEXCOORD0;
				};
				
				//> implement codes ...
				//> -----------------------------------------------------------------
				float 	_OutlineWidth;
				float4 	_OutlineColor;
				
				//> 效果相关的属性
				//> -----------------------------------------------------------------
				//> 叠色，不影响描边颜色

				//> 溶解
				sampler2D	_DissolveTex;
				float		_Burn;
				float		_LineWidth;
				float4		_BurnColor;
				
				v2f vert (a2v v)
				{
					v2f o;
					//Correct Z artefacts
					float4 pos = mul( UNITY_MATRIX_MV, v.vertex);
					float3 normal = mul( (float3x3)UNITY_MATRIX_IT_MV, v.normal);
					normal.z = -0.6;
					
					float dist = distance(_WorldSpaceCameraPos, mul(_Object2World, v.vertex));
					pos = pos + float4(normalize(normal),0) * _OutlineWidth*0.01f * dist;
					
					o.pos = mul(UNITY_MATRIX_P, pos);

					o.texcoord.x = v.texcoord.x;
					o.texcoord.y = v.texcoord.y;
					
					return o;
				}
				
				float4 frag (v2f IN) : COLOR
				{
					half4 finalColor = _OutlineColor;
					
					//> 溶解效果，要同时溶解掉描边颜色
					//> -----------------------------------------------------------------
					half4 burnColor = tex2D(_DissolveTex, IN.texcoord);
					half4 clear = half4(0.0);
					
					clear = lerp(_BurnColor, clear, max(0.0, int(burnColor.r - (_Burn+_LineWidth) + 0.99)));
					finalColor = lerp(finalColor, clear, max(0.0,int(burnColor.r - _Burn + 0.99)));
					finalColor.a = lerp(1.0, 0.0, int(burnColor.r - (_Burn+_LineWidth) + 0.99));
					
					return finalColor;
				}
			ENDCG
		}
		
		
		//Outline Const Size
		Pass
		{
			Name "OUTLINE_CONST"
			
			Cull 		Back
			Lighting 	Off
			ZWrite 		On
			Blend		SrcAlpha	OneMinusSrcAlpha
			
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				
				#include "UnityCG.cginc"
				
				struct appdata_t
				{
					float4 vertex : POSITION;
					float2 texcoord : TEXCOORD0;
					float3 normal : NORMAL;				
				}; 
				
				struct v2f
				{
					float4 vertex : POSITION;
					float2 texcoord : TEXCOORD0;
					float  rim : TEXCOORD1;
				};

				//> implement codes ...
				//> -----------------------------------------------------------------
				sampler2D 	_MainTex;
				float4 		_Color;
				float4		_OutlineColor;
				
				//> 效果相关的属性
				//> -----------------------------------------------------------------
				//> 叠色
				float4		_ColorEff;

				//> 溶解
				sampler2D	_DissolveTex;
				float		_Burn;
				float		_LineWidth;
				float4		_BurnColor;


				v2f vert (appdata_t v)
				{
					v2f o;
					o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
					o.texcoord.x = v.texcoord.x;
					o.texcoord.y = v.texcoord.y;
					
					float3 normalWorld = normalize( mul( float4( v.normal, 0.0f ), _World2Object ).xyz );
					half xrim = dot( normalWorld,normalize(_WorldSpaceCameraPos));
					o.rim = (xrim+0.3f)*2.0f;
					
					return o;
				}
				
				float4 frag (v2f IN) : COLOR
				{
					half4 finalColor = tex2D(_MainTex, IN.texcoord);
					finalColor.rgb *= _Color.rgb*clamp(IN.rim,0.9f,1.2f);
				  
					//> 叠色效果
					//> -----------------------------------------------------------------
					//_ColorEff *= (IN.rim * 2.0f);
					finalColor += _ColorEff;

					//> 溶解效果
					//> -----------------------------------------------------------------
					half4 burnColor = tex2D(_DissolveTex, IN.texcoord);
					half4 clear = half4(0.0);
					
					clear = lerp(_BurnColor, clear, max(0.0, int(burnColor.r - (_Burn+_LineWidth) + 0.99)));
					finalColor = lerp(finalColor, clear, max(0.0,int(burnColor.r - _Burn + 0.99)));
					finalColor.a = lerp(1.0, 0.0, int(burnColor.r - (_Burn+_LineWidth) + 0.99));
					
					return finalColor;
				}
			ENDCG
		}
	}
}
