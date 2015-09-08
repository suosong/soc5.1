Shader "VertexColor/PlayerDiffuse_Normal"
{
	Properties 
	{
		_MainTex	("Base (RGB) Trans (A)", 2D)= "white"	{}
		_BumpMap	("Bump (RGB) Bumpmap", 2D)	= "bump"	{}

		_LightPower ("Light Power", Float) = 1
		//> _AlphaBlend ("Alpha Blend", Range(0,1)) = 1

		//> 高光
		_SpecIntensity	("Spec Intensity", Range(0.01, 1)) = 0.85
		_SpecWidth		("Spec Width", Range(0, 1)) = 0.2
		_Specular		("Spec Color", Color)		= (0.8, 0.8, 0.8, 1.0)

		//> [add by Cool_J]
		//> 效果相关的属性
		//> -----------------------------------------------------------------
		//> 边缘光
		_RimColor	("Rim Color", Color)				= (0.57,0.57,0.56,0.0)
		_RimPower	("Rim Power", Range(0.6,9.0))		= 3.5
		_RimScalar	("Rim Scalar", Range(0.0,1.0))		= 0.65

		//> 叠色
		_ColorEff 	("Additive Color", Color) 			= (0,0,0,0)

		//> 溶解
		_DissolveTex("Dissolve(RGB)", 2D) 				= "white" {}
		_Burn		("Burn Amount", Range(-0.25, 1.25)) = 1.0
		_LineWidth	("Burn Line Size", Range(0.0, 0.2)) = 0.1
		_BurnColor	("Burn Color", Color) 				= (1.0, 0.0, 0.0, 1.0)

		//> 电流
		_GradientTex("Gradient Tex", 2D)				= "black"	{}
		_ElectricSpd("Electric Speed", Float)			= 0.7
		_ElectricClr("Electric Color", Color)			= (0,0,0,1)
		_ElectricPow("Electric Power", Range(0.0, 3.0))	= 2.0

		_CullOff	("Alpha Cull Off", Float)			= 0.9
	}


	SubShader 
	{
		//> Tags { "RenderType" = "Opaque" }
		//> Tags { "Queue" = "Transparent" "IgnoreProjector" = "False" "RenderType"="Transparent" }
		Tags { "RenderType" = "Opaque" }

		LOD 		300

		Cull 		Off
		ZWrite 		On
		Lighting 	Off

		//ZTest		LEqual
		//ColorMask	RGBA

		//> Alphatest	Greater		[_CullOff]
		//> Blend		SrcAlpha	OneMinusSrcAlpha

		CGPROGRAM

		#pragma surface surf BasicDiffuse vertex:vert halfasview alphatest:_CullOff

		struct Input 
		{
			half2	uv_MainTex;
			half4 	vertColor;
			half3	viewDir;
		};


		//> 变量声明
		//> -----------------------------------------------------------------
		sampler2D		_MainTex;
		sampler2D		_BumpMap;
		half 			_LightPower;
		//> half			_AlphaBlend;

		half			_SpecIntensity;
		half			_SpecWidth;
		half4			_Specular;

		//> 效果相关的属性
		//> -----------------------------------------------------------------
		//> 边缘光
		half4			_RimColor;
		half			_RimPower;
		half			_RimScalar;

		//> 叠色
		half4			_ColorEff;

		//> 溶解
		sampler2D		_DissolveTex;
		half			_Burn;
		half			_LineWidth;
		half4			_BurnColor;

		//> 电流
		sampler2D		_GradientTex;
		half			_ElectricSpd;
		half4			_ElectricClr;
		half			_ElectricPow;


		void vert(inout appdata_full v, out Input o)    
		{
			UNITY_INITIALIZE_OUTPUT( Input, o )

			o.uv_MainTex= float2( v.texcoord.x, v.texcoord.y );
			o.vertColor = v.color * _LightPower;
			o.viewDir	= normalize( float3( float4( _WorldSpaceCameraPos.xyz, 1.0).xyz - mul(_Object2World, v.vertex).xyz ) ); 
			/*
			half rim	= 1.0f - saturate( dot(normalize(ObjSpaceViewDir(v.vertex)), v.normal) );
			o.rimColor	= _RimColor * pow(rim, _RimPower) * _RimScalar;
			*/
		} 


		//int		ProcessBurnBlend()
		//> 溶解效果
		//> -----------------------------------------------------------------
		void	ProcessDissolve( Input IN, inout SurfaceOutput o )
		//> void	ProcessDissolve( Input IN, inout half3 color, inout half alpha )
		{
			half4	burnColor	= tex2D( _DissolveTex, IN.uv_MainTex );
			half4	clear		= half4(0.0, 0.0, 0.0, 0.0);

			int		burnBlendR	= burnColor.r - (_Burn+_LineWidth) + 0.99;
			int		burnBlendT	= burnColor.r - _Burn + 0.99;

			clear		=	lerp( _BurnColor,	clear,		burnBlendR );
			o.Albedo	=	lerp( o.Albedo,		clear.rgb,	burnBlendT );
			o.Alpha		*=	lerp( 1.0,			0.0,		burnBlendR );
		}


		//> 电流效果
		//> -----------------------------------------------------------------
		void	ProcessElectricRim( Input IN, inout SurfaceOutput o )
		{
			half4	Fresnel0	=	(1.0 - dot( normalize(IN.viewDir), o.Normal )).xxxx;

			//> float4	Fresnel0	=	(1.0 - dot( IN.viewDir, o.Normal )).xxxx;
			/*
			//> for test
			half4	Multiply3	=	_Time * 10.0;//_ElectricSpd.xxxx;
			half4	Tex2D2		=	tex2D( _GradientTex, half2(IN.uv_MainTex.x, IN.uv_MainTex.y + Multiply3.x) );
			*/

			half4	Tex2D2		=	tex2D( _GradientTex, half2(IN.uv_MainTex.x, IN.uv_MainTex.y + _ElectricSpd) );
			half4	Multiply2	=	Tex2D2 * pow( Fresnel0, _ElectricPow.xxxx ) * _ElectricClr;

			//> 电流 + 边缘光颜色
			//> -----------------------------------------------------------------
			o.Emission		+=	Multiply2.rgb;	//> + IN.rimColor.rgb;
		}


		//> 表面着色函数
		void surf (Input IN, inout SurfaceOutput o) 
		{
			//> 基础纹理着色
			half4 fCol	= tex2D( _MainTex, IN.uv_MainTex );
			o.Albedo	= fCol.rgb * IN.vertColor.rgb;
			o.Alpha		= fCol.a;

			//> 法线图
			//> -----------------------------------------------------------------
			o.Normal	= UnpackNormal( tex2D (_BumpMap, IN.uv_MainTex) );
			o.Gloss		= _SpecIntensity;
			o.Specular	= _SpecWidth;

			//> 边缘光颜色
			o.Emission	= half3(0.0, 0.0, 0.0);
			/*
			half rim = 1.0 - saturate( dot( IN.viewDir, o.Normal ) );
			o.Emission = _RimColor.rgb * pow( rim, _RimPower ) * _RimScalar;
			*/

			//> 叠色效果
			//> -----------------------------------------------------------------
			o.Albedo	+= _ColorEff.rgb;

			//> 溶解效果
			//> -----------------------------------------------------------------
			//> ProcessDissolve( IN, o );
			
			//> 电流效果，IP6上会导致破损？
			//> ------------------------------------------------------------------
			//> ProcessElectricRim( IN, o );
		}


		inline float4 LightingBasicDiffuse (SurfaceOutput s, float3 lightDir, float3 viewDir, float atten)  
		{
			/*
				half3	h		= normalize( lightDir + viewDir );
				half	nh		= max( 0, dot( s.Normal, h ) );
				half	diff	= max( 0, dot( lightDir, s.Normal ) );

				half	spec	= pow( nh, s.Specular * 128.0 );

				half4	res;
				res.rgb	= _LightColor0.rgb * diff;
				res.w	= spec * Luminance( _LightColor0.rgb );
				res		*= atten * 2.0;

				half3	specular= res.a * s.Gloss;

				half4	c;
				c.rgb	=	(s.Albedo * res.rgb + res.rgb * specular ) * s.Alpha;
				c.a		=	s.Alpha * _AlphaBlend;
			*/ 

			half3	halfVec = normalize( lightDir + viewDir );
			half	NdotL	= dot( s.Normal, halfVec );
			half	diff	= NdotL * 0.5 + 0.5;
			half	spec	= pow( diff, s.Specular * 128 ) * s.Gloss;

			half4 c;
			c.rgb = (s.Albedo * _LightColor0.rgb + spec * _Specular.rgb) * (diff * atten * 2);

			//> c.rgb = s.Albedo * _LightColor0.rgb * (diff * atten * 2);
			//> c.rgb = (s.Albedo * NdotL * _LightColor0.rgb) + (spec * (/*finalSpecMask * */_FresnelColor)) * (atten * 2);

			//> c.a = s.Alpha * _AlphaBlend;
			c.a = s.Alpha;

			return c;
		}

		ENDCG
	} 

	Fallback "Diffuse"
}
