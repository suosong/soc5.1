Shader "VertexColor/SelfLPBlend"
{
    Properties 
    {
     _MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
     _LightMap ("Light Map", 2D) = "white" {}      
    }
    
    SubShader 
    {
      Tags{"IgnoreProjector" = "True" "Queue" = "Geometry" "RenderType" = "Transparent"}

      Cull Off
      Lighting Off
      ZWrite off
      Blend SrcAlpha OneMinusSrcAlpha
      
      CGPROGRAM
      #pragma surface surf BasicDiffuse vertex:vert noforwardadd  
      
      float _LightPower;    
      sampler2D _MainTex;
      sampler2D _LightMap;
      
      uniform float Uani;
      uniform float Vani;     
      
      struct Input 
      {
        float2 MTex;
        float2 uv2_LightMap;        
      };

      void vert(inout appdata_full v, out Input o)    
      {    
            o.MTex=float2(v.texcoord.x+Uani,v.texcoord.y+Vani);                 
      } 
      
      void surf (Input IN, inout SurfaceOutput o) 
      {         
       float4 Col=tex2D(_MainTex, IN.MTex);
       o.Albedo =Col.rgb * tex2D (_LightMap, IN.uv2_LightMap).rgb;
       o.Alpha = Col.a;
      }        
     
      inline float4 LightingBasicDiffuse (SurfaceOutput s, float3 lightDir, float atten)  
      {  
       float4 c;  
       c.rgb = s.Albedo*_LightColor0.rgb;  
       c.a = s.Alpha;
       return c;  
      }      
      ENDCG     
     }
}
