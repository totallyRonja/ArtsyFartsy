Shader "Unlit/Waves"
{
	Properties
	{
		[PerRendererData]_MainTex ("Texture", 2D) = "white" {}
        _Variables("rotation size (xy) and speed (w)", Vector) = (1, 1, 0, 1)
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" "disablebatching"="True"}
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
		LOD 100
                    Cull Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
                float4 color : COLOR;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
                float4 color : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _Variables;


            //get a scalar random value from a 3d value
            float rand3dTo1d(float3 value, float3 dotDir = float3(12.9898, 78.233, 37.719)){
                //make value smaller to avoid artefacts
                float3 smallValue = cos(value);
                //get scalar value from 3d vector
                float random = dot(smallValue, dotDir);
                //make value more random by making it bigger and then taking the factional part
                random = frac(sin(random) * 143758.5453);
                return random;
            }

            float3 rand3dTo3d(float3 value){
                return float3(
                    rand3dTo1d(value, float3(12.989, 78.233, 37.719)),
                    rand3dTo1d(value, float3(39.346, 11.135, 83.155)),
                    rand3dTo1d(value, float3(73.156, 52.235, 09.151))
                );
            }
			
			v2f vert (appdata v)
			{
				v2f o;
                float3 baseWorldPos = unity_ObjectToWorld._m03_m13_m23;
                float random = rand3dTo1d(baseWorldPos.xyz);
                float time = _Time.y * _Variables.w - random * 124.6234;
				o.vertex = UnityObjectToClipPos((v.vertex * lerp(0.7, 2, random) + float4(sin(time) * _Variables.x, cos(time) * _Variables.y, 0, 0)));
				o.uv = v.uv;
                o.color = v.color;
                float3 col = rand3dTo3d(baseWorldPos);
                o.color.rgb *= lerp(0.7, 1.1, col);
				return o;
			}
			
			fixed4 frag (v2f IN) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, IN.uv) * IN.color;

				return col;
			}
			ENDCG
		}
	}
}
