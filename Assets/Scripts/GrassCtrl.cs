using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GrassCtrl : MonoBehaviour
{
    [SerializeField]
    GameObject[] entities;
    Vector4[] positions = new Vector4[100];

    // Update is called once per frame
    void Update()
    {
        SendEntityPositionToShader();
    }

    void SendEntityPositionToShader()
    {
        //Shader.SetGlobalVector("_EntityPosition", new Vector4(entity.transform.position.x, entity.transform.position.y, entity.transform.position.z, 1));
        SendEntitiesPositionsToShader();
    }

    void SendEntitiesPositionsToShader()
    {
        for (int i = 0; i < entities.Length; i++)
        {
            positions[i] = entities[i].transform.position;
        }
        Shader.SetGlobalFloat("_EntityPositionsSize", entities.Length);
        Shader.SetGlobalVectorArray("_EntityPositions", positions);
    }
}