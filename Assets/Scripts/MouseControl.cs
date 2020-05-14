using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MouseControl : MonoBehaviour
{
  public float sensitivity;
  public Transform cameraTransform;
  private float xRotation;

  private void Start()
  {
    //Cursor.lockState = CursorLockMode.Locked;
  }

  private void Update()
  {
    float mouseX = Input.GetAxis("Mouse X") * sensitivity * Time.deltaTime;
    float mouseY = Input.GetAxis("Mouse Y") * sensitivity * Time.deltaTime;
    xRotation -= mouseY;
    xRotation = Mathf.Clamp(xRotation, -90f, 90f);
    transform.localRotation = Quaternion.Euler(xRotation, 0f, 0f);
    cameraTransform.Rotate(Vector3.up * mouseX);
  }
}
