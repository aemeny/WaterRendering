Shader "Unlit/WaterShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        [Space(20)][Header(Lighting Model Properties)][Space] 
        _AmbientColour("Ambient Colour", Color) = (0.1, 0.1, 0.1, 1)
        _DiffuseColour("Diffuse Colour", Color) = (0.7, 0.7, 0.7, 1)
        _SpecularColour("Specular Colour", Color) = (1, 1, 1, 1)
        _Shininess("Shininess", Range(1, 128)) = 32

        [Space(20)][Header(Water Properties)][Space] 
        _WaterColour("Water Colour", Color) = (0, 0.329, 0.466, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            // Define constants
            #define TWO_PI 6.28318530718

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
                float3 normal : TEXCOORD2;
                float3 viewDir : TEXCOORD3;
            };

            // Texture properties
            sampler2D _MainTex;
            float4 _MainTex_ST;

            // Lighting properties
            uniform float4 _AmbientColour;
            uniform float4 _DiffuseColour;
            uniform float4 _SpecularColour;
            uniform float _Shininess;

            // Water properties
            uniform float4 _WaterColour;

            // Wave parameters
            uniform int _NumWaves;
            uniform float4 _Waves[10];          // Amplitude, Wavelength, Speed, PhaseShift
            uniform float4 _WaveDirections[10];  // Wave directions (x, y)

            // Function to compute the wave height
            float waveHeight(float x, float z)
            {
                float height = 0.0;
                float t = _Time.y;

                // Loop through each wave
                for (int i = 0; i < _NumWaves; i++)
                {
                    float amplitude = _Waves[i].x;
                    float wavelength = _Waves[i].y;
                    float speed = _Waves[i].z;
                    float phaseShift = _Waves[i].w;

                    float2 direction = float2(_WaveDirections[i].x, _WaveDirections[i].y);

                    // Precompute the angular frequency (omega)
                    float omega = TWO_PI / wavelength;
                    float phase = (x * direction.x + z * direction.y) * omega + t * speed + phaseShift;

                    // Add the wave contribution to the total height
                    height += amplitude * exp(sin(phase) - 1.0) * cos(phase);
                }

                return height;
            }

            // Vertex shader
            v2f vert(appdata v)
            {
                v2f o;

                // Apply wave displacement
                float height = waveHeight(v.vertex.x, v.vertex.z);
                v.vertex.y += height;

                // Compute normal direction
                float offset = 0.01;
                float h_dx = waveHeight(v.vertex.x + offset, v.vertex.z);
                float h_dz = waveHeight(v.vertex.x, v.vertex.z + offset);

                float3 dx = float3(1, (h_dx - height) / offset, 0);
                float3 dz = float3(0, (h_dz - height) / offset, 1);
                float3 normal = normalize(cross(dx, dz));

                // World position
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                // Pass the normal
                o.normal = normal;

                // Compute view direction
                o.viewDir = normalize(_WorldSpaceCameraPos - o.worldPos);

                // Transform vertex position
                o.vertex = UnityObjectToClipPos(v.vertex);

                // Pass UV coords
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            // Fragment shader
            fixed4 frag(v2f i) : SV_Target
            {
                // Normalize interpolated normal and view direction 
                float3 normal = normalize(i.normal);
                float3 viewDir = normalize(i.viewDir);

                // Light direction
                float3 lightDir = normalize(float3(-1, -1, 1)); 

                // Half vector
                float3 halfDir = normalize(lightDir + viewDir);

                // Ambient light
                float3 ambient = _AmbientColour.rgb;

                // Lambertian diffuse
                float NdotL = max(0, dot(normal, lightDir));
                float3 diffuse = _DiffuseColour.rgb * NdotL;

                // Specular light
                float NdotH = max(0, dot(normal, halfDir));
                float3 specular = _SpecularColour.rgb * pow(NdotH, _Shininess);

                // Combine lighting effects
                float3 finalColour = (ambient + diffuse + specular) * _WaterColour.rgb;

                // Sample the texture
                fixed4 texColor = tex2D(_MainTex, i.uv);

                // Return final output color
                return float4(finalColour, texColor.a);
            }
            ENDCG
        }
    }
}
