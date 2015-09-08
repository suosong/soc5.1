Shader "UGameTech/BackgroundClouds"
{
    Properties 
    {
		_MainTex	("Base (RGB) Trans (A)", 2D)= "white" {}
		_CloudsClr	("Clouds Color", Color)		= (1,1,1,1)
		_LightPower ("Light Power", Float)				= 1
		_AlphaBlend ("Alpha Blend", Range(0,1))			= 1
		_UVOffsetX	("UVAnim Offset X", Float)			= 0
		_UVOffsetY	("UVAnim Offset Y", Float)			= 0
    }

    SubShader
    {
		Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType"="Transparent" }
		LOD 		300
		ZWrite 		On
		Lighting 	Off
		Cull 		Back
		Blend		SrcAlpha	OneMinusSrcAlpha

		CGPROGRAM

		#pragma surface surf BasicDiffuse vertex:vert

		struct Input
		{
			float2 	uv_MainTex;
			float4 	VertColor;
			float3	ViewDir;
		};


		sampler2D 		_MainTex;
		half4			_CloudsClr;
		half 			_LightPower;
		half			_AlphaBlend;
		half			_UVOffsetX;
		half			_UVOffsetY;


		void vert(inout appdata_full v, out Input o)    
		{
			o.uv_MainTex= float2( v.texcoord.x, v.texcoord.y );
			o.VertColor = v.color; //+ clamp(pow(rim, 6.0f),0.0f,1.0f);
			o.ViewDir	= normalize( float3( float4( _WorldSpaceCameraPos.xyz, 1.0) - mul(_Object2World, v.vertex).xyz ) );
		} 

		void surf (Input IN, inout SurfaceOutput o) 
		{
			//> float4 fCol = tex2D(_MainTex, float2(IN.uv_MainTex.x+_UVOffsetX*_Time.x, IN.uv_MainTex.y+_UVOffsetY*_Time.x));
			float4 fCol = tex2D(_MainTex, float2(IN.uv_MainTex.x+_UVOffsetX, IN.uv_MainTex.y+_UVOffsetY));
			o.Albedo= fCol.rgb * IN.VertColor * _LightPower;
			o.Alpha = fCol.a;
		}

		//> 最终受光照色彩影响的计算在这里进行，将surf中计算好的数据应用
		//> -----------------------------------------------------------------
		inline float4 LightingBasicDiffuse (SurfaceOutput s, float3 lightDir, float atten)  
		{
			half NdotL = dot (s.Normal, lightDir);
			half diff = NdotL * 0.5 + 0.5;

			half4 c;
			c.rgb = s.Albedo * _CloudsClr.rgb * (diff * atten * 2);
			c.a = s.Alpha * _AlphaBlend;
			return c;
		}

		ENDCG     
	}

	Fallback "Diffuse"
}
