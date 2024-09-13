// Upgrade NOTE: commented out 'float3 _WorldSpaceCameraPos', a built-in variable

Shader "Unlit/WaterShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        [Space(20)][Header(Lighting Model Properties)][Space] _AmbientColour("Ambient Colour", color) = (0.1, 0.1, 0.1, 1)
        _DiffuseColour("Diffuse Colour", color) = (0.7, 0.7, 0.7, 1)
        _SpecularColour("Specular Colour", color) = (1, 1, 1, 1)
        _Shininess("Shininess", Range(1, 128)) = 32

        [Space(20)][Header(Water Properties)][Space] _WaterColour("Water Colour", color) = (0, 0.329, 0.466, 1)

        [Space(20)][Header(First Wave)][Space] _Amplitude1("Amplitude", Range(0, 3)) = 1
        _WaveLength1("WaveLength", Range(0, 10)) = 2
        _Speed1("Speed", Range(0, 10)) = 1

        [Header(Second Wave)][Space] _Amplitude2("Amplitude", Range(0, 3)) = 1
        _WaveLength2("WaveLength", Range(0, 10)) = 2
        _Speed2("Speed", Range(0, 10)) = 1

        [Header(Third Wave)][Space] _Amplitude3("Amplitude", Range(0, 3)) = 1
        _WaveLength3("WaveLength", Range(0, 10)) = 2
        _Speed3("Speed", Range(0, 10)) = 1

        [Header(Fourth Wave)][Space] _Amplitude4("Amplitude", Range(0, 3)) = 1
        _WaveLength4("WaveLength", Range(0, 10)) = 2
        _Speed4("Speed", Range(0, 10)) = 1
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

            // Define PI constant
            #define TWO_PI 6.28318530718 // 2 * PI to avoid recalculating it

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
                float3 normal : TEXCOORD2; // Pass normal from vertex to fragment
                float3 viewDir : TEXCOORD3; // camera view direction
            };

            //Texture properties
            sampler2D _MainTex;
            float4 _MainTex_ST;

            // Lighting properties
            float4 _AmbientColour;
            float4 _DiffuseColour;
            float4 _SpecularColour;
            float _Shininess;

            //Water properties
            float4 _WaterColour;
            float _Amplitude1, _Amplitude2, _Amplitude3, _Amplitude4;   
            float _WaveLength1, _WaveLength2, _WaveLength3, _WaveLength4; 
            float _Speed1, _Speed2, _Speed3, _Speed4;


            // Function to compute the wave height
            float waveHeight(float x, float z)
            {
                return _Amplitude1 * sin(TWO_PI / _WaveLength1 * x + _Time.y * _Speed1) +  // Wave moving along x-axis
                       _Amplitude2 * sin(TWO_PI / _WaveLength2 * z + _Time.y * _Speed2) +  // Wave moving along z-axis
                       _Amplitude3 * sin(TWO_PI / _WaveLength3 * (x + z) + _Time.y * _Speed3) + // Diagonal wave
                       _Amplitude4 * sin(TWO_PI / _WaveLength4 * (x - z) + _Time.y * _Speed4);  // Opposite diagonal wave
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

                // Light direction (overhead light for testing)
                float3 lightDir = normalize(float3(-1, -1, 1)); 

                // Half vector
                float3 halfDir = normalize(lightDir + viewDir);

                // Ambience
                float3 ambient = _AmbientColour.rgb;

                // Lambertian diffuse
                float NdotL = max(0, dot(normal, lightDir));
                float3 diffuse = _DiffuseColour.rgb * NdotL;

                // Specular
                float NdotH  = max(0, dot(i.normal, halfDir));
                float3 specular = _SpecularColour.rgb * pow(NdotH, _Shininess);

                // Combine effects
                float3 finalColour = (ambient + diffuse + specular) * _WaterColour;

                // Sample the texture
                fixed4 texColor = tex2D(_MainTex, i.uv);

                // Final output
                return float4(finalColour, texColor.a);
            }
            ENDCG
        }
    }
}
