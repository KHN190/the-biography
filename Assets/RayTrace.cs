using System.Collections.Generic;
using UnityEngine;

public class RayTrace : MonoBehaviour
{
	private RenderTexture target;
    public ComputeShader compute;
    private ComputeBuffer buffer;

        struct Sphere {
        public Vector3 position;
        public float radius;
        public Vector3 albedo;
        public Vector3 specular;
    }

    private void Start()
    {
        // create sphere
        Sphere sphere = new Sphere();
        sphere.position = new Vector3(0, 2, 0);
        sphere.radius = 2;
        sphere.albedo = new Vector3(0.2f, 0.3f, 0.2f);
        sphere.specular = new Vector3(0.8f, 0.8f, 0.8f);

        List<Sphere> spheres = new List<Sphere>();
        spheres.Add(sphere);

        // set sphere data size in bytes
        buffer = new ComputeBuffer(spheres.Count, 40);
        buffer.SetData(spheres);
    }

    private void OnDisable()
    {
        if (buffer != null)
            buffer.Dispose();
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Render(destination);
    }

    private void Render(RenderTexture destination)
    {
        // Make sure we have a current render target
        InitRenderTexture();

        // Set the target and dispatch the compute shader
        compute.SetTexture(0, "Result", target);
        compute.SetBuffer(0, "_Spheres", buffer);
        compute.SetMatrix("_CameraToWorld", Camera.main.cameraToWorldMatrix);
    	compute.SetMatrix("_CameraInverseProjection", Camera.main.projectionMatrix.inverse);
        compute.SetFloat("_Time", Time.time * 0.18f);
        int threadGroupsX = Mathf.CeilToInt(Screen.width / 8.0f);
        int threadGroupsY = Mathf.CeilToInt(Screen.height / 8.0f);
        compute.Dispatch(0, threadGroupsX, threadGroupsY, 1);

        // Blit the result texture to the screen
        Graphics.Blit(target, destination);
    }

    private void InitRenderTexture()
    {
        if (target == null || target.width != Screen.width || target.height != Screen.height)
        {
            RenderTexture init = new RenderTexture(Screen.width, Screen.height, 0,
                RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
            init.enableRandomWrite = true;
            init.Create();

            if (target != null)
                target.Release();
            target = init;
        }
    }
}
