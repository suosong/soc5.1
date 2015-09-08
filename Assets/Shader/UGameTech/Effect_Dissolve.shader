Shader "UGameTech/Effect_Dissolve"
{
	Properties 
	{
		_MainTex	("Base (RGB) Trans (A)", 2D)= "white"	{}

		//> 溶解
		_DissolveTex("Dissolve(RGB)", 2D) 				= "white" {}
		_Burn		("Burn Amount", Range(-0.25, 1.25)) = 1.0
		_LineWidth	("Burn Line Size", Range(0.0, 0.2)) = 0.1
		_BurnColor	("Burn Color", Color) 				= (1.0, 0.0, 0.0, 1.0)
	}


	SubShader 
	{
		//> Tags { "RenderType" = "Opaque" }
		Tags { "Queue" = "Transparent" "IgnoreProjector" = "False" "RenderType"="Transparent" }

		LOD 		300

		ZWrite 		On
		Lighting 	Off

		Blend		SrcAlpha	OneMinusSrcAlpha

		CGPROGRAM

		#pragma surface surf Lambert vertex:vert halfasview

		struct Input 
		{
			half2	uv_MainTex;
			half4 	vertColor;
			half3	viewDir;
		};


		//> 变量声明
		//> -----------------------------------------------------------------
		sampler2D		_MainTex;

		//> 溶解
		sampler2D		_DissolveTex;
		half			_Burn;
		half			_LineWidth;
		half4			_BurnColor;


		void vert(inout appdata_full v, out Input o)    
		{
			UNITY_INITIALIZE_OUTPUT( Input, o )

			o.uv_MainTex= float2( v.texcoord.x, v.texcoord.y );
			o.vertColor = v.color;
			o.viewDir	= normalize( float3( float4( _WorldSpaceCameraPos.xyz, 1.0).xyz - mul(_Object2World, v.vertex).xyz ) ); 
		} 


		//int		ProcessBurnBlend()
		//> 溶解效果
		//> -----------------------------------------------------------------
		void	ProcessDissolve( Input IN, inout SurfaceOutput o )
		{
			half4	burnColor	= tex2D( _DissolveTex, IN.uv_MainTex );
			half4	clear		= half4(0.0, 0.0, 0.0, 0.0);

			int		burnBlendR	= burnColor.r - (_Burn+_LineWidth) + 0.99;
			int		burnBlendT	= burnColor.r - _Burn + 0.99;

			clear		=	lerp( _BurnColor,	clear,		max(0.0, burnBlendR) );
			o.Albedo	=	lerp( o.Albedo,		clear.rgb,	max(0.0, burnBlendT) );
			o.Alpha		*=	lerp( 1.0,			0.0,		burnBlendR );
		}


		//> 表面着色函数
		void surf (Input IN, inout SurfaceOutput o) 
		{
			//> 基础纹理着色
			half4 fCol	= tex2D( _MainTex, IN.uv_MainTex );
			o.Albedo	= fCol.rgb * IN.vertColor.rgb;
			o.Alpha		= fCol.a;

			//> 溶解效果
			//> -----------------------------------------------------------------
			ProcessDissolve( IN, o );
		}

		ENDCG
	} 

	Fallback "Diffuse"
}
