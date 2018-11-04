Shader "Custom/CloudMaterial" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		
		[PowerSlider(4)] _FresnelExponent ("Fresnel Exponent", Range(0.25, 4)) = 1
		_FresnelMult("fresnel multiplier", Range(0,2)) = 1
		_InvFade("depth fade", Range(0.001,5)) = 1
	}
	SubShader {
		

		Tags { "RenderType"="Transparent" "Queue"="Transparent"}
		LOD 200
		Blend SrcAlpha OneMinusSrcAlpha

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard vertex:vert fullforwardshadows alpha:fade nolightmap

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0
		#include "Random.cginc"

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
			float3 worldNormal;
			float3 viewDir;
			float4 screenPos;
			float eyeDepth;
			float3 worldPos;
		};

		fixed4 _Color;

		float _FresnelExponent;
		sampler2D _CameraDepthTexture;
		float _InvFade;
		float _FresnelMult;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		float fresnel(float3 worldNormal, float3 viewDir){
			float fresnel = dot(worldNormal, viewDir);
			fresnel = saturate(fresnel);
			return saturate(pow(fresnel, _FresnelExponent) * _FresnelMult);
		}

		float depthFade(float4 screenPos, float eyeDepth){
			float rawZ = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(screenPos));
            float sceneZ = LinearEyeDepth(rawZ);
            float partZ = eyeDepth;
			float fade = saturate (_InvFade * (sceneZ-partZ));
			return fade;
		}

		float easeIn(float interpolator){
			return interpolator * interpolator;
		}

		float easeOut(float interpolator){
			return 1 - easeIn(1 - interpolator);
		}

		float easeInOut(float interpolator){
			float easeInValue = easeIn(interpolator);
			float easeOutValue = easeOut(interpolator);
			return lerp(easeInValue, easeOutValue, interpolator);
		}

		float3 ValueNoise3d(float3 value){
			float interpolatorX = easeInOut(frac(value.x));
			float interpolatorY = easeInOut(frac(value.y));
			float interpolatorZ = easeInOut(frac(value.z));

			float3 cellNoiseZ[2];
			[unroll]
			for(int z=0;z<=1;z++){
				float3 cellNoiseY[2];
				[unroll]
				for(int y=0;y<=1;y++){
					float3 cellNoiseX[2];
					[unroll]
					for(int x=0;x<=1;x++){
						float3 cell = floor(value) + float3(x, y, z);
						cellNoiseX[x] = rand3dTo3d(cell);
					}
					cellNoiseY[y] = lerp(cellNoiseX[0], cellNoiseX[1], interpolatorX);
				}
				cellNoiseZ[z] = lerp(cellNoiseY[0], cellNoiseY[1], interpolatorY);
			}
			float3 noise = lerp(cellNoiseZ[0], cellNoiseZ[1], interpolatorZ);
			return noise;
		}

		void vert (inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            COMPUTE_EYEDEPTH(o.eyeDepth);
        }

		void surf (Input i, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed3 c = ValueNoise3d(i.worldPos * 0.5) * _Color.rgb;
			o.Albedo = c;
			
			o.Alpha = fresnel(i.worldNormal, i.viewDir) * depthFade(i.screenPos, i.eyeDepth);
		}
		ENDCG
	}
	FallBack "Diffuse"
}
