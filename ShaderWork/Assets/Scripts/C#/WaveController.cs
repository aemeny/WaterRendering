using UnityEngine;

public class WaveController : MonoBehaviour
{
    public Material waterMaterial;

    public Wave[] waves;
    public int maxWaves = 10;
    public int activeWaves = 4;

    private void Start()
    {
        waves = new Wave[maxWaves];

        // EXAMPLE WAVE DATA
        waves[0] = new Wave(1.0f, 2.0f, 1.0f, 0.0f, new Vector2(1.0f, 0.0f));
        waves[1] = new Wave(1.5f, 2.5f, 1.2f, 1.0f, new Vector2(0.0f, 1.0f));
        waves[2] = new Wave(0.8f, 1.5f, 0.8f, 0.5f, new Vector2(1.0f, 1.0f));
        waves[3] = new Wave(1.2f, 2.8f, 1.5f, 1.2f, new Vector2(-1.0f, 1.0f));

        updateWaveShader();
    }

    void updateWaveShader()
    {
        Vector4[] waveArray = new Vector4[activeWaves];
        Vector4[] directionArray = new Vector4[activeWaves];

        for (int i = 0; i < activeWaves; i++)
        {
            waveArray[i] = waves[i].toVec4();
            Vector2 direction = waves[i].getDirection();
            directionArray[i] = new Vector4(direction.x, direction.y, 0, 0);
        }

        waterMaterial.SetInt("_NumWaves", activeWaves);
        waterMaterial.SetVectorArray("_Waves", waveArray);
        waterMaterial.SetVectorArray("_WaveDirections", directionArray);
    }
}
