
//> Fragment shader for object with diffuse & normal & specular
//> Referenced follow:
//> http://wiki.unity3d.com/index.php/BumpColorSpec this is not working correctly
//> http://www.cnblogs.com/yaukey/archive/2013/06/16/unity_bump_mapping_shader.html
//> http://blog.csdn.net/candycat1992/article/details/40212735
//> -----------------------------------------------------------------

//> Support: Diffuse, Normal, Specular, LightPower, AlphaCutoff, Electric;
//> -----------------------------------------------------------------

Shader "UGameTech/F_Player_N"
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

		_GradientTex("Gradient Tex", 2D)					= "black"	{}
		_GradientPow("Gradient Power", Float)				= 1.0
		_ElectricSpd("Electric Speed", Float)				= 0.7
		_ElectricPow("Electric Power", Range(0.0, 3.0))		= 2.0
		_ElectricClr("Electric Color", Color)				= (0,0,0,0)
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

			sampler2D 	_GradientTex;
			half		_GradientPow;
			half		_ElectricSpd;
			half		_ElectricPow;
			half4		_ElectricClr;


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

			float4	ProcessElectric( float3 viewDir, float3 normal, float2 uv )
			{
				float4 fResult;

				//> for test
				//_ElectricSpd	=	_Time * 10.0;

				half4	gradientCol	=	tex2D( _GradientTex, half2(uv.x, uv.y + _ElectricSpd) );

				half4	Fresnel0	=	(1.0 - dot(viewDir, normal)).xxxx;
				half4	Multiply2	=	gradientCol * pow( Fresnel0, _ElectricPow.xxxx ) * _ElectricClr;

				fResult.rgb = (Multiply2.rgb * _ElectricClr.a) * _GradientPow;
				fResult.a	= gradientCol.a;

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
				c += ProcessElectric(viewDir, vNormal, i.uv);

				return c;
			}


			//> No use codes
			//> -----------------------------------------------------------------
			//> Fragment modal 1
			/*
			float4 frag(v2f i) : COLOR0
			{
				float3	viewDir  = normalize(i.viewDir);
				float3	lightDir = normalize(i.lightDir);

				//> float3 normalDir = normalize(normalMap * 2.0 - 1.0);
				float4	normalMap = tex2D(_BumpTex, i.uv);
				float3	normalDir = normalize(UnpackNormal(normalMap));

				float	s	= max(0, dot(lightDir, normalDir));
				fixed3	h	= normalize(viewDir + lightDir);
				float	r	= max(0, dot(h, normalDir));
                //> float	spec= pow(r, 48.0);
				float	spec= pow( r, _SpecWidth * 128 ) * _SpecIntensity;

				half4	clr		= tex2D(_MainTex, i.uv);
                half4	specclr = tex2D(_SpecTex, i.uv);

                float4 c;
				c.rgb	= ((_Ambient + _Diffuse * s) * clr.rgb + spec * _Specular.rgb * specclr.rgb * clr.a * 1.5) * 1.3;
				c.a		= clr.a * specclr.a;

				//> c.rgb = ((_Ambient + _Diffuse * s) * clr.rgb + spec * _Specular.rgb * clr.a * 1.5) * 1.3;
				//> c.a   = clr.a;
				return c;
            }
			*/

			//> Fragment modal 2
			/*
			float4 frag(v2f i) : COLOR0
			{
				float3	viewDir  = normalize(i.viewDir);
				float3	lightDir = normalize(i.lightDir);

				float4	normalMap	= tex2D(_BumpTex, i.uv);
				float3	normalDir	= normalize(UnpackNormal(normalMap));
				float4	texclr		= tex2D(_MainTex, i.uv);
				float4	specclr		= tex2D(_SpecTex, i.uv);

				half3 h = normalize( lightDir + viewDir );
    
				half diffuse = dot( normalDir, lightDir );

				float nh = saturate( dot( h, normalDir ) );
				float spec = pow( nh, _SpecWidth * 128 ) * _SpecIntensity;

				half4 c;
				c.rgb = (texclr.rgb * diffuse + _LightColor0.rgb * specclr.rgb * spec) * (LIGHT_ATTENUATION(i) * 2);
				c.a = _LightColor0.a * specclr.a * spec * LIGHT_ATTENUATION(i); // specular passes by default put highlights to overbright
				return c;
			}
			*/

            ENDCG
        }
    }
    
    Fallback "Diffuse"

}