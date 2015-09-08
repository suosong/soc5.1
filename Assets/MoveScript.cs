using UnityEngine;
using System.Collections;

public class MoveScript : MonoBehaviour {

    private CharacterController controller;
    private Animation anim;

	// Use this for initialization
	void Start () {
        controller = GetComponent<CharacterController>();
        anim = GetComponent<Animation>();  
	}
	
	// Update is called once per frame
	void Update () {
        if (Input.GetKey(KeyCode.W))
        {
            anim.Play("run");
        }

        if (Input.GetKeyDown(KeyCode.S))
        {
            anim.Play("attack1");
        }

        if (Input.GetKeyDown(KeyCode.A))
        {
            anim.Play("attack2");
        }

        if (Input.GetKeyDown(KeyCode.D))
        {
            anim.Play("attack3");
        }

	    Vector3 move = Physics.gravity * Time.deltaTime;
        controller.Move(move);
	}
}
