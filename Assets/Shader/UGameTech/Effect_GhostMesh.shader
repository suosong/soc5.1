Shader "UGameTech/Effect_GhostMesh"
{
	Properties
	{
		_GhostColor	("Main Color", Color) = (1,0,0,1)
		_MainTex 	("Base (RGB)", 2D) = "white" {}
	}

	SubShader
	{
		LOD 200
		
		Tags { "Queue" = "Transparent+5" "IgnoreProjector" = "True" "RenderType"="Transparent" }

		Pass
		{
			Name "GhostDepth"
			ColorMask	0
		}

		Pass
		{
			Name "Ghost"

			ZWrite		Off
			Cull		Back
			Blend		SrcAlpha	OneMinusSrcAlpha

			ZTest 		LEqual
			//> AlphaTest	Greater		0
			//> ColorMask	RGB
			
			CGPROGRAM
			
				#include "UnityCG.cginc"
				#pragma vertex		vert
				#pragma fragment	frag
				
				
				struct appdata_t
				{
					float4 vertex 	: POSITION;
					float4 normal 	: NORMAL;
				}; 

				struct v2f
				{
					float4 pos		: POSITION;
					float4 n		: TEXCOORD0;
					float3 PtToCam	: TEXCOORD1;
				};

				sampler2D	_MainTex;
				float4 		_GhostColor;

				v2f vert (appdata_t v)
				{
					//> 这里传入的顶点和法线是骨骼空间的，要做世界空间转换
					//> ----------------------------------------------------------------
					v2f o;
					o.pos		= mul(UNITY_MATRIX_MVP, v.vertex);
					o.PtToCam 	= normalize( _WorldSpaceCameraPos - mul(_Object2World,v.vertex) );

					float4 n = v.normal;
					n.w = 0.0f;
					o.n = normalize( mul( _Object2World, n ));

					return o;
				}
				
				float4 frag (v2f IN) : COLOR
				{
					float u = saturate(dot(IN.n, IN.PtToCam));

					float factor = tex2D( _MainTex, float2(u, 0.5f) ).r;

					float4 finalColor = _GhostColor;
					finalColor.rgb = finalColor.rgb * 2.0f;
					finalColor.a *= factor;

					/*
					float4 finalColor = _GhostColor;
					finalColor.rgb = finalColor.rgb * factor * 0.01f + IN.n;
					finalColor.a *= (1- factor);
					*/
					return finalColor;
				}
				
			ENDCG
		}
	}

	Fallback "Transparent/VertexLit"
}
