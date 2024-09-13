using UnityEngine;

public class Wave
{
    public float amplitude;
    public float waveLength;
    public float speed;
    public float phaseShift;
    public Vector2 direction;

    public Wave(float amplitude, float waveLength, float speed, float phaseShift, Vector2 direction)
    {
        this.amplitude = amplitude;
        this.waveLength = waveLength;
        this.speed = speed;
        this.phaseShift = phaseShift;
        this.direction = direction;
    }

    public Vector4 toVec4()
    {
        return new Vector4(amplitude, waveLength, speed, phaseShift);
    }

    public Vector2 getDirection()
    {
        return direction;
    }
}
