Shader "Unlit/Clouds"
{
	Properties
	{
		[PerRendererData]_MainTex ("Texture", 2D) = "white" {}
        _TextureScaling ("Texture Scaling", Vector) = (1,1,0,0)
        _BaseColor ("Base Color", Color) = (1,1,1,0)
        _CloudColor ("Cloud Color", Color) = (1,1,1,1)
        _Parallax ("Parallax", Range(0, 2)) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
		LOD 100

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
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _TextureScaling;

            float4 _BaseColor;
            float4 _CloudColor;
            float _Parallax;

            float4 _People[10];
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
                float3 baseWorldPos = unity_ObjectToWorld._m03_m13_m23;
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
                float2 uv = worldPos.xy - baseWorldPos.xy * _Parallax;
				o.uv = uv * _TextureScaling.xy + _TextureScaling.zw;
                o.worldPos = worldPos;
				return o;
			}
			
			fixed4 frag (v2f IN) : SV_Target
			{
                float dist = 9999;
                [unroll(10)]
                for(uint i=0;i<10;i++){
                    float newDist = distance(IN.worldPos.xy, _People[i].xy);
                    dist = min(dist, newDist);
                }

				// sample the texture
				fixed4 col = tex2D(_MainTex, IN.uv);
                col = lerp(_BaseColor, _CloudColor, col.a);
                col.a *= smoothstep(4, 15, dist);

				return col;
			}
			ENDCG
		}
	}
}
