Shader "VertexColor/PlayerShader"
{
	Properties
	{
		_MainTex ("Base (RGB), Alpha (A)", 2D) = "white" {} 
	    _MainColor ("Base (RGB) Color", Color) = (0,0,0,0)
        Lighty("Vertex Lighty", float) =1  
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
		
		Pass
		{
		    Cull Off
		    Lighting Off
		    ZWrite on

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
	
			struct appdata_t
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};
	
			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 texcoord : TEXCOORD0;
				float4 color    : TEXCOORD1;				
			};
	
			sampler2D _MainTex;		
			half4 _MainColor;
		    float Lighty;
		    
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
			    o.texcoord = v.texcoord;
			    o.color=_MainColor*Lighty;
				return o;
			}
			
			fixed4 frag (v2f i) : COLOR
			{
				float4 col = tex2D(_MainTex, i.texcoord) ;
				col.rgb*=i.color;
				return col;
			}
			ENDCG
		}
	}

}
