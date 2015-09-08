using UnityEngine;
using System.Collections;

public class camera_Script1 : MonoBehaviour {

    private GameObject ball = null;
    private Vector3 offset;
	// Use this for initialization
	void Start () {
	     ball = GameObject.Find("Sphere");
        offset = new Vector3(0, 10, 10);
	}
	
	// Update is called once per frame
	void Update () {
        //transform.position = ball.transform.position + offset;
	}
}
