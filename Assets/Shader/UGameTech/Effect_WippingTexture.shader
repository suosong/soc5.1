Shader "UGameTech/Effect_WippingTexture"
{
	Properties
	{
        _baseTex 	("Base Texture(None by alpha)", 2D)	= 	"black" {}
        _wipeTex 	("Wipe Texture", 2D) 				= 	"black" {}
		_wipeCoeff	("WipeCoeff", Range(0.0, 1.0)) 		=	0.0
		_YModeCoeff	("YModeCoeff", Range(0.0, 1.0))		= 	0.0
	}

    SubShader
	{
		/*
		//> Surface Shader Mode
		//> ---------------------------------------------------------------------
		Tags { "RenderType" = "Transparent" }
		Blend	SrcAlpha	OneMinusSrcAlpha
		
		CGPROGRAM

			#pragma surface surf Lambert

			struct Input 
			{
			  float2 uv_baseTex;
			  float2 uv_wipeTex;
			};

			//变量声明
			sampler2D 	_baseTex;
			sampler2D 	_wipeTex;
			float		_wipeCoeff;
			float		_YModeCoeff;

			void surf (Input IN, inout SurfaceOutput o) 
			{
				float4 oricol   = tex2D(_baseTex, IN.uv_baseTex);
				float4 col      = tex2D(_wipeTex, IN.uv_baseTex);
				float  comp     = smoothstep(0.0, 1.0, sin(_wipeCoeff));
				float  coeff    = clamp(-2.0 + 2.0 * IN.uv_baseTex.y + 3.0 * comp, 0.0, 1.0);
				float4 result   = lerp(oricol, col, coeff);
				
				o.Albedo = result.rgb;
				o.Alpha  = result.a;
			}
			
		ENDCG
		*/
		
		//> CG Shader Mode
		//> ---------------------------------------------------------------------
		Tags { "Queue"="Transparent" "RenderType" = "Transparent" }
		Blend	SrcAlpha	OneMinusSrcAlpha
		
        Pass
		{
			CGPROGRAM
				#pragma 	vertex vert
				#pragma 	fragment frag
				#include 	"UnityCG.cginc"

				sampler2D	_baseTex;
				sampler2D 	_wipeTex;
				float4		_baseTex_ST;
				
				float		_wipeCoeff;
				float		_YModeCoeff;

				struct v2f
				{
					float4 	pos 	: POSITION;
					float2	uv 		: TEXCOORD0;
				};

				v2f vert(appdata_base v)
				{
					v2f o;
					o.pos 		= mul( UNITY_MATRIX_MVP, v.vertex );
					o.uv 		= TRANSFORM_TEX( v.texcoord, _baseTex );
					return o;
				}

				half4 frag(v2f i) : COLOR
				{
					float4 oricol   = tex2D(_baseTex, i.uv);
					float4 col      = tex2D(_wipeTex, i.uv);

					float  comp     = smoothstep(0.0, 1.0, sin(_wipeCoeff));
					float  coeff    = clamp(-2.0 + 2.0 * (1.0-i.uv.y) + 3.0 * comp, 0.0, 1.0);
					//float  coeff    = clamp(-2.0 + 2.0 * (i.uv.y) + 3.0 * comp, 0.0, 1.0);
					float4 result   = lerp(oricol, col, coeff);

					return result;
				}
			ENDCG
		}
	}
}