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

float hash(float n) {
    return fract(sin(n)*43758.5453);
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

float capusle(vec3 p, vec3 a, vec3 b, float r) {
    vec3 pa = p - a, ba = b - a;
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

float mapLeft(vec3 p) {
    return p.y - noise(vec3(p.xz * 1.5, iGlobalTime * 0.5)) * 1.5;
}

vec3 normalLeft(vec3 p) {
    vec2 extraPolate = vec2(0.002, 0.0);

    return normalize(vec3(
        mapLeft(p + extraPolate.xyy),
        mapLeft(p + extraPolate.yxy),
        mapLeft(p + extraPolate.yyx)
    ) - mapLeft(p));
}

float marchLeft(vec3 camera, vec3 ray) {
    float distance = 0.;

    for (int i = 0; i < 100; i++) {
        vec3 p = camera + ray * distance;

        float currentDistance = mapLeft(p);

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

void leftScene(vec2 p, inout vec3 col) {
    vec3 camera = vec3(0., 0., 5.0);
    vec3 ray = vec3(p.x, p.y, -1.);

    rotate(camera.zy, ray.zy, 0.2);
    // rotate(camera.xy, ray.xy, 0.50);

    float distance = marchLeft(camera, ray);

    if (distance > 0.) {
        vec3 p = camera + ray * distance;
        vec3 normal = normalLeft(p);

        col = vec3(0.);

        for (int i = 0; i < 3; i++) {
            vec3 light = lights[i];

            col += vec3(0.25);
            col += vec3(0.05) * max(dot(normal, light), 0.0) * i;

            vec3 halfVector = normalize(light + normal);
            col += vec3(1.) * pow(max(dot(normal, halfVector), 0.0), 20. * i);

            float att = clamp(1.0 - length(light - p) / 5.0, 0.0, 1.0); att *= att;
            col *= att;

            col *= vec3(smoothstep(0.25, 0.75, mapLeft(p + light))) + 0.5;
        }
    }

    col = mix(col, vec3(1.), clamp(1.25 - iGlobalTime * 0.5, 0., 1.));
}

float mapRight(vec3 p) {
    p.x -= -1.5;
    p.z -= 1.;
    p.y -= 0.5;

    float res = p.y;

    float tree = capusle(p, vec3(0., -100, 0.), vec3(0., 100., 0.), 0.1);
    tree -= noise(p + iGlobalTime) * 0.25;
    tree -= noise(vec3(p.xz * 40., iGlobalTime)) * 0.02;

   res = smin(p.y, tree, 0.5);

    return res;
}

vec3 normalRight(vec3 p) {
    vec2 extraPolate = vec2(0.002, 0.0);

    return normalize(vec3(
        mapRight(p + extraPolate.xyy),
        mapRight(p + extraPolate.yxy),
        mapRight(p + extraPolate.yyx)
    ) - mapRight(p));
}

float marchRight(vec3 camera, vec3 ray) {
    float distance = 0.;

    for (int i = 0; i < 100; i++) {
        vec3 p = camera + ray * distance;

        float currentDistance = mapRight(p);

        if (currentDistance < 0.001) {
            return distance;
        }

        distance += currentDistance;
    }

    return -1.;
}

void rightScene(vec2 p, inout vec3 col) {
    vec3 camera = vec3(0., 0., 5.0);
    vec3 ray = vec3(p.x, p.y, -1.);

    rotate(camera.zy, ray.zy, 0.8);
    rotate(camera.xz, ray.xz, 0.9);

    if (iGlobalTime > 15.) {
        camera.y -= (15. - iGlobalTime) * 0.25;
    }

    float distance = marchRight(camera, ray);

    if (distance > 0.) {
        vec3 p = camera + ray * distance;
        vec3 normal = normalRight(p);

        col = vec3(0.);

        vec3 ambient = vec3(0.2, 0.3, 0.25);
        vec3 diffuse = vec3(0.05, 0.05, 0.);
        vec3 specular = vec3(2, 0.1, 0.);

        for (int i = 0; i < 3; i++) {
            vec3 light = lights[i];

            col += ambient;
            col += diffuse * max(dot(normal, light), 0.0) * i;

            vec3 halfVector = normalize(light + normal);

            col += specular * pow(max(dot(normal, halfVector), 0.0), 20. * i);

            float att = clamp(1.0 - length(light - p) / 5.0, 0.0, 1.0); att *= att;
            col *= att;

            col *= vec3(smoothstep(0.25, 0.75, mapRight(p + light))) + 0.5;
        }
    }

    col = mix(col, vec3(1.), clamp(4.25 - iGlobalTime * 0.5, 0., 1.));
}


void mainImage(out vec4 o, in vec2 p) {
    p /= iResolution.xy;

    vec2 q = p;
    vec2 qa = p;

    p -= 0.5;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(1., 1., 1.);


    if (iGlobalTime > 20. && iGlobalTime < 22.) {
        qa.x -= noise(vec3(q * 20., iGlobalTime * 20.)) * 0.1;
    }
    else if (iGlobalTime > 17. && iGlobalTime < 45.) {
        qa.x -= texture(iChannel0, q.yx * 0.1).r * 0.25;
        qa.x += noise(vec3(q * 20., iGlobalTime * 20.)) * 0.1;
    }

    if (qa.x < clamp(2. - iGlobalTime * 0.25, 0.5, 1.0)) {
        leftScene(p, col);
    }
    else {
        rightScene(p, col);
    }

    // if (length(p - vec2(-0.5, 0.)) < 0.25) {
    //     vec2 qb = q;
    //     qb.y = 1. - qb.y;

    //     // bigger
    //     // qb *= 0.995;
    //     // qb += 0.0025;

    //     // smaller
    //     qb *= 1.005;
    //     qb -= 0.0025;

    //     col = texture(previous, qb).rgb;
    // }

    // Quality sign
    q -= 0.5;
    q.x *= iResolution.x / iResolution.y;
    float re = zen(q - vec2(0.75, -0.375));
    re = smoothstep(0.0, 0.0125, re);
    col = col * re + vec3(1., 1., 0.) * (1. - re);

    o.rgb = col;
}
