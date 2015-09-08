Shader "VertexColor/LPBlend"
{
    Properties 
    {
     _MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
     _LightMap ("Light Map", 2D) = "white" {} 
     _LightPower ("Light Power", Range(0,3)) = 1       
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
       o.Albedo =Col.rgb * tex2D (_LightMap, IN.uv2_LightMap).rgb*_LightPower;
       o.Alpha = Col.a;
      }        
     
      inline float4 LightingBasicDiffuse (SurfaceOutput s, float3 lightDir, float atten)  
      {  
       float diff = max (0, dot (s.Normal, lightDir));  
                
       float4 c;  
       c.rgb = s.Albedo * _LightColor0.rgb* (diff * atten * 2); 
       c.a = s.Alpha;
       return c;  
      }      
      ENDCG     
     }
}
