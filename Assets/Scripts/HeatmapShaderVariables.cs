using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using System.IO;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

[ExecuteInEditMode]
public class HeatmapShaderVariables : MonoBehaviour
{
  public float radius;
  public float max;
  public float min;
  public string filepath;
  public List<GameObject> sensors;
  private string[] lines;
  private string[] lineData;
  public float speed;
  public Slider slider;
  public Text pause;
  private bool isPaused;

  private void Awake()
  {
    string fileData = File.ReadAllText(filepath);
    lines = fileData.Split("\n"[0]);
    lineData = (lines[0].Trim()).Split(","[0]);
    slider.maxValue = lines.Length - 1;
    slider.interactable = false;
    isPaused = false;
    StartCoroutine("RunExperiment");
  }

  private void OnPreRender()
  {
    List<float> intensities = new List<float>();
    List<Vector4> positions = new List<Vector4>();

    int sensorNo = sensors.Count;

    for (int i = 0; i < sensorNo; i++)
    {
      positions.Add(sensors[i].transform.position);
      intensities.Add(float.Parse(lineData[i]));
    }

    Shader.SetGlobalVectorArray("_SensorsPos", positions);
    Shader.SetGlobalFloatArray("_SensorsIntensities", intensities);
    Shader.SetGlobalFloat("_SensorRadius", radius);
    Shader.SetGlobalFloat("_SensorsNo", sensorNo);
    Shader.SetGlobalFloat("_SensorMin", min);
    Shader.SetGlobalFloat("_SensorMax", max);
    //Shader.SetGlobalFloat("_SensorMax", max);
  }

  IEnumerator RunExperiment()
  {
    for (int i = 0; i <= lines.Length; i++)
    {
      while (isPaused)
      {
        yield return null;
      }

      if (i < lines.Length - 1)
      {
        lineData = (lines[i].Trim()).Split(","[0]);
        slider.value = i;
      }
      else if (i == lines.Length - 1)
      {
        slider.value = i;
      }
      else
      {
        SceneManager.LoadScene("Experiments");
      }
      yield return new WaitForSeconds(speed);
    }
  }

  public void ChangeSpeed(float newSpeed)
  {
    speed = newSpeed;
  }

  public void PausePlay()
  {
    if (isPaused)
    {
      isPaused = false;
      pause.text = "Pause";
    }
    else
    {
      isPaused = true;
      pause.text = "Play";
    }
  }
}
