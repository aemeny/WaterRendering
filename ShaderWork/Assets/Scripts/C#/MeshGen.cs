using UnityEngine;

public class MeshGen : MonoBehaviour
{
    public Material mat;

    public int x_cnt = 2;
    public int z_cnt = 2;
    public float x_scale = 1f;
    public float z_scale = 1f;

    Vector3[] vert;
    int[] tri;
    //Vector2[] uvs;

    void Start()//public void Generate()
    {
        if (x_scale <= 0f)
        {
            x_scale = 1f;
            Debug.Log("Xscale less than or equal to 0");
        }
        if (z_scale <= 0f)
        {
            z_scale = 1f;
            Debug.Log("Zscale less than or equal to 0");
        }

        if (x_cnt >= 2 && z_cnt >= 2)
        {
            MakePlane();
        }
    }

    //make mesh without uv mapping...
    void MeshMake(ref Vector3[] v, ref int[] t, Material m)
    {
        Mesh me = new Mesh();
        if (!transform.GetComponent<MeshFilter>() || !transform.GetComponent<MeshRenderer>())
        {
            transform.gameObject.AddComponent<MeshFilter>();
            transform.gameObject.AddComponent<MeshRenderer>();
        }
        transform.GetComponent<MeshFilter>().mesh = me;
        me.vertices = v;
        me.triangles = t;
        me.RecalculateNormals();
        transform.gameObject.GetComponent<MeshRenderer>().material = m;
    }

    void MakePlane()
    {
        //define vertices...
        vert = new Vector3[x_cnt * z_cnt];
        for (int i = 0; i < z_cnt; i++)
        {
            for (int j = 0; j < x_cnt; j++)
            {
                int idx = i * x_cnt + j;
                vert[idx] = new Vector3(j * x_scale, 0f, i * z_scale);
            }
        }

        //define triangles...
        tri = new int[(x_cnt - 1) * (z_cnt - 1) * 6];
        int id = 0;
        for (int i = 0; i < z_cnt - 1; i++)
        {
            for (int j = 0; j < x_cnt - 1; j++)
            {
                //first triangle..
                tri[id] = i * x_cnt + j;
                tri[id + 1] = tri[id] + x_cnt;
                tri[id + 2] = tri[id + 1] + 1;

                //second triangle..
                tri[id + 3] = tri[id];
                tri[id + 4] = tri[id + 2];
                tri[id + 5] = tri[id] + 1;

                id += 6;
            }
        }

        MeshMake(ref vert, ref tri, mat);  //mesh without uv mappin..
    }
}