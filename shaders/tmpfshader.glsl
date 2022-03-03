#version 330

in vec3 vPosition;
in vec2 vUv;
in vec3 vNormal;
in vec3 vTangent;
in vec3 vBitangent;

uniform mat4 viewMatrix;

uniform vec3 cameraPosition;

uniform float TIME;
uniform float DTIME;

out vec4 FragColor;

const vec3 lightColor = vec3(1.3, 1.1, 0.9);
const vec3 ambientColor = vec3(0.1, 0.15, 0.25);

const float PI = 3.141592;
const float MAXO = 2 * PI;
const float MINO = 0;
const float MAXF = 15;
const float MINF = 10;
const float JMAX = 10;
const float DELTA = 0.2;

vec3 getLightDir() {
	return normalize(vec3(cos(TIME), 0.8728, sin(TIME)));
}

//A rand function
float rand(float co) { return fract(sin(co*(91.3458)) * 47453.5453);}

//Renders a cosinus with amplitude A, frequency f, phase p and orientation o.
float harmonic(float A, float f, vec2 x, float p, float o) {
x -= vec2(0.5);
    float v = cos(o) * x.x + sin(o) * x.y;
    return A * cos(2.0 * PI * f * v + p);
}

//for a fragment x and a point xi, evaluates a local noise.
float localNoise(vec2 x, vec2 xi) {
    float sum = 0.0;
    for (int j = 0; j < JMAX; j++) {
         // /!\ Might not be random
         // Here we relies on the fact that values should not repeat easely, and that our rand() function works well
         // but we should generate 2 unique IDs for the set (j, xi.x, xi.y), and pass it into a reputed rand function
         float randP = rand(21.132 * float(j) + 7.231 * xi.x + 7.498 * xi.y);
         float randO = rand(12.521 * float(j) + 4.409 * xi.x + 1.145 * xi.y);
         float randF = rand(12.132 * float(j) + 7.231 * xi.x + 7.145 * xi.y);
         
         float minO = MINO; //here we choose the min/max orientation, time dependant for animation
         float maxO = MAXO;
         
         float minF = MINF;
         float maxF = MAXF;
         
         float phi = randP * 2.0 * PI; //Phase, time dependant for animation
         float o = randO * minO + (1.0 - randO) * maxO; //Orientation
         float f = randF * minF + (1.0 - randF) * maxF;
         
         sum += harmonic(
             0.5 / float(JMAX), //Here we set A as 1/(JMAX * 2) to make sure that the sum stays in [-0.5, 0.5]
             f, 
             x, 
             phi, 
             o); 
    }
    return sum;
}

//with o = 0.4, g(0) ~= 1, g(+-1.5) ~= 0
float gaussian (float x, float o) {
   return 1.0 / (o * sqrt(2.0 * PI)) * exp(-((x * x) / (2.0 * o * o)));
}

//w function, basically a gaussian
float w (vec2 x, vec2 xi, float d) {
    return gaussian(distance(x, xi) / d, 0.4);
}

//local noise * w
float ondelette (vec2 x, vec2 xi) {
    return w(x, xi, DELTA) * localNoise(x, xi);
}

//LRP
float LRP(vec2 uv) {
    //If we consider a grid of size UV(=1,1) / Delta, we start & end processing impulses at :
    int startX = int(uv.x / DELTA) - 1;
    int endX = startX + 2;
    int startY = int(uv.y / DELTA) - 1;
    int endY = startY + 2;
    
    float sum = 0.0;
    for (int x = startX; x <= endX; x++) {
        for (int y = startY; y <= endY; y++) {
            vec2 xi = vec2(float(x) * DELTA, float(y) * DELTA);
            sum += ondelette(uv, xi);
        }
    }
    
	return sum;
}

void main () {
	vec3 color = vec3(LRP(vUv) + 0.5);
	FragColor = vec4(color, 1.0);
}
















































































