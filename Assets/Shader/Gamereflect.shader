Shader "VertexColor/Gamereflect" 
{
   Properties 
   {
      _MainTex("BaseMap", 2D) = "white" {}    
      environmentMap("Environment Map", Cube) = "" {}
      reflectivity("reflectivity1", float) =1
      LightyAni("Vertex Lighty", float) =1        
   }
   
   SubShader
   {
	  LOD 300

	  Lighting Off
	  ZWrite on
	  
      Pass
      {
		   CGPROGRAM
		   #pragma vertex vert
		   #pragma fragment frag
		   #include "UnityCG.cginc"
		   
           sampler2D _MainTex; 
           samplerCUBE environmentMap;

           float reflectivity;
           float LightyAni;
       
           struct appdata_t
           {
               float4 pos:POSITION;
               float2 tex:TEXCOORD0;
			   float4 col:COLOR;
               float3 nor:NORMAL;               
           };
           
           struct v2f
           {
               float4 pos:SV_POSITION;
               float2 tex:TEXCOORD0;
               float3 ref:TEXCOORD1;
			   float4 col:TEXCOORD2;	               
           };


           
           v2f vert(appdata_t v)
           {
              v2f o;
              o.pos=mul(UNITY_MATRIX_MVP,v.pos);
              o.tex=v.tex;
              
              float3 I=mul(_Object2World,v.pos).xyz-_WorldSpaceCameraPos;              
              float3 N=normalize(mul((float3x3)_Object2World,v.nor));
              o.ref=reflect(I,N);
              o.col = v.col*LightyAni;              
              return o;
           }
           
           float4 frag(v2f i):COLOR
           {
              float4 reflectionColor=texCUBE(environmentMap,i.ref);
              float4 BaseMapColor=tex2D(_MainTex,i.tex.xy*LightyAni);
              
              return lerp(BaseMapColor,reflectionColor,reflectivity)*i.col;
           }
           ENDCG
       }
   }
}