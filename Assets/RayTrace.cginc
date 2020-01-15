#define FLOAT3_ONES float3(1.0, 1.0, 1.0)

// structs
struct Sphere
{
    float3 position;
    float radius;
    float3 albedo;
    float3 specular;
};

struct Ray
{
    float3 origin;
    float3 direction;
    float3 energy;
};

struct RayHit
{
    float3 position;
    float distance;
    float3 normal;
    float3 albedo;
    float3 specular;
    uint object;
};

// create structs
Ray CreateRay(float3 origin, float3 direction)
{
    Ray ray;
    ray.origin = origin;
    ray.direction = direction;
    ray.energy = FLOAT3_ONES;
    return ray;
}

RayHit CreateRayHit()
{
    RayHit hit;
    hit.position = float3(0.0f, 0.0f, 0.0f);
    hit.distance = 1.#INF;
    hit.normal = float3(0.0f, 0.0f, 0.0f);
    hit.object = 0;
    return hit;
}

Ray CreateCameraRay(float2 uv, float4x4 camToWorld, float4x4 camInvProj)
{
    // Transform the camera origin to world space
    float3 origin = mul(camToWorld, float4(0.0f, 0.0f, 0.0f, 1.0f)).xyz;
    // Invert the perspective projection of the view-space position
    float3 direction = mul(camInvProj, float4(uv, 0.0f, 1.0f)).xyz;
    // Transform the direction from camera to world space
    direction = normalize(mul(camToWorld, float4(direction, 0.0f)).xyz);

    return CreateRay(origin, direction);
}

void IntersectGroundPlane(Ray ray, inout RayHit bestHit)
{
    // Calculate distance along the ray where the ground plane is intersected
    float t = -ray.origin.y / ray.direction.y;
    if (t > 0 && t < bestHit.distance)
    {
        bestHit.distance = t;
        bestHit.position = ray.origin + t * ray.direction;
        bestHit.normal = float3(0.0, 1.0, 0.0);
        bestHit.albedo = float3(0.4, 0.4, 0.4);
        bestHit.specular = float3(0.6, 0.6, 0.6);
        bestHit.object = 1;
    }
}

void IntersectSphere(Ray ray, inout RayHit bestHit, Sphere sphere)
{
    // Calculate distance along the ray where the sphere is intersected
    float3 d = ray.origin - sphere.position;
    float p1 = -dot(ray.direction, d);
    float p2sqr = p1 * p1 - dot(d, d) + sphere.radius * sphere.radius;
    if (p2sqr < 0)
        return;
    float p2 = sqrt(p2sqr);
    float t = p1 - p2 > 0 ? p1 - p2 : p1 + p2;
    // find closest hit
    if (t > 0 && t < bestHit.distance)
    {
        bestHit.distance = t;
        bestHit.position = ray.origin + t * ray.direction;
        bestHit.normal = normalize(bestHit.position - sphere.position);
        bestHit.albedo = sphere.albedo;
        bestHit.specular = sphere.specular;
        bestHit.object = 2;
    }
}
