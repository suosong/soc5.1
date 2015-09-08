
//> Support: Diffuse, LightPower, AlphaBlend, DiffuseClr;
//> -----------------------------------------------------------------

Shader "UGameTech/F_Background_A"
{
    Properties 
    {
		_MainTex	("Base (RGB) Trans (A)", 2D)= "white" {}
		_LightPower ("Light Power", Float)				= 1
		_AlphaBlend ("Alpha Blend", Range(0,1))			= 1
		_DiffuseClr	("Diffuse Clr", Color)				= (1,1,1,1)
		_UVOffsetX	("UVAnim Offset X", Float)			= 0
		_UVOffsetY	("UVAnim Offset Y", Float)			= 0
    }

    SubShader
    {
		Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType"="Transparent" }
		LOD		300

		Pass
		{
			Cull 		Back
			ZWrite 		On
			Lighting 	Off
			Blend		SrcAlpha	OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex			vert
			#pragma fragment		frag
			#pragma fragmentoption	ARB_precision_hint_fastest
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			sampler2D 		_MainTex;      
			half 			_LightPower;
			half			_AlphaBlend;
			half4			_DiffuseClr;
			half			_UVOffsetX;
			half			_UVOffsetY;

			//> Fragment input struction
			//> -----------------------------------------------------------------
			struct v2f
			{
				float4	pos		: SV_POSITION;
				float2	uv		: TEXCOORD0;
				float3	viewDir	: TEXCOORD1;
				float4	vertClr	: TEXCOORD2;
			};


			v2f vert (appdata_full v)
			{
				v2f o;
				o.pos		= mul(UNITY_MATRIX_MVP, v.vertex);
			    o.uv		= v.texcoord;
				o.vertClr	= v.color;
				o.viewDir	= normalize( float3( float4( _WorldSpaceCameraPos.xyz, 1.0) - mul(_Object2World, v.vertex).xyz ) );

				//> 顶点光照
				half3 lightDir = ObjSpaceLightDir(v.vertex);
				half NdotL = max(0, dot( v.normal, lightDir));
				half diff = NdotL * 0.5 + 0.5;
				half atten	= LIGHT_ATTENUATION(o);

				o.vertClr = v.color * (diff * atten * 2);

				return o;
			}

			//> Fragment Program
			//> -----------------------------------------------------------------
			float4 frag(v2f i) : SV_Target
			{
				half4 fCol = tex2D(_MainTex, float2(i.uv.x+_UVOffsetX, i.uv.y+_UVOffsetY));

				half4 c;
				c.rgb = fCol.rgb * i.vertClr * _DiffuseClr * _LightColor0.rgb * _LightPower;
				c.a = fCol.a * _AlphaBlend;

				return c;
			}

			ENDCG
		}

		//> 妹的，5.0写的surface里用半透明会失效？
		/*
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
			float4 	vertColor;
			float3	viewDir;
		};


		sampler2D 		_MainTex;      
		half 			_LightPower;
		half			_AlphaBlend;
		half4			_DiffuseClr;
		half			_UVOffsetX;
		half			_UVOffsetY;

		void vert(inout appdata_full v, out Input o)    
		{
			o.uv_MainTex= float2( v.texcoord.x, v.texcoord.y );
			o.vertColor = v.color; //+ clamp(pow(rim, 6.0f),0.0f,1.0f);
			o.viewDir	= normalize( float3( float4( _WorldSpaceCameraPos.xyz, 1.0) - mul(_Object2World, v.vertex).xyz ) );
		} 

		void surf (Input IN, inout SurfaceOutput o) 
		{
			//> float4 fCol = tex2D(_MainTex, float2(IN.uv_MainTex.x+_UVOffsetX*_Time.x, IN.uv_MainTex.y+_UVOffsetY*_Time.x));
			float4 fCol = tex2D(_MainTex, float2(IN.uv_MainTex.x+_UVOffsetX, IN.uv_MainTex.y+_UVOffsetY));
			o.Albedo= fCol.rgb * IN.vertColor * _DiffuseClr * _LightPower;
			o.Alpha = fCol.a;
		}

		//> 最终受光照色彩影响的计算在这里进行，将surf中计算好的数据应用
		//> -----------------------------------------------------------------
		inline float4 LightingBasicDiffuse (SurfaceOutput s, float3 lightDir, float atten)  
		{
			half NdotL = dot (s.Normal, lightDir);
			half diff = NdotL * 0.5 + 0.5;

			//float diff = max (0, dot (s.Normal, lightDir));  

			half4 c;
			c.rgb = s.Albedo * _LightColor0.rgb * (diff * atten * 2);
			c.a = s.Alpha * _AlphaBlend;
			return c;
		}

		ENDCG
		*/
	}

	Fallback "Diffuse"
}
