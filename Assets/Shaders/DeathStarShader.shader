Shader "Custom/DeathStarShader"
{
    SubShader
    {
        Tags { "Queue" = "Transparent" }

        Pass
        {
              Blend SrcAlpha OneMinusSrcAlpha

              CGPROGRAM

              #pragma vertex vert
              #pragma fragment frag

              #include "UnityCG.cginc"

              struct v2f
              {
                    float2 uv : TEXCOORD0;
                    float4 vertex : SV_POSITION;
			  };

              v2f vert(appdata_base v)
              {
                    v2f o;
                    
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = v.texcoord;

                    return o;
			  }

              float3 _CamPos;
              float3 _CamRight;
              float3 _CamUp;
              float3 _CamForward;
              float3 _StarPos;
              float4 _LightColor0;

              float getDistanceSphere(float sphereRadius, float3 circleCenter, float3 rayPos)
              {
                    float distance = length(rayPos - circleCenter) - sphereRadius;
                    return distance;
			  }

              float getDistanceBox(float3 boxSize, float3 boxCenter, float3 rayPos)
              {
                    return length(max(abs(rayPos - boxCenter) - boxSize, 0.0));     
			  }

              float distFunc(float3 pos)
              {
                    const float starRadius = 50.0;
                    const float3 cutOutBoxSize = float3(starRadius, starRadius, starRadius);
                    const float distanceBetweenHalf = 0.5;

                    float3 starPosTop = _StarPos + float3(0.0, distanceBetweenHalf, 0.0);
                    float starDistanceTop = getDistanceSphere(starRadius, starPosTop, pos);
                    float3 cutOutPosTop = starPosTop + float3(0.0, starRadius, 0.0);
                    float cutOutDistanceTop = getDistanceBox(cutOutBoxSize, cutOutPosTop, pos);

                    float3 starPosBottom = _StarPos + float3(0.0, -distanceBetweenHalf, 0.0);
                    float starDistanceBottom = getDistanceSphere(starRadius, starPosBottom, pos);
                    float3 cutOutPosBottom = starPosBottom + float3(0.0, -starRadius, 0.0);
                    float cutOutDistanceBottom = getDistanceBox(cutOutBoxSize, cutOutPosBottom, pos);

                    float starBodyDist = min(max(starDistanceTop, cutOutDistanceTop), max(starDistanceBottom, cutOutDistanceBottom));
                    const float cutOutRadius = starRadius * 0.3;
                    float3 cutOutPos = _StarPos + float3(0.0, starRadius / 2.0, 0.0);
                    float3 centerDir = normalize(-_StarPos);
                    centerDir.y = 0;
                    cutOutPos += starRadius * centerDir;
                    float cutOutDistance = getDistanceSphere(cutOutRadius, cutOutPos, pos);

                    return max(starBodyDist, -cutOutDistance);
			  }

              fixed4 getColor(float3 pos, fixed3 color)
              {
                         const fixed2 eps = fixed2(0.00, 0.02);
                         fixed3 normal = normalize(float3(distFunc(pos + eps.yxx) - distFunc(pos - eps.yxx), distFunc(pos + eps.xyx) - distFunc(pos - eps.xyx), distFunc(pos + eps.xxy) - distFunc(pos - eps.xxy)));
                         fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                         fixed3 diffuse = _LightColor0.rgb * max(dot(lightDir, normal), 0.0);
                         fixed3 finalLight = diffuse + (UNITY_LIGHTMODEL_AMBIENT.xyz * 2.0);
                         color *= finalLight;
                         float distance = length(pos - _CamPos);
                         fixed fogDensity = 0.1;
                         const fixed3 fogColor = fixed3(0.8, 0.8, 0.8);
                         float f = exp(-distance * fogDensity);
                         color = (fogColor * (1.0 - f)) + (color * f);
                         fixed4 finalColor = fixed4(color, 1.0);
                         finalColor.a *= max(dot(lightDir, normal) * 1.0, 0.0);
                         return finalColor;
			  }

              fixed4 getColorFromRaymarch(float3 pos, float3 ray)
              {
                    fixed4 color = 0;
                    
                    for (int i = 0; i < 64; i++)
                    {
                        float d = distFunc(pos);
                        if (d < 0.005)
                        {
                            color = getColor(pos, fixed3(0.7, 0.7, 0.7));
                            break;
						}

                        if (d > 400.0)
                        {
                            break;              
						}

                        pos += ray * d * 0.5;
					}

                    return color;
			  }

              fixed4 frag(v2f i) : SV_Target
              {
                    float2 uv = i.uv * 2.0 - 1.0;
                    float3 startPos = _CamPos;
                    fixed focalLength = 0.62;
                    fixed3 ray = normalize(_CamUp * uv.y + _CamRight * uv.x + _CamForward * focalLength);
                    fixed4 color = getColorFromRaymarch(startPos, ray);

                    return color;
			  }

              ENDCG
		}
    }
}
