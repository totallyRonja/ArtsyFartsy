using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerCamera : MonoBehaviour {

    public Transform Player;

	void Start () {
		
	}
	
	void LateUpdate () {
		transform.position = Player.position;
	}
}
