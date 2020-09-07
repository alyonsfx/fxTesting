using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AssignAtlasOffset : MonoBehaviour
{
    void Awake()
    {
        SpriteRenderer rend = GetComponent<SpriteRenderer>();
        Rect sprite = rend.sprite.textureRect;
        Material mat = rend.material;
        mat.SetVector("_AtlasInfo", new Vector4(sprite.x, sprite.y, sprite.width, sprite.height));
    }
}
