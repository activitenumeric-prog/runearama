
using UnityEngine;

public class Portal : MonoBehaviour {
    public Portal target; public bool bidirectional = true; public Vector2 exitOffset = Vector2.up;
    void OnTriggerEnter2D(Collider2D c){ if(!target) return; if(!c.CompareTag("Player")) return; c.transform.position = target.transform.position + (Vector3)exitOffset; }
    void OnValidate(){ if (bidirectional && target && target.target != this) target.target = this; }
}
