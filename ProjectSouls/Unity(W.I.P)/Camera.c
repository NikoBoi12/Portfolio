using Unity.Mathematics;
using UnityEngine;
using UnityEngine.UIElements.Experimental;

public class CameraScript : MonoBehaviour
{

    public float xSensitivity = 3f;
    public float ySensitivity = 3f;
    public new Camera camera;

    private float xRotation = 0;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
        // Cursor.visible = false;
    }

    // Update is called once per frame
    void Update()
    {
        float mouseX = Input.GetAxisRaw("Mouse X") * xSensitivity;
        float mouseY = Input.GetAxisRaw("Mouse Y") * ySensitivity;

        transform.Rotate(0, mouseX, 0);

        xRotation = math.clamp(-mouseY + xRotation, -90, 90);
        
        camera.transform.eulerAngles = new Vector3(xRotation, camera.transform.eulerAngles.y, camera.transform.eulerAngles.z);
    }
}   
