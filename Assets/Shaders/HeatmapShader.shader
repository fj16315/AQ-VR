// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/HeatmapShader"
{
    Properties
    {
        
    }
    SubShader
    {
        Tags { "Queue"="Transparent" }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f
            {
                float3 worldPos : TEXCOORD1;
                float4 vertex : SV_POSITION;
			};

            v2f vert(appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                return o;
			}

            float4 _LightColor0;

            int _SensorsNo;
            float4 _SensorsPos [30];
            float _SensorsIntensities [30];
            float _SensorRadius;
            float _SensorMin;
            float _SensorMax;

            float convertIntensity(float intensity)
            {
                float oldRange = _SensorMax - _SensorMin;
                float newIntensity = (intensity - _SensorMin) / oldRange;
                return newIntensity;
			}

            float getIntensity(float3 worldPos)
            {
                float h = 0;

                for (int i = 0; i < _SensorsNo; i++)
                {
                    float dist = distance(worldPos, _SensorsPos[i].xyz);
                    float hi = 1 - saturate(dist / _SensorRadius);
                    float newIntensity = saturate(convertIntensity(_SensorsIntensities[i]));

                    h += hi * newIntensity;
				}
                h = saturate(h);

                return h;     
			}

            fixed4 frag(v2f i) : SV_TARGET
            {
                float intensity = getIntensity(i.worldPos);

                fixed4 colour = fixed4(0.0, 0.0, 0.0, 1.0);
                colour.x = intensity;
                colour.z = (1 - intensity);
                //colour.z = intensity;
                //colour = (1 - intensity);
                colour.a = 0.95;
                return colour;
			}

            ENDCG
		}
    }
}
