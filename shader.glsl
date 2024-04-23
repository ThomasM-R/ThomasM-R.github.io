
#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

const float PI = asin(1.0) * 2.0;
const float EPSILON = 0.00001;

#define ITER clamp(u_time * 60.0, 3.0, 128.0)

void rotate(inout vec2 p, float a) {
    p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

float map(vec3 p) {
    float dist = length(mod(p, vec3(4.0)) - 2.0) - 0.2;
    return dist;
}

struct Ray {
    vec3 origin;
    vec3 direction;
    float length;
};

vec3 rgb2hsv(in vec3 c) {
    vec4 k = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.zy, k.wz), vec4(c.yz, k.xy), (c.z < c.y) ? 1.0 : 0.0);
    vec4 q = mix(vec4(p.xyw, c.x), vec4(c.x, p.yzx), (p.x < c.x) ? 1.0 : 0.0);
    float d = q.x - min(q.w, q.y);
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + EPSILON)), d / (q.x + EPSILON), q.x);
}

vec3 hsv2rgb(in vec3 c) {
    vec3 rgb = clamp(abs(mod(c.x * 6.0 + vec3(0.0,4.0,2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
    return c.z * mix(vec3(1.0), rgb, c.y);
}

void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy ) / u_resolution.x * 1.5;

    Ray ray;
    
    // camera animations
    if (u_time < 3.0) ray.origin = vec3(2.0 - pow(3.0 - u_time, 3.0) * 0.1);
    else ray.origin = vec3(2.0);
    
    if (u_time > 4.0) {
        float loopedTime = mod(u_time, 2.0);
        float speed = loopedTime < 1.0 ? pow(loopedTime, 3.0) * 2.0 : 4.0 - pow(2.0 - loopedTime, 3.0) * 2.0;
        if (mod(u_time, 6.0) < 2.0)
            ray.origin.x += speed;
        else if (mod(u_time, 6.0) < 4.0)
            ray.origin.y += speed;
        else
            ray.origin.z += speed;
    }
    
    ray.direction = normalize(vec3(uv, 0) - vec3(0,0,1));
    rotate(ray.direction.yz, 0.61547970867); // arcsin(1 / sqrt(3))
    rotate(ray.direction.xz, PI * 0.25);
    
    ray.length = 2.0;
    float dist = 0.0;
    int steps = 0;
    
    while (steps < int(ITER)) {
        dist = map(ray.origin + ray.direction * ray.length);
        ray.length += dist;
        if (dist < EPSILON) {
            break;
        }
        steps++;
    }
    vec3 endPos = ray.origin + ray.direction * ray.length;
    
    float steps_inv = 1.0 / ITER;
    
    vec3 color = abs(ray.direction * 2.0);
    color = abs(endPos - ray.origin) * steps_inv;
    color += 1.1 - length(color * ITER) * steps_inv;
    
    color = rgb2hsv(color);
    color.z = 1.0;
    color = hsv2rgb(color);
    
    gl_FragColor = vec4(color, 1.0);
}