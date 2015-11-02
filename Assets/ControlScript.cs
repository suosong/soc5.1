using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class ControlScript : MonoBehaviour {

    private float hold_time = 0; // 被持球时长
    private GameObject holder = null;    // 持球人
    public GameObject soccer = null;
    public List<GameObject> players;
    public GameObject cur_player = null;
    private const float move_speed = 0.1f;
    public Rigidbody rb = null;
    public Vector3 forward_w = new Vector3(1, 0, 1);
    public Vector3 forward_s = new Vector3(-1, 0, -1);
    public Vector3 forward_a = new Vector3(-1, 0, 1);
    public Vector3 forward_d = new Vector3(1, 0, -1);
    public Vector3 cur_forward;
    public bool cur_forward_changing = false;
    public const float forward_change_delta = 0.20f;

    private bool FindPlayer(GameObject player)
    {

        if (player == cur_player)
        {
            return true;
        }
        else
        {
            return false;
        }

    }

    void Change_cur_player()
    {
        if (!cur_player)
        {
            cur_player = players[0];
            return;
        }

        int cur_player_index = players.FindIndex(FindPlayer);
        if(cur_player_index == players.Count-1)
        {
            cur_player = players[0];
        }
        else
        {
            cur_player = players[cur_player_index+1];
        }

        cur_forward_changing = false;
    }


	// Use this for initialization
	void Start () {
        soccer = GameObject.Find("Sphere");
        rb = soccer.GetComponent<Rigidbody>();
        players = new List<GameObject>();
        players.Add(GameObject.Find("player3"));
        players.Add(GameObject.Find("player2"));
        cur_player = GameObject.Find("player2");

	}
	
	// Update is called once per frame
	void Update () {
        // 无持球人或持球时间超过0.3秒情况下，距离球小于0.2米且是与球距离最近的人获得球
        if (holder)
        {
            soccer.transform.parent = holder.transform;
            soccer.transform.localPosition = new Vector3(3.2f, -0.74f, 0);
        }

        hold_time = hold_time + Time.deltaTime;
        if (!holder || hold_time > 0.3)
        {
            float dis_min = 2.3f;
            foreach (GameObject player in players)
            {
                if (player == holder)
                    continue;

                float dis = Vector3.Distance(soccer.transform.position, player.transform.position);
                if (dis_min > dis) 
                {
                    dis_min = dis;
                    holder = player;
                    hold_time = 0;
                    soccer.transform.parent = holder.transform;
                    soccer.transform.localPosition = new Vector3(3.2f, -0.74f, 0);
                }
            }
        }

        CharacterController controller = cur_player.GetComponent<CharacterController>();
        Animator anim = cur_player.GetComponent<Animator>();

        bool is_running = false;
        int f_w = 0, f_s = 0, f_a = 0, f_d = 0;


        if (Input.GetKeyDown(KeyCode.Tab))
        {
            Change_cur_player();
        }

        if (Input.GetKey(KeyCode.W))
        {
            controller.Move(new Vector3(0, 0, move_speed));
            is_running = true;
            f_w = 1;
        }

        if (Input.GetKey(KeyCode.S))
        {
            controller.Move(new Vector3(0, 0, -move_speed));
            is_running = true;
            f_s = 1;
        }

        if (Input.GetKey(KeyCode.A))
        {
            controller.Move(new Vector3(-move_speed, 0, 0));
            is_running = true;
            f_a = 1;
        }

        if (Input.GetKey(KeyCode.D))
        {
            controller.Move(new Vector3(move_speed, 0, 0));
            is_running = true;
            f_d = 1;
        }

        if (f_w != 0 || f_s != 0 || f_a != 0 || f_d != 0)
        {
            //cur_player.transform.forward = f_w * forward_w + f_s * forward_s + f_a * forward_a + f_d * forward_d;
            cur_forward = f_w * forward_w + f_s * forward_s + f_a * forward_a + f_d * forward_d;
            cur_forward_changing = true;
        }

        change_cur_player_rotation();
            

        anim.SetBool("is_running", is_running);

        if (Input.GetKeyDown(KeyCode.J))
        {
            if (holder == cur_player)
            {
                rb.AddForce(get_pass_dir() * 400);
                //anim.SetTrigger("Trigger kick");

                holder = null;
                soccer.transform.parent = null;
            }
            else
            {
                anim.SetTrigger("Trigger slide tackle");
            }
        }

        Debug.Log("ori " + cur_player.transform.forward.x.ToString() + "  " + cur_player.transform.forward.y.ToString() + "  " + cur_player.transform.forward.z.ToString());
	}

    Vector3 get_pass_dir()
    {
        return holder.transform.forward;
    }

    void change_cur_player_rotation()
    {
        if (!cur_forward_changing)
            return;

        float f_x = 0;
        float f_z = 0;

        if (Mathf.Abs(cur_forward.x - cur_player.transform.forward.x) < forward_change_delta)
            f_x = cur_forward.x;
            //cur_player.transform.forward = new Vector3(0, cur_forward.x, 0);
        else if (cur_forward.x > cur_player.transform.forward.x)
            f_x = cur_player.transform.forward.x + forward_change_delta;
            //cur_player.transform.forward = new Vector3(0, cur_player.transform.forward.x + forward_change_delta, 0);
        else
            f_x = cur_player.transform.forward.x - forward_change_delta;
            //cur_player.transform.forward = new Vector3(0, cur_player.transform.forward.x - forward_change_delta, 0);

        if (Mathf.Abs(cur_forward.z - cur_player.transform.forward.z) < forward_change_delta)
            f_z = cur_forward.z;
            //cur_player.transform.forward = new Vector3(0, cur_forward.z, 0);
        else if (cur_forward.z > cur_player.transform.forward.z)
            f_z = cur_player.transform.forward.z + forward_change_delta;
            //cur_player.transform.forward = new Vector3(0, cur_player.transform.forward.z + forward_change_delta, 0);
        else
            f_z = cur_player.transform.forward.z - forward_change_delta;
            //cur_player.transform.forward = new Vector3(0, cur_player.transform.forward.z - forward_change_delta, 0);

        cur_player.transform.forward = new Vector3(f_x, 0, f_z);
        if (cur_forward.x == cur_player.transform.forward.x && cur_forward.z == cur_player.transform.forward.z)
            cur_forward_changing = false;
    }
}
