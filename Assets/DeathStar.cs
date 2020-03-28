﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DeathStar : MonoBehaviour
{
  public float height;
  public float distance;
  public float rotationSpeed;

  private void Start()
  {
    transform.position = new Vector3(distance, height, distance);
  }

  private void Update()
  {
    transform.RotateAround(Vector3.zero, Vector3.up, rotationSpeed * Time.deltaTime);
  }
}
