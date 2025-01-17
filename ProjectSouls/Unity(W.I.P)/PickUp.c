
using Unity.VisualScripting;
using UnityEditor;
using UnityEditor.Rendering;
using UnityEditor.VersionControl;
using UnityEngine;

public class PickUp : MonoBehaviour
{
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    GameObject head;

    void Start()
    {
        head = transform.GetChild(0).GameObject();
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.E)) {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit itemHit;
            if (Physics.Raycast(head.transform.position, ray.direction, out itemHit, 5)) {
                ItemProps itemProps = itemHit.transform.gameObject.GetComponent<ItemProps>();
                if (itemProps) {
                    Debug.Log(itemProps.item);
                    itemProps.item.SetActive(true);
                    itemHit.transform.gameObject.SetActive(false);
                }
            }
        }
    }
}
