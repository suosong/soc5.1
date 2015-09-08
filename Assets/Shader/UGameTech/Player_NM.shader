Shader "UGameTech/Player_NM"
{
	Properties 
	{
		_MainTex	("Base (RGB) Trans (A)", 2D)= "white"	{}
		_BumpMap	("Bump (RGB) Bumpmap", 2D)	= "bump"	{}

		_CullOff	("Alpha Cull Off", Float)				= 0.9
		_LightPower ("Light Power", Float)					= 0.8

		//> 高光
		_SpecTex		("Spec (RGB)",			2D)			= "white"	{}
		_SpecIntensity	("Spec Intensity", Range(0.01, 1))	= 0.85
		_SpecWidth		("Spec Width", Range(0, 1))			= 0.25
		_Specular		("Spec Color", Color)				= (0.8, 0.8, 0.8, 1.0)

		//> [add by Cool_J]
		//> 效果相关的属性
		//> -----------------------------------------------------------------
		//> 叠色
		_ColorEff 	("Additive Color", Color) 				= (0,0,0,0)

		//> 电流
		_GradientTex("Gradient Tex", 2D)				= "black"	{}
		_ElectricSpd("Electric Speed", Float)			= 0.7
		_ElectricClr("Electric Color", Color)			= (0,0,0,1)
		_ElectricPow("Electric Power", Range(0.0, 3.0))	= 2.0
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

		sampler2D		_SpecTex;
		half			_SpecIntensity;
		half			_SpecWidth;
		half4			_Specular;

		//> 效果相关的属性
		//> -----------------------------------------------------------------

		//> 叠色
		half4			_ColorEff;

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
			o.Emission		=	Multiply2.rgb * _ElectricClr.a;
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
			o.Specular	= _SpecWidth;// * tex2D( _SpecTex, IN.uv_MainTex);

			//> 叠色效果
			//> -----------------------------------------------------------------
			o.Albedo	+= _ColorEff.rgb;

			//> 电流效果
			//> -----------------------------------------------------------------
			//> Too many math instructions for SM2.0 (72 needed, max is 64).
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

			c.a = s.Alpha;

			return c;
		}

		ENDCG
	} 

	Fallback "Diffuse"
}
