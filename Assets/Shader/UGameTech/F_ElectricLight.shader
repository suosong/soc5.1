
//> 透明通道图颜色mask以黑色为主，算法中的色值默认为0 + 调节任意即可
//> ---------------------------------------------------------------------
Shader "UGameTech/F_ElectricLight"
{
	Properties
	{
        _BaseTex 	("Base Texture(None by alpha)", 2D)	= 	"black" {}
        _GradientTex("Gradient Tex", 2D)				=	"black"	{}
		_ElectricSpd("Electric Speed", Float)			=	0.7
		_ElectricPow("Electric Power", Range(0.0, 3.0))	=	2.0
		_ElectricClr("Electric Color", Color)			=	(0,0,0,1)
	}


    SubShader
	{
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

				sampler2D	_BaseTex;
				sampler2D 	_GradientTex;
				float4		_BaseTex_ST;
				float4		_GradientTex_ST;
				
				float		_ElectricSpd;
				float		_ElectricPow;
				float4		_ElectricClr;

				struct v2f
				{
					float4 	pos 	: POSITION;
					float2	uv 		: TEXCOORD0;
					float3	viewDir	: TEXCOORD1;
					float3	normal 	: TEXCOORD2;
				};

				v2f vert(appdata_base v)
				{
					v2f o;
					o.pos 		= mul( UNITY_MATRIX_MVP, v.vertex );
					o.uv 		= TRANSFORM_TEX( v.texcoord, _BaseTex );
					o.viewDir	= ObjSpaceViewDir(v.vertex);
					o.normal	= v.normal;
					//> Note: what's uv for null first texture  ...

					return o;
				}

				half4 frag(v2f i) : COLOR
				{
					_ElectricSpd	=	_Time * 10.0;//_ElectricSpd.xxxx;
					//> half4	Tex2D2		=	tex2D( _GradientTex, half2(IN.uv_MainTex.x, IN.uv_MainTex.y + Multiply3.x) );

					half4	orginalCol	=	tex2D( _BaseTex, i.uv );
					half4	gradientCol	=	tex2D( _GradientTex, half2(i.uv.x, i.uv.y + _ElectricSpd) );

					half4	Fresnel0	=	(1.0 - dot( normalize(i.viewDir), i.normal )).xxxx;
					half4	Multiply2	=	gradientCol * pow( Fresnel0, _ElectricPow.xxxx ) * _ElectricClr; //> not multiply

					half4	col;
					col.rgb = orginalCol.rgb + (Multiply2.rgb * _ElectricClr.a);
					col.a	= gradientCol.a;

					return col;
				}
			ENDCG
		}
	}
}