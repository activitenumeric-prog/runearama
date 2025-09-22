
using UnityEngine;

public class Door : MonoBehaviour {
    public Collider2D blocker;
    public void SetLocked(bool locked){ if (blocker) blocker.enabled = locked; }
}
