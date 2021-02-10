Shader "Raymarching/ShadingRaymarchig"
{
    Properties
    {
        _Radius ("Radius", Range(0.0, 1.0)) = 0.3
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "LightMode"="ForwardBase" }
        LOD 100

        Pass
        {
            ZWrite On
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            //Use LightingLibrary
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : POSITION1;
                float4 vertex : SV_POSITION;
            };

            float _Radius;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.pos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = v.uv;
                return o;
            }

            float sphere(float3 pos){
                return length(pos) - _Radius;
            }

            float3 getNormal(float3 pos) {
                float d = 0.001;
                return normalize(float3(
                    sphere(pos + float3(d, 0, 0)) - sphere(pos + float3(-d, 0, 0)),
                    sphere(pos + float3(0, d, 0)) - sphere(pos + float3(0, -d, 0)),
                    sphere(pos + float3(0, 0, d)) - sphere(pos + float3(0, 0, -d))
                ));
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 pos = i.pos.xyz;
                float3 rayDir = normalize(pos.xyz - _WorldSpaceCameraPos);

                int StepNum = 30;

                for(int i = 0; i < StepNum; i++){
                    float marchingDist = sphere(pos);

                    if(marchingDist < 0.001){
                        float3 lightDir = _WorldSpaceLightPos0.xyz;
                        float3 normal = getNormal(pos);
                        float3 lightColor = _LightColor0;

                        fixed4 col = fixed4(lightColor * max(dot(normal, lightDir), 0) , 1.0);
                        col.rgb += fixed3(0.2f, 0.2f, 0.2f);

                        return col;
                    }

                    pos.xyz += rayDir * marchingDist;
                }

                return 0;
            }
            ENDCG
        }
    }
}
