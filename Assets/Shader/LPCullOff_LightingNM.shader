Shader "VertexColor/LpCullOff_LightingNM"
{
	Properties
	{
		_MainTex	("Base (RGB) Trans (A)", 2D)	= "white"	{}
		_LightMap	("Ltmp (RGB), Alpha (A)", 2D)	= "white"	{}
		_BumpMap	("Bump (RGB) Bumpmap", 2D)		= "bump"	{}

		_Cutoff		("Alpha cutoff", Range(0,1)) = 0.5
		_LightPower ("Light Power", Range(0,3)) = 1

		//> 高光
		_SpecIntensity	("Spec Intensity", Range(0.01, 1)) = 0.5
		_SpecWidth		("Spec Width", Range(0, 1)) = 0.2
		_Specular		("Spec Color", Color)		= (0.8, 0.8, 0.8, 1.0)
	}
	
	SubShader
	{
		Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
		LOD 300
		
		Cull		Off
		Lighting	Off
		ZWrite		On
		Alphatest	Greater [_Cutoff]

		CGPROGRAM
		#pragma surface surf BasicDiffuse vertex:vert halfasview noforwardadd


		sampler2D	_MainTex;
		sampler2D	_LightMap;
		sampler2D	_BumpMap;

		float		_LightPower;
		half		_SpecIntensity;
		half		_SpecWidth;
		half4		_Specular;

		struct Input 
		{
			float2 MTex;
			float2 uv2_LightMap;
		};



		void vert(inout appdata_full v, out Input o)
		{
			o.MTex=float2(v.texcoord.x,v.texcoord.y);
		}

		void surf (Input IN, inout SurfaceOutput o) 
		{
			float4 Col=tex2D(_MainTex, IN.MTex);
			o.Albedo =Col.rgb * tex2D (_LightMap, IN.uv2_LightMap).rgb*_LightPower;
			o.Alpha = Col.a;

			//> 法线图
			//> -----------------------------------------------------------------
			o.Normal	= UnpackNormal( tex2D (_BumpMap, IN.MTex) );
			o.Gloss		= _SpecIntensity;
			o.Specular	= _SpecWidth;
		}

		inline float4 LightingBasicDiffuse (SurfaceOutput s, float3 lightDir, float3 viewDir, float atten)
		{
			half3	halfVec = normalize( lightDir + viewDir );
			half	NdotL	= dot( s.Normal, halfVec );
			half	diff	= NdotL * 0.5 + 0.5;

			fixed	spec = pow( diff, s.Specular * 128 ) * s.Gloss;

			half4 c;
			c.rgb	= (s.Albedo * _LightColor0.rgb + spec * _Specular.rgb) * (diff * atten * 2);
			c.a		= s.Alpha;

			return c;
		}

		ENDCG
	}

	Fallback "Diffuse"
}
