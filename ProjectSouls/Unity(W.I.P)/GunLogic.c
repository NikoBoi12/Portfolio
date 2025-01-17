using UnityEngine;




public class Gun : MonoBehaviour
{
    public GameObject firePoint;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Mouse0)) {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit bulletHit;
            if (Physics.Raycast(firePoint.transform.position, ray.direction*1000, out bulletHit)) {
                Debug.Log(bulletHit.transform.name);
                Debug.DrawLine(firePoint.transform.position, bulletHit.point, Color.red, 100f);
            } else {
                Debug.Log(firePoint.transform.position + ray.direction*1000);
                Debug.DrawLine(firePoint.transform.position, firePoint.transform.position + ray.direction*1000, Color.red, 100f);
            }
        }
    }
}
