using UnityEditor;
using UnityEngine;
using static UnityEngine.UI.Image;

public class WaveController : MonoBehaviour
{
    public Material waterMaterial;
    private Wave[] waves;
    private int maxWaves = 32;

    // Procedural Settings
    [Space]
    [Header("|--------- Procedural Settings ---------|")]
    [Space]
    [Range(1.0f, 32.0f)]
    [SerializeField] int waveCount;
    [Header("Wave Length")]
    [Range(0.1f, 16.0f)]
    [SerializeField] float medianWavelength;
    [Range(0.1f, 16.0f)]
    [SerializeField] float wavelengthRange;
    [Header("Wave Direction")]
    [Range(-20.0f, 20.0f)]
    [SerializeField] float medianDirection;
    [Range(0.0f, 60.0f)]
    [SerializeField] float directionalRange;
    [Header("Wave Amplitude")]
    [Range(0.1f, 3.0f)]
    [SerializeField] float medianAmplitude;
    [Header("Wave Speed")]
    [Range(0.1f, 10.0f)]
    [SerializeField] float medianSpeed;
    [Range(0.01f, 10.0f)]
    [SerializeField] float speedRange;
    [Header("Wave Steepness (NOT IN USE)")]
    [Range(0.0f, 10.0f)]
    [SerializeField] float steepness;

    //float halfPlaneWidth = planeLength * 0.5f;
    //Vector3 minPoint = transform.TransformPoint(new Vector3(-halfPlaneWidth, 0.0f, -halfPlaneWidth));
    //Vector3 maxPoint = transform.TransformPoint(new Vector3(halfPlaneWidth, 0.0f, halfPlaneWidth));
    private void OnValidate()
    {
        createWaves();

        if (waterMaterial == null) return;

        updateWaveShader();
    }

    void createWaves()
    {
        waves = new Wave[maxWaves];

        float wavelengthMin = medianWavelength / (1.0f + wavelengthRange);
        float wavelengthMax = medianWavelength * (1.0f + wavelengthRange);
        float directionMin = medianDirection - directionalRange;
        float directionMax = medianDirection + directionalRange;
        float speedMin = Mathf.Max(0.01f, medianSpeed - speedRange);
        float speedMax = medianSpeed + speedRange;
        float ampOverLen = medianAmplitude / medianWavelength;

        // Populate waves with random values
        for (int i = 0; i < waveCount; i++)
        {
            float wavelength = UnityEngine.Random.Range(wavelengthMin, wavelengthMax);
            float amplitude = wavelength * ampOverLen;
            float speed = UnityEngine.Random.Range(speedMin, speedMax);
            float direction = UnityEngine.Random.Range(directionMin, directionMax);

            waves[i] = new Wave(amplitude, wavelength, speed, direction);
        }
    }

    public void updateWaveShader()
    {
        Vector4[] waveArray = new Vector4[waveCount];
        Vector4[] directionArray = new Vector4[waveCount];

        for (int i = 0; i < waveCount; i++)
        {
            waveArray[i] = waves[i].toVec4();
            Vector2 direction = waves[i].getDirection();
            directionArray[i] = new Vector4(direction.x, direction.y, 0, 0);
        }

        waterMaterial.SetInt("_NumWaves", waveCount);
        waterMaterial.SetVectorArray("_Waves", waveArray);
        waterMaterial.SetVectorArray("_WaveDirections", directionArray);
    }
}
