// book of shader
float2 tile(float2 st, float zoom){
    st *= zoom;
    return frac(st);
}

float circle(float2 st, float radius){
    float2 pos = float2(0.5 - st);
    radius *= 0.75;
    return 1.-smoothstep(radius-(radius*0.05),radius+(radius*0.05),dot(pos,pos)*3.14);
}

float circlePattern(float2 st, float radius) {
    return  circle(st+float2(0.,-.5), radius)+
            circle(st+float2(0.,.5),  radius)+
            circle(st+float2(-.5,0.), radius)+
            circle(st+float2(.5,0.),  radius);
}

float4 Background(float3 vec, inout float time)
{
    float2 st = float2(vec.x + time, vec.y);
    float2 nt = float2(vec.x + time * 0.5, vec.y);
    float3 color = 0.0;

    float2 grid1 = tile(st,7.);
    grid1 = tile(st, 7.);
    color += lerp(float3(0.075,0.114,0.329),float3(0.973,0.843,0.675),circlePattern(grid1,0.23)-circlePattern(grid1,0.01));

    float2 grid2 = tile(st,3.);
    grid2 = tile(nt,3.);
    color += lerp(color, float3(0.761,0.247,0.102), circlePattern(grid2,0.2)) - circlePattern(grid2,0.05);

    return float4(color.x, color.y, color.z, 1.0);
}

// return factor of refraction
float fresnel(Ray ray, RayHit hit)
{
    float f = abs(dot(ray.direction, hit.normal));
    return smoothstep(0.0, 0.6, f);
    // return 0.8;
}

float4 Reflective(inout Ray ray, RayHit hit, float time)
{
    ray.origin = hit.position + hit.normal * 0.001;
    ray.direction = normalize(reflect(ray.direction, hit.normal));
    ray.energy =  ray.energy * hit.specular;

    return float4(0.0, 0.0, 0.0, 1.0);
}

float4 Refractive(inout Ray ray, RayHit hit, float time)
{
    // refraction rate of air
    float w = 1.0;
    // refraction rate of glass
    float f = 1.01;

    ray.origin = hit.position - hit.normal * 0.001;
    ray.direction = normalize(refract(ray.direction, hit.normal, w / f));
    ray.energy *= 0.95;

    ray.direction *= -1.0;
    ray.direction = normalize(refract(ray.direction, hit.normal, w / f * 0.85));
    ray.energy *= 0.95;

    return Background(ray.direction * 0.4, time);
}