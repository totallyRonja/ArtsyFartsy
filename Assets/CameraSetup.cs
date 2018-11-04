using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera)), ExecuteInEditMode]
public class CameraSetup : MonoBehaviour {

	// Use this for initialization
	void Start () {
		var cam = GetComponent<Camera>();
		cam.depthTextureMode |= DepthTextureMode.Depth;
	}
	
	// Update is called once per frame
	void Update () {
		
	}
}
