using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Yarn.Unity;

public class PlayerDialogue : MonoBehaviour {

    public float InteractionRadius;

    DialogueCharacter activeCharacter;

	void Start () {
		
	}

    void OnDrawGizmosSelected() {
        Gizmos.color = Color.blue;

        // Flatten the sphere into a disk, which looks nicer in 2D games
        Gizmos.matrix = Matrix4x4.TRS(transform.position, Quaternion.identity, new Vector3(1,1,0));

        // Need to draw at position zero because we set position in the line above
        Gizmos.DrawWireSphere(Vector3.zero, InteractionRadius);
    }

    void Update(){
        if(Input.GetButtonDown("Jump") && activeCharacter != null){
            DialogueRunner.Instance.StartDialogue(activeCharacter.StartNode);
        }
    }
	
	void LateUpdate () {
        if(activeCharacter != null){
            if(Vector3.Distance(activeCharacter.transform.position, transform.position) < InteractionRadius){
                return;
            } else {
                activeCharacter.SetInRange(false);
                activeCharacter = null;
            }
        }
        var dialogue = DialogueCharacter.Characters.Find(c => Vector3.Distance(c.transform.position, transform.position) < InteractionRadius);
        if(dialogue == null)
            return;
        dialogue.SetInRange(true);
        activeCharacter = dialogue;
	}
}
