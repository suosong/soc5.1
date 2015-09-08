
//> Fragment shader for object with diffuse & normal & specular
//> Referenced follow:
//> http://wiki.unity3d.com/index.php/BumpColorSpec this is not working correctly
//> http://www.cnblogs.com/yaukey/archive/2013/06/16/unity_bump_mapping_shader.html
//> http://blog.csdn.net/candycat1992/article/details/40212735
//> -----------------------------------------------------------------

//> Support: Diffuse, Normal, Specular, LightPower, AlphaCutoff, Mask;
//> -----------------------------------------------------------------

Shader "UGameTech/F_Player_N_Mask"
{
	Properties
	{
		_MainTex("Main Tex", 2D)							= "white" {}
		_BumpTex("Bump Tex", 2D)							= "bump" {}
		_SpecTex("Spec Tex", 2D)							= "white" {}
		_LightPower("Lighting Power", Float)				= 1.0
		_AlphaCutoff("Alpha Cut Off", Float)				= 0.9

		_SpecIntensity	("Spec Intensity", Range(0.01, 1))	= 0.85
		_SpecWidth		("Spec Width", Range(0, 1))			= 0.2

		_PreferColor("Prefer Color", Color)					= (0.0, 0.0, 0.0, 1.0)
		_SpecularColor("Specular Color", Color)				= (1.0, 1.0, 1.0, 1.0)

		_ColorMaskTex("ColorMask Tex", 2D)					= "black"	{}
		_ColorMask("Color Mask", Color)						= (0,0,0,0)
		_ColorMaskPow("Color Mask Power", Range(0.0, 3.0))	= 0.0
		_ColorMaskCtrl("Mask Control", Float)				= 0.0
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

            sampler2D	_MainTex;
            sampler2D	_BumpTex;
			sampler2D	_SpecTex;
			half4		_MainTex_ST;

			half		_SpecIntensity;
			half		_SpecWidth;

			half		_LightPower;
			half		_AlphaCutoff;
			half4		_PreferColor;
			half4		_SpecularColor;

			sampler2D 	_ColorMaskTex;
			half4		_ColorMask;
			half		_ColorMaskPow;
			half		_ColorMaskCtrl;


			//> Fragment input struction
			//> -----------------------------------------------------------------
			struct v2f
			{
				float4	pos		: POSITION;
				float2	uv		: TEXCOORD0;
				float2	uv2		: TEXCOORD1;
				float3	lightDir: TEXCOORD2;
				float3	viewDir	: TEXCOORD3;
				float4	vertClr	: TEXCOORD4;
				LIGHTING_COORDS(3, 4)
			};


			//> Vertex program
			//> -----------------------------------------------------------------
			v2f vert(appdata_full v)
			{
				v2f o;
				
				TANGENT_SPACE_ROTATION;

				o.lightDir	= mul(rotation, ObjSpaceLightDir(v.vertex));
				o.viewDir	= mul(rotation, ObjSpaceViewDir(v.vertex));

				o.pos		= mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv		= TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv2		= TRANSFORM_TEX(v.texcoord, _MainTex);
				o.vertClr	= v.color * _LightPower;

				TRANSFER_VERTEX_TO_FRAGMENT(o);

				return o;
			}

			float4	ProcessColorMask( float3 viewDir, float3 normal, float2 uv )
			{
				float4 fResult;

				half4	texCol	=	tex2D( _ColorMaskTex, uv );
				fResult.rgb = texCol.rgb * _ColorMask * _ColorMaskCtrl;
				fResult.a	= texCol.a;

				return fResult;
			}

			//> Fragment Program
			//> -----------------------------------------------------------------
			float4 frag(v2f i) : COLOR
			{
				//> 纹理像素提取
				half4	diffTex	= tex2D(_MainTex, i.uv);
                half4	specTex = tex2D(_SpecTex, i.uv2);
				half4	bumpTex	= tex2D(_BumpTex, i.uv2);

				half3	viewDir	= normalize(i.viewDir);
				half3	lightDir= normalize(i.lightDir);
				half	atten	= LIGHT_ATTENUATION(i);

				//> 提取法向量并计算高光反射
				half3	vNormal	= normalize(UnpackNormal(bumpTex));
				half3	vH		= normalize(viewDir + lightDir);
				half	NdotL	= dot(vH, vNormal) * 0.5 + 0.5;
				half	spec	= pow( NdotL, _SpecWidth * 128 ) * _SpecIntensity;

				//> 表面反射
				half	fDiff	= dot(lightDir, vNormal);
				fDiff = fDiff * 0.5 + 0.5;

                half4 c;
				c.rgb	= (diffTex.rgb * _LightColor0.rgb * fDiff) + (specTex.rgb * spec * _SpecularColor.rgb) * (atten * 2);

				c.rgb	+= _PreferColor.rgb;
				c.rgb	*= i.vertClr.rgb;
				c.a		= diffTex.a;

				//> Alpha cutoff
				if ( c.a < _AlphaCutoff )
				{
					//> yes: discard this fragment
					discard;
				}

				//> NOTE: need alpha
				c += ProcessColorMask(viewDir, vNormal, i.uv);

				return c;
			}

            ENDCG
        }
    }
    
    Fallback "Diffuse"

}