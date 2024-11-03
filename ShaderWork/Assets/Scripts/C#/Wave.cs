using UnityEngine;

public class Wave
{
    public float amplitude;
    public float waveLength;
    public float speed;
    public float phaseShift;
    public Vector2 direction;

    public Wave(float amplitude, float waveLength, float speed, float direction)
    {
        this.amplitude = amplitude;
        this.waveLength = waveLength;
        this.speed = speed;

        this.direction = new Vector2(Mathf.Cos(Mathf.Deg2Rad * direction), Mathf.Sin(Mathf.Deg2Rad * direction));
        this.direction.Normalize();
    }

    //this.frequency = 2.0f / wavelength;
    //this.phase = speed* Mathf.Sqrt(9.8f * 2.0f * Mathf.PI / wavelength);;

    //if (waveFunction == WaveFunction.Gerstner)
    //   this.steepness = steepness / this.frequency* this.amplitude* (float) waveCount;
    //else
    //   this.steepness = steepness;

    public Vector4 toVec4()
    {
        return new Vector4(amplitude, waveLength, speed, 0.0f);
    }

    public Vector2 getDirection()
    {
        return direction;
    }
}
