using UnityEngine;
using System.Collections;

public class camera_target_Script : MonoBehaviour {

    private float z_max = 115.0f;
    private float z_min = 85.0f;
    private float x_max = 115.0f;
    private float x_min = 85.0f;
    private Transform ball_trans = null;
    private Vector3 cur_pos;
	// Use this for initialization
	void Start () {
        ball_trans = GameObject.Find("Sphere").transform;
	}
	
	// Update is called once per frame
	void Update () {
        cur_pos = ball_trans.position;
        cur_pos.y = 1;
        if (cur_pos.x < x_min)
            cur_pos.x = x_min;
        if (cur_pos.x > x_max)
            cur_pos.x = x_max;
        if (cur_pos.z < z_min)
            cur_pos.z = z_min;
        if (cur_pos.z > z_max)
            cur_pos.z = z_max;

        transform.position = cur_pos;
	}
}
