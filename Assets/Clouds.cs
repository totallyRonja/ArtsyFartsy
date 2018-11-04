using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Clouds : MonoBehaviour {

    public static Clouds Instance;

    public Material cloudmat;
    public Vector4[] people;
    private Dictionary<string, int> indices = new Dictionary<string, int>();
    int peopleCount = 0;

	void Awake () {
		Instance = this;
        cloudmat = GetComponent<Renderer>().sharedMaterial;
        people = new Vector4[10];
        for(int i=0;i<people.Length;i++)
            people[i] = new Vector4(float.MaxValue, float.MaxValue, float.MaxValue, 1);
	}

    public void SetPosition(string person, Vector3 position){
        int index;
        if(indices.TryGetValue(person, out index)){
            people[index] = new Vector4(position.x, position.y, position.z, 1);
        } else {
            indices.Add(person, peopleCount);
            people[peopleCount] = new Vector4(position.x, position.y, position.z, 1);
            peopleCount++;
        }
        cloudmat.SetVectorArray("_People", people);
    }
}
