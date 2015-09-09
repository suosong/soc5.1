using UnityEngine;
using System.Collections;

public class player2controlScript : MonoBehaviour {

    private CharacterController controller;
    private Animator anim;


	// Use this for initialization
	void Start () {
        controller = GetComponent<CharacterController>();
        anim = GetComponent<Animator>();  
	}
	
	// Update is called once per frame
	void Update () {
        Vector3 move = Physics.gravity * Time.deltaTime;
        controller.Move(move);
	}
}
