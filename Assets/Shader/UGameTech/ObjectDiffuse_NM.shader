Shader "UGameTech/ObjectDiffuse_NM"
{
	Properties 
	{
		_MainTex		("Base (RGB) Trans (A)",2D)	= "white"	{}
		_BumpMap		("Bump (RGB) Bumpmap",	2D)	= "bump"	{}
		_SpecTex		("Spec (RGB)",			2D) = "white"	{}

		_LightPower		("Light Power", Float) = 1
		_Cutoff			("Alpha CutOff", Float) = 0.2

		//> 高光
		_SpecIntensity	("Spec Intensity", Range(0.01, 1)) = 0.85
		_SpecWidth		("Spec Width", Range(0, 1)) = 0.2

		//> 电流
		_GradientTex	("Gradient Tex", 2D)				= "black"	{}
		_ElectricSpd	("Electric Speed", Float)			= 0.7
		_ElectricClr	("Electric Color", Color)			= (0,0,0,1)
		_ElectricPow	("Electric Power", Range(0.0, 3.0))	= 2.0
	}


	SubShader 
	{
		//> Tags { "RenderType" = "Opaque" }
		//> Tags { "Queue" = "Transparent" "IgnoreProjector" = "False" "RenderType"="Transparent" }
		Tags { "RenderType"="Opaque" }

		LOD 		300

		Cull 		Back
		ZWrite 		On
		Lighting 	Off
		//> Alphatest	Greater		[_Cutoff]
		//> Blend		SrcAlpha	OneMinusSrcAlpha

		CGPROGRAM

		#pragma surface surf BasicDiffuse vertex:vert halfasview alphatest:_Cutoff

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
		sampler2D		_SpecTex;

		half 			_LightPower;

		half			_SpecIntensity;
		half			_SpecWidth;

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
			half4	Multiply3	=	_Time * _ElectricSpd.xxxx;
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
			o.Specular	= _SpecWidth * tex2D( _SpecTex, IN.uv_MainTex).rgb;

			//> 电流效果
			//> -----------------------------------------------------------------
			//> Too many math instructions for SM2.0 (72 needed, max is 64).
			//> ProcessElectricRim( IN, o );
		}


		inline float4 LightingBasicDiffuse (SurfaceOutput s, float3 lightDir, float3 viewDir, float atten)  
		{
			half3	halfVec = normalize( lightDir + viewDir );
			half	NdotL	= dot( s.Normal, halfVec );
			half	diff	= NdotL * 0.5 + 0.5;
			half	spec	= pow( diff, s.Specular * 128 ) * s.Gloss;

			half4 c;
			c.rgb = (s.Albedo * _LightColor0.rgb * spec) * (diff * atten * 2);

			c.a = s.Alpha;

			return c;
		}

		ENDCG
	} 

	Fallback "Diffuse"
}
