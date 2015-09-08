Shader "VertexColor/MutilLayerColor"
{
  Properties 
  {
	_MainTex ("Base (RGB), Alpha (A)", 2D) =   "" {}

    _Layer0  ("_Layer0", 2D)   = "white" {}
	_Layer1  ("_Layer1", 2D)   = "white" {}

    _TileRepeat0 ("Tiling Repeat0", Range(0,50)) = 10
    _TileRepeat1 ("Tiling Repeat1", Range(0,50)) = 10
  }

  SubShader
  {
	Tags{"SplatCount" = "3" "IgnoreProjector" = "True" "Queue" = "Geometry-200"}
	
	LOD 300
	ZWrite on
    Lighting Off    
    Cull Back
    
    CGPROGRAM
    #pragma surface surf Lambert vertex:vert noforwardadd 
   
    sampler2D _MainTex;
    sampler2D _Layer0,_Layer1;
    half _TileRepeat0,_TileRepeat1;
    
    struct Input 
    {   
      float2 MTex0;
      float2 MTex1;      
    };
    
    void vert(inout appdata_full v, out Input o)
    {
      o.MTex0=float2(v.texcoord.x,v.texcoord.y);
      o.MTex1=float2(v.texcoord.x,v.texcoord.y);
    }
    
    void surf (Input IN, inout SurfaceOutput o)
    {
     half4 col;
     half4 splat_control= tex2D(_MainTex, IN.MTex0);
     
     col.rgb   = splat_control.a* tex2D (_Layer0, IN.MTex0*_TileRepeat0).rgb;
     col.rgb  += (1.0f-splat_control.a)* tex2D (_Layer1, IN.MTex0*_TileRepeat1).rgb;
     col.rgb  *=  splat_control.rgb*1.6f;
          
     o.Albedo = col.rgb;
     o.Alpha = 1.0f;
    }

    ENDCG  
  }
}
