float mod289(float x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 mod289(vec4 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 perm(vec4 x){return mod289(((x * 34.0) + 1.0) * x);}

float noise(vec3 p){
    vec3 a = floor(p);
    vec3 d = p - a;
    d = d * d * (3.0 - 2.0 * d);

    vec4 b = a.xxyy + vec4(0.0, 1.0, 0.0, 1.0);
    vec4 k1 = perm(b.xyxy);
    vec4 k2 = perm(k1.xyxy + b.zzww);

    vec4 c = k2 + a.zzzz;
    vec4 k3 = perm(c);
    vec4 k4 = perm(c + 1.0);

    vec4 o1 = fract(k3 * (1.0 / 41.0));
    vec4 o2 = fract(k4 * (1.0 / 41.0));

    vec4 o3 = o2 * d.z + o1 * (1.0 - d.z);
    vec2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);

    return o4.y * d.y + o4.x * (1.0 - d.y);
}

float smin(float a, float b, float k) {
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}

mat2 rotate(float a) {
    return mat2(-sin(a), cos(a),
               cos(a), sin(a));
}

void rotate(inout vec2 a, inout vec2 b, float angle) {
    a *= rotate(angle);
    b *= rotate(angle);
}

float circle(vec2 p, float radius) {
    return length(p) - radius;
}

float rightHalfCircle(vec2 p, float radius) {
    return max(-p.x, circle(p, radius));
}

float leftHalfCircle(vec2 p, float radius) {
    return max(p.x, circle(p, radius));
}

float upHalfCircle(vec2 p, float radius) {
    return max(-p.y, circle(p, radius));
}

float downHalfCircle(vec2 p, float radius) {
    return max(p.y, circle(p, radius));
}

float rect(vec2 p, vec2 dimensions) {
    dimensions *= .5;
    return max(abs(p.x) - dimensions.x, abs(p.y) - dimensions.y);
}

float r(vec2 p) {
    float result = 1.;

    result = min(result, circle(p - vec2(.27, .25), .124));
    result = min(result, rect(p, vec2(.25, .75)));

    return result;
}

float o(vec2 p) {
    float result = 1.;

    result = min(result, circle(p, .25));

    return result;
}

float h(vec2 p) {
    float result = 1.;

    result = min(result, rect(p - vec2(1.1, .025), vec2(.25, .8)));
    result = min(result, rightHalfCircle(p - vec2(1.3695 - .2525*.5, -.14), .249));
    result = min(result, rect(p - vec2(1.3675, -.34), vec2(.2475, .45)));

    return result;
}

float t(vec2 p) {
    float result = 1.;

    result = min(result, rect(p - vec2(0.27, .0), vec2(.25, .75)));
    result = min(result, upHalfCircle(p - vec2(0., .15), .124));

    return result;
}

float i(vec2 p) {
    float result = 1.;

    result = min(result, rect(p, vec2(.25, .5)));
    result = min(result, circle(p - vec2(.0, .25), .124));
    result = min(result, circle(p - vec2(.0, .55), .124));

    return result;
}

float e(vec2 p) {
    float result = 1.;

    result = min(result, upHalfCircle(p - vec2(.0, .0), .25));
    result = min(result, max(p.x - .025, downHalfCircle(p - vec2(.0, - .0175), .25)));

    return result;
}

float rohtie(vec2 p) {
    p /= .415;

    float result = 1.;

    result = min(result, r(p - vec2(.125, .0)));
    result = min(result, o(p - vec2(.675, -.075)));
    result = min(result, h(p - vec2(.035, .0)));
    result = min(result, t(p - vec2(1.57, .0)));
    result = min(result, i(p - vec2(2.19, -.125)));
    result = min(result, e(p - vec2(2.65, -.075)));

    return result;
}

float z(vec2 p, float s, float b) {
    float result = 1.;

    result = min(result, max(leftHalfCircle(p - vec2(0, b), b), p.y - b));
    result = min(result, max(rightHalfCircle(p - vec2(0, -b), b), -(p.y + b)));
    result = min(result, rect(p - vec2(s * 1.5, s * 2.5), vec2(b, s)));
    result = min(result, rect(p - vec2(-s * 1.5, -s * 2.5), vec2(b, s)));

    return result;
}

float e(vec2 p, float s, float b) {
    float result = 1.;

    result = min(result, max(leftHalfCircle(p - vec2(0, b), b), p.y - b));
    result = min(result, max(leftHalfCircle(p - vec2(0, -b), b), -(p.y + b)));
    result = min(result, rect(p - vec2(s * 1.5, s * 2.5), vec2(b, s)));
    result = min(result, rect(p - vec2(s * 1.5, -s * 2.5), vec2(b, s)));
    result = min(result, circle(p - vec2(s, 0.), s));

    return result;
}

float _p(vec2 p, float s, float b) {
    float result = 1.;

    result = min(result, max(leftHalfCircle(p - vec2(0, 0), b), -(p.y)));
    result = min(result, rect(p - vec2(-b * 0.835, -s * 1.5), vec2(s, b)));
    result = min(result, rect(p - vec2(-b * 0.835, -s * 1.5 * 3.), vec2(s, b)));
    result = min(result, max(rightHalfCircle(p - vec2(0, b), b),-(p.y)));

    return result;
}

float _o(vec2 p, float s, float b) {
    float result = 1.;

    result = min(result, circle(p - vec2(0, 0), b));
    result = max(result, -circle(p - vec2(0, 0), b * 0.95));

    return result;
}

float _x(vec2 p, float s, float b) {
    float result = 1.;

    p *= rotate(acos(-1.) * 0.25);

    result = min(result, rect(p - vec2(0., 0.), vec2(b, s)));
    result = min(result, rect(p - vec2(0., 0.), vec2(s, b)));

    return result;
}

float _3(vec2 p, float s, float b) {
    float result = 1.;

    result = min(result, circle(p - vec2(0, b), b));
    result = max(result, -circle(p - vec2(0, b), b * 0.95));
    result = min(result, circle(p - vec2(0, 0), b));
    result = max(result, -circle(p - vec2(0, 0), b * 0.95));

    result = max(result, -rect(p - vec2(-b, s), vec2(b * 1.5, b * 2.)));

    return result;
}

float _0(vec2 p, float s, float b) {
    float result = 1.;

    result = min(result, circle(p - vec2(0, b), b));
    result = max(result, -circle(p - vec2(0, b), b * 0.95));

    result = max(result, -rect(p - vec2(-b, s), vec2(b * 1.5, b * 2.)));

    return result;
}

float sepox32(vec2 p) {
    float result = 1.;

    float s = .025;
    float b = .075;

    p.x -= 0.05;

    float ls = b * 2.1;

    result = min(result, z(p - vec2(-ls * 3., 0.), s, b));
    result = min(result, e(p - vec2(-ls * 2., 0.), s, b));
    result = min(result, _p(p - vec2(-ls * 1., 0.), s, b));
    result = min(result, _o(p - vec2(-ls * 0.75, -ls * 0.5), s, b));
    result = min(result, _x(p - vec2(ls * 0.2, -ls * 0.5), s, b));
    result = min(result, _3(p - vec2(ls * 1.0, -ls * 0.75), s * 0.75, b * 0.75));
    result = min(result, _0(p - vec2(ls * 2.0, -ls * 0.75), s * 0.75, b * 0.75));

    result = smoothstep(0., 0.005, result);

    return result;
}

float capusle(vec2 p, vec2 a, vec2 b, float r, float pointiness) {
    vec2 pa = p - a, ba = b - a;
    float h = clamp( dot(pa, ba) / dot(ba, ba), 0.0, 1.0 );
    return length( pa - ba*h ) - (r + pa.x * pointiness);
}

float capusle(vec2 p, vec2 a, vec2 b, float r) {
    vec2 pa = p - a, ba = b - a;
    float h = clamp( dot(pa, ba) / dot(ba, ba), 0.0, 1.0 );
    return length( pa - ba*h ) - r;
}

float zen(vec2 p) {
    float r = 1.;

    p /= 0.075;

    r = smin(r, capusle(p, vec2(-0.125, 0.38), vec2(-0.09, 0.33), 0.03, -0.3), 0.05);
    r = smin(r, capusle(p, vec2(0.11, 0.42), vec2(0.04, 0.33), 0.03, 0.3), 0.05);

    r = smin(r, capusle(p, vec2(-0.17, 0.26), vec2(0.15, 0.285), 0.01, 0.05), 0.05);
    r = smin(r, capusle(p, vec2(-0.18, 0.14), vec2(0.125, 0.17), 0.01, 0.05), 0.05);
    r = smin(r, capusle(p, vec2(-0.24, 0.015), vec2(0.2, 0.05), 0.01, 0.05), 0.05);
    r = smin(r, capusle(p, vec2(-0.35, -0.15), vec2(0.35, -0.11), 0.01, 0.05), 0.05);
    r = smin(r, capusle(p, vec2(-0.15, -0.01), vec2(-0.1, -0.115), 0.02, 0.05), 0.05);
    r = smin(r, capusle(p, vec2(0.105, -0.01), vec2(0.1, -0.115), 0.02, 0.05), 0.05);
    r = smin(r, capusle(p, vec2(-0.02, 0.26), vec2(-0.02, -0.115), 0.02, 0.05), 0.05);

    r = smin(r, capusle(p, vec2(-0.175, -0.225), vec2(0.15, -0.23), 0.01, 0.05), 0.05);
    r = smin(r, capusle(p, vec2(-0.14, -0.4), vec2(0.15, -0.38), 0.01, 0.05), 0.05);

    r = smin(r, capusle(p, vec2(-0.175, -0.225), vec2(-0.14, -0.4), 0.02, 0.05), 0.05);
    r = smin(r, capusle(p, vec2(0.15, -0.23), vec2(0.1, -0.38), 0.02, 0.05), 0.05);

    p.x += sin(p.y * 10.) * 0.01;
    p.y += sin(p.x * 10.) * 0.01;
    float ring = capusle(p, vec2(0.0, -0.1), vec2(0.0, 0.1), 0.34);
    r = min(r, max(-ring, ring - 0.045));

    return r;
}

float map(vec3 p) {
    vec3 q = p;

    p += noise(p + iGlobalTime * 2.);

    p += atan(p.x, p.y) * 0.25;
    p += atan(p.z, p.x) * 0.25;

    float distort = texture(iChannel0, p.xx * p.yy * p.zz * 0.25).r * 2.;

    float r = (rohtie(p.zy) - distort * clamp(iGlobalTime * 0.2, 0., 1.));

    if (iGlobalTime > 18. && iGlobalTime < 22.5) {
        float rep = 3.5;
        q = mod(q, rep);
        q -= rep * 0.5;

        r = mix(r, length(q) - 1.0, clamp((iGlobalTime - 18.) * 0.15, 0., 1.25));
    }
    else if (iGlobalTime > 18. && iGlobalTime < 30.) {
        r = 1.;
    }

    return r;
}

vec3 normal(vec3 p) {
    vec2 extraPolate = vec2(0.002, 0.0);

    return normalize(vec3(
        map(p + extraPolate.xyy),
        map(p + extraPolate.yxy),
        map(p + extraPolate.yyx)
    ) - map(p));
}

float march(vec3 camera, vec3 ray) {
    float distance = 0.;

    for (int i = 0; i < 100; i++) {
        vec3 p = camera + ray * distance;

        float currentDistance = map(p);

        if (currentDistance < 0.001) {
            return distance;
        }

        distance += currentDistance;
    }

    return -1.;
}

uniform vec3 lights[3] = vec3[3] (
    vec3(-2.5, 2., 2.5),
    vec3(1., 1., 1.),
    vec3(-1., 2.0, -1.5)
);

void mainImage(out vec4 o, in vec2 p) {
	p /= iResolution.xy;

    vec2 qe = p;
    vec2 q = p;
    q.y = 1.0 - q.y;

    p -= 0.5;
    p.x *= iResolution.x / iResolution.y;


    vec3 camera = vec3(0., 0., 5.0);
    vec3 ray = vec3(p.x, p.y, -1.);

    float fadeRate = 0.005;


    if (iGlobalTime < 2.55) {
        camera.z *= 4.55;
        rotate(camera.xz, ray.xz, iGlobalTime * 0.515);
        rotate(camera.xy, ray.xy, iGlobalTime * 0.15);
    }
    else if (iGlobalTime < 6.) {
        camera.z *= 0.2;
        rotate(camera.xz, ray.xz, iGlobalTime * -0.25);
        rotate(camera.xy, ray.xy, iGlobalTime * -0.25);
        fadeRate = 0.1;
    }
    else if (iGlobalTime < 9.) {
        camera.z *= iGlobalTime - 6.;
        rotate(camera.xz, ray.xz, iGlobalTime * 0.45);
        rotate(camera.xy, ray.xy, iGlobalTime * 0.45);
        fadeRate = iGlobalTime * 0.5 - 6.;
        fadeRate = 0.1;
    }
    else if (iGlobalTime < 9.49) {
        camera.z *= iGlobalTime - 6.;
        rotate(camera.xz, ray.xz, iGlobalTime * 0.45);
        rotate(camera.xy, ray.xy, iGlobalTime * 0.45);
        fadeRate = 0.0;
    }
    else if (iGlobalTime < 15.) {
        rotate(camera.xz, ray.xz, iGlobalTime * 0.15);
        rotate(camera.xy, ray.xy, iGlobalTime * 0.15);
        fadeRate = 1.;
    }
    else if (iGlobalTime < 22.2) {
        ray.y = abs(ray.y) - sin(iGlobalTime * 50.);
        rotate(camera.xz, ray.xz, iGlobalTime * 0.15);
        rotate(camera.xy, ray.xy, iGlobalTime * 0.15);
        fadeRate = 1.;
    }
    else {
        rotate(camera.xz, ray.xz, iGlobalTime * 0.15);
        rotate(camera.xy, ray.xy, iGlobalTime * 0.15);
        fadeRate = 0.005;
    }

    vec3 col = vec3(1., 0., 0.);

    float distance = march(camera, ray);

    if (distance > 0.) {
        vec3 p = camera + ray * distance;
        vec3 normal = normal(p);

        col = vec3(0.);

        for (int i = 0; i < 3; i++) {
            vec3 light = lights[i];

            col += vec3(0.25);
            col += vec3(tan(iGlobalTime * distance), tan(iGlobalTime * 2. * distance), tan(iGlobalTime * 5.5)) * max(dot(normal, light), 0.0) * i;

            vec3 halfVector = normalize(light + normal);
            col += vec3(1.) * pow(max(dot(normal, halfVector), 0.0), 20. * i);

            float att = clamp(1.0 - length(light - p) / 5.0, 0.0, 1.0); att *= att;
            col *= att;

            col *= vec3(smoothstep(0.25, 0.75, map(p + light))) + 0.5;
        }
    }
    else {
        if (iGlobalTime > 24.) {
            col = vec3(1.);
        }

        col = mix(texture(previous, q).rgb, col, fadeRate);
    }

    if (iGlobalTime > 9.3 && iGlobalTime < 15.3) {
        col /= smoothstep(0., 0.01, rohtie(p - vec2(-0.5, 0.)));
    }
    else if (iGlobalTime > 9.3 && iGlobalTime < 22.5) {
        col /= smoothstep(0., 0.01, sepox32(p));
    }

    if (iGlobalTime > 22.) {
        p.x += noise(vec3(col));

        float fill = abs(p.x + sin(iGlobalTime + 1.75) * 1.45) - 0.005;
        fill = smoothstep(0., 0.025, fill);
        col += vec3(1.) * (1. - fill);
    }

    // Quality sign
    qe -= 0.5;
    qe.x *= iResolution.x / iResolution.y;
    float re = zen(qe - vec2(0.75, -0.375));
    re = smoothstep(0.0, 0.0125, re);
    col = col * re + vec3(1., 1., 0.) * (1. - re);

    o.rgb = col;
}
