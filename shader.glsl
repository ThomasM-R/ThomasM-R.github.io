
#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

//
// Distance field function for the scene. It combines
// the seperate distance field functions of three spheres
// and a plane using the min-operator.
//
float sceneSDF(vec3 p) {
    return length(mod(p + 1.5, 3.) - 1.5) - 0.4;
}

//
// Calculate the normal by taking the central differences on the distance field.
//
vec3 calcNormal(in vec3 p) {
    vec2 e = vec2(1.0, -1.0) * 0.5773 * 0.0005;
    return normalize(
        e.xyy * sceneSDF(p + e.xyy) +
        e.yyx * sceneSDF(p + e.yyx) +
        e.yxy * sceneSDF(p + e.yxy) +
        e.xxx * sceneSDF(p + e.xxx));
}

const int MAX_STEPS = 256;

void main() {
    // start of raymarcher code
    vec3 cameraPos = vec3(1.5, 1.5, -u_time * 2.0);
    vec3 ro = vec3(0, 0, 1);                           // ray origin

    vec2 q = (gl_FragCoord.xy - .5 * u_resolution.xy ) / u_resolution.y;
    vec3 rd = normalize(vec3(q, 0.) - ro);             // ray direction for fragCoord.xy

    // March the distance field until a surface is hit.
    float h, t = 1.;
    for (int i = 0; i < MAX_STEPS; i++) {
        h = sceneSDF(ro + rd * t + cameraPos);
        t += h;
        // hit distance gets bigger the farther away the ray is from the camera
        if (h < 0.01) break;
    }

    if (h < 0.01) {
        vec3 p = ro + rd * t + cameraPos;
        vec3 normal = calcNormal(p);

        float fog = 1.0 - distance(p, cameraPos) / 32.0;
        gl_FragColor = vec4(normal + vec3(0.5, 0.5, 0.5) * fog, 1.0);
    } else {
        gl_FragColor = vec4(0,0,0,1);
    }
}