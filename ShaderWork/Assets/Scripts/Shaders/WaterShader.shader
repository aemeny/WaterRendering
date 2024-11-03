Shader "Custom/WaterShader"
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
        Tags { 
            "LightMode" = "ForwardBase" 
        }

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

            struct dummyV
            {
                float4 vertex : INTERNALTESSPOS;
                float2 uv : TEXCOORD0;
                float4 colour : COLOR;
                float3 normal : NORMAL;
            };

            // Texture properties
            sampler2D _MainTex;
            float4 _MainTex_ST;
            samplerCUBE _ReflectionTex;

            // Lighting properties
            uniform float4 _AmbientColour;
            uniform float4 _DiffuseColour;
            uniform float4 _SpecularColour;
            uniform float _Shininess;

            // Water properties
            uniform float4 _WaterColour;

            // Wave parameters
            uniform int _NumWaves;
            uniform float4 _Waves[64];          // Amplitude, Wavelength, Speed, PhaseShift
            uniform float4 _WaveDirections[64];  // Wave directions (x, y)

            // Function to compute the final wave height
            float waveHeight(float x, float z, out float2 derivative)
            {
                float height = 0.0;
                float t = _Time.y;

                float amplitudeMul = 0.8;
                float frequency = 1.0;

               derivative = float2(0.0, 0.0);
               float2 previousDerivative = float2(0.0, 0.0);

               // Loop through each wave
               for (int i = 0; i < _NumWaves; i++)
               {
                   float speed = _Waves[i].z;
                   float amplitude = _Waves[i].x * amplitudeMul;
                   float waveLength = _Waves[i].y;
                   float2 direction = float2(_WaveDirections[i].x, _WaveDirections[i].y);

                   // Precompute the angular frequency and phase
                   float omega = (2 / waveLength) * frequency;
                   float phase = ((x + previousDerivative.x) * direction.x + (z + previousDerivative.y) * direction.y) * omega + t * speed;
                   float exponent = exp(sin(phase) - 1.0);

                   // Compute wave height using fBM
                   height += amplitude * exponent;

                   // Compute partial derivatives (with respect to x and z)
                   float waveDerivative = omega * amplitude * exponent * cos(phase);

                   derivative.x += (waveDerivative * direction.x);
                   derivative.y += (waveDerivative * direction.y);

                   // Decrease amplitude and increase frequency for the next wave
                   amplitudeMul *= 0.82;
                   frequency *= 1.18;
                   previousDerivative = derivative;
               }

               return height;
            }

            // Vertex shader
            v2f vert(appdata v)
            {
                v2f o;

                // Apply wave displacement
                float2 derivative;
                float height = waveHeight(v.vertex.x, v.vertex.z, derivative);
                v.vertex.y += height;

                // Compute normal direction
                o.normal = normalize(float3(-derivative.x, 1.0, -derivative.y));

                // World position
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

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
                float3 lightDir = normalize(float3(-0.6, 0.8, 0.2)); 

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

                // Fresnel
                float3 reflectedDir = reflect(-viewDir, normal);
                float4 reflectedColour = texCUBE(_ReflectionTex, reflectedDir);
                float fresnel = pow(1.0 - max(0.0, dot(viewDir, normal)), 3.0);
                finalColour = lerp(finalColour, reflectedColour.rgb, fresnel);

                // Sample the texture
                fixed4 texColor = tex2D(_MainTex, i.uv);

                // Return final output color
                //return float4(specular, texColor.a);
                return float4(finalColour, texColor.a);
            }
            ENDCG
        }
    }
}