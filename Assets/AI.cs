using UnityEngine;
using System.Collections;

public class none : MonoBehaviour {
    public float length_pos = 0.5f; // 最左边是 0，最右边是 1
    public float width_pos = 0.5f;  // 最下边是 0，最上边是 1

    public Vector3 field_left_up = new Vector3(75, 0, 125);
    public Vector3 field_left_down = new Vector3(75, 0, 75);
    public Vector3 field_right_up = new Vector3(125, 0, 125);
    public Vector3 field_right_down = new Vector3(125, 0, 75);

    public bool left_or_right = true;  // true, 左方，false，右方

    public const float cover_scale = 0.5f;  // 阵型覆盖球场面积

    private const float move_speed = 0.1f;

    public CharacterController controller;

	// Use this for initialization
	void Start () {
        controller = gameObject.GetComponent<CharacterController>();
	}
	
	// Update is called once per frame
	void Update () {
        if 
        Vector3 target_pos = get_pos();
        controller.Move((target_pos - gameObject.transform.position).normalized * move_speed);
	}

    Vector3 get_pos()
    {
        float x, y = 0, z;

        z = field_left_down.z + width_pos * (field_left_up.z - field_left_down.z);

        x = field_left_down.x + length_pos * (field_right_down.x - field_left_down.x);

        return new Vector3(x, y, z);
    }
}
