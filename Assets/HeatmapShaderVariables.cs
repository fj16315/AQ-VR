using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using System.IO;

[ExecuteInEditMode]
public class HeatmapShaderVariables : MonoBehaviour
{
  public GameObject sensor;
  public float intensity;
  public float radius;
  public float min;
  public string filepath;

  private void OnPreRender()
  {
    List<Vector4> sensors = new List<Vector4>();
    List<float> intensities = new List<float>();

    SensorData[] sensorsObj = FindObjectsOfType<SensorData>();
    foreach (var s in sensorsObj)
    {
      sensors.Add(s.transform.position);
      intensities.Add(s.intensity);
    }

    int sensorNo = sensors.Count;

    /*string fileData = File.ReadAllText(filepath);
    string[] lines = fileData.Split("\n"[0]);
    string[] lineData = (lines[0].Trim()).Split(","[0]);
    intensity = float.Parse(lineData[0]);*/

    //intensities.Add(intensity);

    Shader.SetGlobalVectorArray("_SensorsPos", sensors);
    Shader.SetGlobalFloatArray("_SensorsIntensities", intensities);
    Shader.SetGlobalFloat("_SensorRadius", radius);
    Shader.SetGlobalFloat("_SensorsNo", sensorNo);
    Shader.SetGlobalFloat("_SensorMin", min);
    Shader.SetGlobalFloat("_SensorMax", intensities.Max());
  }
}
