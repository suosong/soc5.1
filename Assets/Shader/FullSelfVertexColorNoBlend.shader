Shader "VertexColor/FullSelfNoBlend"
{
    Properties 
    {
     _MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}    
    }
    
    SubShader 
    {
      Tags{"IgnoreProjector" = "True" "Queue" = "Geometry"}
      
      LOD 300
      ZWrite On
      Lighting Off
      Cull Back
      
      CGPROGRAM
      #pragma surface surf BasicDiffuse vertex:vert noforwardadd 
       
      sampler2D _MainTex;
      
      uniform float Uani;
      uniform float Vani;     
      
      struct Input 
      {
        float2 MTex;
        float4 vertColor;      
      };
      
      void vert(inout appdata_full v, out Input o)    
      {    
            o.vertColor = v.color;    
            o.MTex=float2(v.texcoord.x+Uani,v.texcoord.y+Vani);            
      } 
      
      void surf (Input IN, inout SurfaceOutput o) 
      {   
       o.Albedo =tex2D(_MainTex, IN.MTex).rgb*IN.vertColor;
       o.Alpha = 1.0f;
      }     
      
      inline float4 LightingBasicDiffuse (SurfaceOutput s, float3 lightDir, float atten)  
      {  
       float4 c;  
       c.rgb = s.Albedo;  
       c.a = 1.0f;  
       return c;  
      }
      ENDCG     
     }
}
