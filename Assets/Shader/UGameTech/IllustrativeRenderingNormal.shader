Shader "UGameTech/IllustrativeRenderingNormal"
{
	Properties
	{
		_MainTex		("Base (RGB)", 2D)		= "white" {}
		_NormalTex		("Normal Texture", 2D)	= "white" {}
		_RampTex		("Ramp Texture", 2D)	= "white" {}
		_SpecularMask	("Specular Mask", 2D)	= "white" {}
		_Specular		("Speculr Exponent", Range(0.1, 128)) = 128
		_RimMask		("Rim Mask", 2D)		= "white" {}
		_Rim			("Rim Exponent", Range(0.1, 8)) = 1
	}


	SubShader
	{
		Pass
		{
			Name "FORWARD"
			Tags { "LightMode" = "ForwardBase" }
		
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			sampler2D	_MainTex;
			sampler2D	_NormalTex;
			sampler2D	_RampTex;
			sampler2D	_SpecularMask;
			float		_Specular;
			sampler2D	_RimMask;
			float		_Rim;
			
			float4		_MainTex_ST;
			float4		_NormalTex_ST;
			float4		_SpecularMask_ST;
			float4		_RimMask_ST;
			
			struct v2f
			{
				float4	position	: SV_POSITION;
				float2	uv0			: TEXCOORD0;
  				float2	uv1			: TEXCOORD1;
  				float2	uv2			: TEXCOORD2;
  				float2	uv3			: TEXCOORD3;
  				float3	viewDir		: TEXCOORD4;
  				float3	lightDir	: TEXCOORD5;
  				float3	up			: TEXCOORD6;
			};


			v2f vert(appdata_full v)
			{
				v2f o;
  				o.position = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv0 = TRANSFORM_TEX (v.texcoord, _MainTex); 
				o.uv1 = TRANSFORM_TEX (v.texcoord, _NormalTex); 
				o.uv2 = TRANSFORM_TEX (v.texcoord, _SpecularMask); 
				o.uv3 = TRANSFORM_TEX (v.texcoord, _RimMask); 

				TANGENT_SPACE_ROTATION;
 	 			float3 lightDir = mul (rotation, ObjSpaceLightDir(v.vertex));
 	 			o.lightDir = normalize(lightDir);
				
				float3 viewDirForLight = mul (rotation, ObjSpaceViewDir(v.vertex));
  				o.viewDir = normalize(viewDirForLight);
  				
  				o.up = mul(rotation, float3(mul(_World2Object, half4(0, 1, 0, 0))));
				
				//> pass lighting information to pixel shader
				TRANSFER_VERTEX_TO_FRAGMENT(o);
				return o;
			}


			fixed4 frag (v2f i) : COLOR
			{
				half3 normal = UnpackNormal(tex2D (_NormalTex, i.uv1)); 
				
				// Compute View Independent Lighting Terms
				half3 k = tex2D( _MainTex, i.uv0).rgb;
				
				half difLight = dot (normal, i.lightDir);
				half halfLambert = pow(0.5 * difLight + 0.5, 1);
				
				half3 ramp = tex2D(_RampTex, float2(halfLambert)).rgb;
				half3 difWarping = ramp * 2; // Or difWarping = ramp * 2;
				
				half3 difLightTerm = _LightColor0.rgb * difWarping; 
				
				half3 dirLightTerm = 0;
				
				half3 viewIndependentLightTerms = k * (dirLightTerm + difLightTerm);
				
				// Compute View Dependent Lighting Terms
				half3 r = reflect(i.lightDir, normal);
				half3 refl = dot(i.viewDir, r);
				half fresnelForSpecular = 1; // Just for example
				half fresnelForRim = pow(1 - dot(normal, i.viewDir), 4);
				
				half3 kS = tex2D( _SpecularMask, i.uv2).rgb;
				half3 multiplePhongTerms =  _LightColor0.rgb * kS * max(fresnelForSpecular * pow(refl, _Specular), fresnelForRim * pow(refl, _Rim));
				
				half3 kR = tex2D( _RimMask, i.uv3).rgb;
				half3 aV = float(1);
				half3 dedicatedRimLighting = dot(normal, i.up) * fresnelForRim * kR * aV;
				half3 viewDependentLightTerms = multiplePhongTerms + dedicatedRimLighting;
	       	  	
	       	  	// Compute the final color
	       	  	float4 col;
	       	  	col.rgb = viewIndependentLightTerms + viewDependentLightTerms;
	       	  	col.a = 1.0;
	       	  	
	       	  	return col;
			}

			ENDCG
		}
	}
	
	FallBack "Diffuse"
}
