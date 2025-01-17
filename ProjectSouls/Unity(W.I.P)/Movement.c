using System;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.TextCore.Text;


public class PlayerMovment : MonoBehaviour
{
    
    private const float defaultSpeed = 15f;
    public float speed = defaultSpeed;
    public float jumpHeight = 10f;
    private CharacterController characterController;
    public float gravityValue = -9.81f;
    private Vector3 playerVelocity;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        characterController = GetComponent<CharacterController>();
    }

    // Update is called once per frame
    void Update()
    {
        float horizontal = Input.GetAxis("Horizontal");
        float vertical = Input.GetAxis("Vertical");

        Vector3 move = Vector3.zero;

        move += transform.forward * vertical;
        move += transform.right * horizontal;

        bool isGrounded = characterController.isGrounded;

        if (isGrounded && playerVelocity.y < 0)
        {
            playerVelocity.y = 0f;
        }

        playerVelocity.y += gravityValue * Time.deltaTime;

        if (isGrounded && Input.GetKeyDown(KeyCode.Space)) {
            playerVelocity.y += Mathf.Sqrt(jumpHeight * -2.0f * gravityValue);
        }

        if (isGrounded && Input.GetKey(KeyCode.LeftShift)) {
            speed = 25;
        } else {
            speed = defaultSpeed;
        }

        characterController.Move(((move * speed) + playerVelocity) * Time.deltaTime);
    }
}
 
