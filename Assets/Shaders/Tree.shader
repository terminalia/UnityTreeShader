Shader "Mistwork/Tree" {
    Properties {
        [HDR]
        _Color ("Main Color", Color) = (1,1,1,1)
        _MainTex ("Leaves texture", 2D) = "white" {}
        _Cutoff ("Alpha cutoff", Range(0,1)) = 0.3
        _TurbulenceTex("Turbulence texture", 2D) = "black" {}
        _TurbulenceAmount("Turbulence amount", Float) = 0
        _TurbulenceSpeed("Turbulence speed", Float) = 0

        [Header(Swaying)]
        _WindSpeed("Wind speed", Range(0,50)) = 25
        _SwayingRigidness("Swaying rigidness", Range(1,50)) = 25 
        _SwayMax("Sway Max", Range(0, 5)) = .05 
        _YOffset("Y offset", float) = 0.0
    }

    SubShader {
        Tags { "IgnoreProjector"="True" "RenderType"="TreeLeaf" }
        LOD 200

        CGPROGRAM
        #pragma surface surf TreeLeaf alphatest:_Cutoff vertex:vert addshadow nolightmap noforwardadd
        #include "UnityBuiltin3xTreeLibrary.cginc"

        sampler2D _MainTex;
       
        float _WindSpeed;
        float _SwayingRigidness;
        float _SwayMax;
        float _YOffset;

        sampler2D _TurbulenceTex;
        float _TurbulenceAmount;
        float _TurbulenceSpeed;

        struct Input {
            float2 uv_MainTex;
            float2 uv_TurbulenceTex;
        };

        //Swaying function
        void wind_force(inout appdata_full v, float3 v_world)
        {
            //To make leaves and trunks swaying back and forth, use sin function
            //_SwayingRigidness -> lower value makes the swaying look "liquid"
            float x = sin(v_world.x / _SwayingRigidness + (_Time.x * _WindSpeed)) * (v.vertex.y - _YOffset);
			float z = sin(v_world.z / _SwayingRigidness + (_Time.x * _WindSpeed)) * (v.vertex.y - _YOffset);
			
            //Sway only vertices of y values > _YOffset. Use _SwayMax to adjust the amount of swaying
            v.vertex.x += (step(0,v.vertex.y - _YOffset) * x * _SwayMax);
			v.vertex.z += (step(0,v.vertex.y - _YOffset) * z * _SwayMax);
        }

        void vert(inout appdata_full v)
        {
            float3 vertex_world_pos = mul(unity_ObjectToWorld, v.vertex).xyz;
            //Apply swaying to every vertice
            wind_force(v, v.vertex.xyz);
        }

        void surf (Input IN, inout LeafSurfaceOutput o) 
        {
            //Sample the turbulence texture and convert its values to the range [-1, 1]. 
            float2 turbulenceTex =  (tex2D(_TurbulenceTex, IN.uv_TurbulenceTex + _Time.y * _TurbulenceSpeed).xy * 2.0 - 1.0) * _TurbulenceAmount;
            //Sample leavesTex and use turbulenceTex to animate leavesTex UVs
            float4 leavesTex = tex2D(_MainTex, IN.uv_MainTex + turbulenceTex);
            
            o.Albedo = leavesTex * _Color;
            o.Alpha = leavesTex.a;
            
        }
        ENDCG
    }

    Dependency "OptimizedShader" = "Hidden/Nature/Tree Creator Leaves Optimized"
    FallBack "Diffuse"
}