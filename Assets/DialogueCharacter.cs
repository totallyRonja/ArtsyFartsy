using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DialogueCharacter : MonoBehaviour {

    public static List<DialogueCharacter> Characters = new List<DialogueCharacter>();

    public bool InRange = false;
    public GameObject InteractableDisplay;
    public string StartNode;

    void Start(){
        Clouds.Instance.SetPosition(gameObject.name, transform.position);
    }

	void OnEnable () {
		Characters.Add(this);
        SetInRange(false);
	}

    void OnDisable () {
		Characters.Remove(this);
	}
	
	public void SetInRange(bool inRange){
        InRange = inRange;
        InteractableDisplay.SetActive(inRange);
    }
}
