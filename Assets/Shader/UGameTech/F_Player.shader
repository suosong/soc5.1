
//> Fragment shader for object with diffuse & normal & specular
//> Referenced follow:
//> http://wiki.unity3d.com/index.php/BumpColorSpec this is not working correctly
//> http://www.cnblogs.com/yaukey/archive/2013/06/16/unity_bump_mapping_shader.html
//> http://blog.csdn.net/candycat1992/article/details/40212735
//> -----------------------------------------------------------------

//> Support: Diffuse, LightPower, AlphaCutoff, Dissolve, ColorEff;
//> -----------------------------------------------------------------

Shader "UGameTech/F_Player"
{
	Properties
	{
		_MainTex("Main Tex", 2D)							= "white" {}
		_LightPower("Lighting Power", Float)				= 1.0
		_AlphaCutoff("Alpha Cut Off", Float)				= 0.9

		//> 溶解
		_DissolveTex("Dissolve(RGB)", 2D) 					= "white" {}
		_Burn		("Burn Amount", Range(-0.25, 1.25))		= 1.0
		_LineWidth	("Burn Line Size", Range(0.0, 0.2))		= 0.1
		_BurnColor	("Burn Color", Color) 					= (1.0, 0.0, 0.0, 1.0)

		//> 叠色
		_ColorEff 	("Additive Color", Color) 				= (0,0,0,0)


		//> Append feature for Wiping Texture
		//> -----------------------------------------------------------------
		/*
        _WipeTex 	("Wipe Texture", 2D) 				= 	"black" {}
		_WipeCoeff	("WipeCoeff", Range(0.0, 1.0)) 		=	0.0
		_YModeCoeff	("YModeCoeff", Range(0.0, 1.0))		= 	0.0
		*/
	}

    SubShader
	{
		Tags {"RenderType" = "Opaque"}
		LOD 		300
		Cull 		Back
		ZWrite 		On
		Lighting 	Off

        Pass
		{
			CGPROGRAM
			#pragma vertex			vert
			#pragma fragment		frag
			#pragma fragmentoption	ARB_precision_hint_fastest
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

            sampler2D		_MainTex;
			half4			_MainTex_ST;

			half			_LightPower;
			half			_AlphaCutoff;
			half4			_ColorEff;

			//> 溶解
			sampler2D		_DissolveTex;
			float			_Burn;
			float			_LineWidth;
			float4			_BurnColor;


			//> Fragment input struction
			//> -----------------------------------------------------------------
			struct v2f
			{
				float4	pos		: POSITION;
				float2	uv		: TEXCOORD0;
				float3	lightDir: TEXCOORD2;
				float3	viewDir	: TEXCOORD3;
				float4	vertClr	: TEXCOORD4;
			};


			//> Vertex program
			//> -----------------------------------------------------------------
			v2f vert(appdata_full v)
			{
				v2f o;

				o.pos		= mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv		= TRANSFORM_TEX(v.texcoord, _MainTex);
				o.lightDir	= ObjSpaceLightDir(v.vertex);
				o.viewDir	= ObjSpaceViewDir(v.vertex);

				//> 顶点光照
				half3 lightDir = ObjSpaceLightDir(v.vertex);
				half NdotL = max(0, dot( v.normal, lightDir));
				half diff = NdotL * 0.5 + 0.5;
				half atten	= LIGHT_ATTENUATION(o);

				o.vertClr = v.color * (diff * atten * 2);

				return o;
			}


			//> 溶解效果
			//> -----------------------------------------------------------------
			void	ProcessDissolve(v2f i, inout half4 color)
			{
				half4	burnColor	= tex2D( _DissolveTex, i.uv );
				half4	clear		= half4(0.0, 0.0, 0.0, 0.0);

				int		burnBlendR	= burnColor.r - (_Burn+_LineWidth) + 0.99;
				int		burnBlendT	= burnColor.r - _Burn + 0.99;

				clear		=	lerp( _BurnColor,	clear,		burnBlendR );
				color.rgb	=	lerp( color,		clear.rgb,	burnBlendT );
				color.a		*=	lerp( 1.0,			0.0,		burnBlendR );
			}


			//> Fragment Program
			//> -----------------------------------------------------------------
			float4 frag(v2f i) : SV_Target
			{
				half4 fCol = tex2D(_MainTex, float2(i.uv.x, i.uv.y));

				half4 c;
				c.rgb = fCol.rgb * i.vertClr * _LightColor0.rgb * _LightPower;
				c.a = fCol.a;

				c.rgb += _ColorEff;

				//> NOTE: need alpha
				ProcessDissolve(i, c);

				//> Alpha cutoff
				if ( c.a < _AlphaCutoff )
				{
					//> yes: discard this fragment
					discard;
				}

				return c;
			}

            ENDCG
        }


		//> Append feature for Wiping Texture
		//> -----------------------------------------------------------------
		/*
		Pass
		{
			CGPROGRAM
				#pragma 	vertex vert
				#pragma 	fragment frag
				#include 	"UnityCG.cginc"

				sampler2D	_MainTex;
				sampler2D 	_WipeTex;
				float4		_MainTex_ST;
				
				float		_WipeCoeff;
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
					o.uv 		= TRANSFORM_TEX( v.texcoord, _MainTex );
					return o;
				}

				half4 frag(v2f i) : COLOR
				{
					float4 oricol   = tex2D(_MainTex, i.uv);
					float4 col      = tex2D(_WipeTex, i.uv);

					float  comp     = smoothstep(0.0, 1.0, sin(_WipeCoeff));
					float  coeff    = clamp(-2.0 + 2.0 * (1.0-i.uv.y) + 3.0 * comp, 0.0, 1.0);
					//float  coeff    = clamp(-2.0 + 2.0 * (i.uv.y) + 3.0 * comp, 0.0, 1.0);
					float4 result   = lerp(oricol, col, coeff);

					return result;
				}
			ENDCG
		}
		*/
    }
    
    Fallback "Diffuse"
}
