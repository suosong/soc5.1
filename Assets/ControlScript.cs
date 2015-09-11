﻿using UnityEngine;
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

        //Animator anim = cur_player.GetComponent<Animator>();
        //if (anim) 
        //anim.Play("attack1");
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

        if (Input.GetKeyDown(KeyCode.Tab))
        {
            Change_cur_player();
        }

        if (Input.GetKey(KeyCode.W))
        {
            //anim.Play("run");
            controller.Move(new Vector3(0, 0, move_speed));
            is_running = true;
        }

        if (Input.GetKey(KeyCode.S))
        {
            //anim.Play("attack1");
            controller.Move(new Vector3(0, 0, -move_speed));
            is_running = true;
        }

        if (Input.GetKey(KeyCode.A))
        {
            //anim.Play("run");
            controller.Move(new Vector3(-move_speed, 0, 0));
            is_running = true;
        }

        if (Input.GetKey(KeyCode.D))
        {
            //anim.Play("attack1");
            controller.Move(new Vector3(move_speed, 0, 0));
            is_running = true;
        }

        anim.SetBool("is_running", is_running);

        if (Input.GetKeyDown(KeyCode.J))
        {
            if (holder == cur_player)
            {
                rb.AddForce(holder.transform.forward * 400);
                //anim.SetTrigger("Trigger kick");

                holder = null;
                soccer.transform.parent = null;
            }
            else
            {
                anim.SetTrigger("Trigger slide tackle");
            }
        }
	}
}
