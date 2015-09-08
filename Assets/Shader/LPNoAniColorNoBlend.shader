Shader "VertexColor/LPNoAniNoBlend"
{
	Properties
	{
		_MainTex ("Base (RGB), Alpha (A)", 2D) = "white" {}
		_LpTex ("Base (RGB), Alpha (A)", 2D) = "white" {}		
        LightyAni ("Alpha cutoff", Range(0,3)) = 1.3		
	}

	SubShader
	{
		LOD 300

		Tags
		{
			"Queue" = "Geometry-100"
			"IgnoreProjector" = "True"
			"RenderType" = "Opaque"
		}
		
		Lighting Off
		ZWrite on
		
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			sampler2D _LpTex;
			float  LightyAni;
                   
			struct appdata_t
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				float2 texcoordLp : TEXCOORD1;		
			};

			struct v2f
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				float2 texcoordLp : TEXCOORD1;				
			};

			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
			    o.texcoord   = v.texcoord;
				o.texcoordLp = v.texcoordLp;
				return o;
			}

			half4 frag (v2f IN) : COLOR
			{
				float4 col = tex2D(_MainTex, IN.texcoord) * (tex2D(_LpTex, IN.texcoordLp)*LightyAni);		
				return col;
			}
			ENDCG
		}
	}
	
}
