/*
Tal Rastopchin
December 12, 2019

Adapted from Laszlo Szecsi's homework starter code and
powerpoint slide instructions.
*/
Shader.source[document.currentScript.src.split('js/shaders/')[1]] = `#version 300 es 
  precision highp float;

  out vec4 fragmentColor;
  in vec4 rayDir;

  uniform struct {
    samplerCube envTexture;
  } material;

  uniform struct {
    float time;
  } scene;

  uniform struct {
    mat4 viewProjMatrix;  
    mat4 rayDirMatrix;
    vec3 position;
  } camera;

  uniform struct {
    vec4 position;
    vec3 powerDensity;
  } lights[16];

  uniform struct {
    vec3 position;
    float radius;
  } metaballs[16];

  float snoise(vec3 r);

  bool binaryRayMarch (vec3 outsidePoint, vec3 insidePoint, float implicitSurfaceThreshold, int MAX_STEPS, out vec3 intersectionPoint);
  bool linearRayMarch (vec3 e, vec3 d, float tstart, float tend, int MAX_STEPS, out vec3 outsidePoint, out vec3 insidePoint);
  vec3 implicitSurfaceNormal (vec3 p, float A);
  vec3 implicitSurfaceGradient (vec3 p, float A, float delta);
  float implicitSurface (vec3 p, float A);
  float metaball (vec3 p, vec3 c, float R);

  void computeIllumination(vec3 p, vec3 n, vec3 d, vec3 w);
  vec3 maxPhongBlinn(vec3 normal, vec3 lightDir, vec3 viewDir, vec3 powerDensity, vec3 materialColor, vec3 specularColor, float shininess);
  vec3 mirrorShade(vec3 d, vec3 n);

  void main (void) {
    // recursive ray tracing parameters
    const int MAX_RAY_BOUNCES = 4;

    // primary linear ray march parameters
    float tstart = 0.0;
    float tend = 64.0;
    const int MAX_LINEAR_STEPS = 64;
    const int MAX_BINARY_STEPS = 16;
    vec3 outsidePoint;
    vec3 insidePoint;

    vec3 e = camera.position;
    vec3 d = normalize(rayDir.xyz);
    vec3 w = vec3(1, 1, 1);
    
    for (int i = 0; i < MAX_RAY_BOUNCES; i++) {

      bool linearRayMarchHit = linearRayMarch(e, d, tstart, tend, MAX_LINEAR_STEPS, outsidePoint, insidePoint);

      if (linearRayMarchHit) {
        // primary binary ray march parameters
        const float implicitSurfaceThreshold = 0.0001;
        vec3 surfacePoint;

        bool binaryRayMarchHit = binaryRayMarch (outsidePoint, insidePoint, implicitSurfaceThreshold, MAX_BINARY_STEPS, surfacePoint);

        if (binaryRayMarchHit) {

          //vec3 n = implicitSurfaceNormal(insidePoint, 0.1);
          vec3 n = implicitSurfaceNormal(surfacePoint, 0.1);
          computeIllumination(surfacePoint, n, d, w);

          e = surfacePoint + 0.1 * n;
          d = reflect(d, n);
          w *= vec3(1, 1, 1);

          // if accumulated reflectance is too low early terminate
          if (dot(w, w) < 0.01) {
            break;
          }
        }
      }
      else {
        fragmentColor.rgb += w * texture(material.envTexture, d.xyz).xyz;
        w *= 0.0;
      }
    }
  }

  /*
  vec3 outsidePoint : the last point recorded outside the implicit surface
  vec3 insidePoint : the first point recorded inside the implicit surface
  float implicitSurfaceThreshold : a threshold for being on an implicit surface
  int MAX_STEPS : the number of max ray marching steps
  out vec3 intersectionPoint : the resulting implicit surface intersection point
  */
  bool binaryRayMarch (vec3 outsidePoint, vec3 insidePoint, float implicitSurfaceThreshold, int MAX_STEPS, out vec3 intersectionPoint) {
    vec3 p = outsidePoint;
    vec3 d = normalize(insidePoint - outsidePoint);
    float tstart = 0.0;
    float tend = length(insidePoint - outsidePoint);

    float tlength = tend / 2.0;
    p += d * tlength;

    bool flipped = false;
    for (int i = 0; i < MAX_STEPS; i++) {

      float fieldValue = implicitSurface(p, 0.1);
      tlength /= 2.0;

      // if we are close enough to the surface
      if (abs(fieldValue) < implicitSurfaceThreshold) {
        intersectionPoint = p;
        return true;
      }
      // if we are inside the surface
      else if (fieldValue > 0.0) {
        flipped = true;
        p -= d * tlength;
      }
      // if we are outside the surface
      else {
        p += d * tlength;
      }
    }

    intersectionPoint = p;
    return true;
  }

  /*
  vec3 e : the start of the ray
  vec3 d : the direction of the ray
  float tstart : the starting ray parameter for the ray march
  float tend : the ending ray parameter for the ray march
  int MAX_STEPS : the number of max ray marching steps
  out vec3 outsidePoint : the last point recorded outside the implicit surface
  out vec3 insidePoint : the first point recorded inside the implicit surface
  */
  bool linearRayMarch (vec3 e, vec3 d, float tstart, float tend, int MAX_STEPS, out vec3 outsidePoint, out vec3 insidePoint) {
    d = normalize(d);
    vec3 p = e + d * tstart;
    vec3 step = d * (tend - tstart)/float(MAX_STEPS);

    for (int i = 0; i < MAX_STEPS; i++) {
      float fieldValue = implicitSurface(p, 0.1);

      // if h is positive -> we are inside !
      if (fieldValue > 0.0) {

        // write the last two points in our linear march
        insidePoint = p;
        outsidePoint = p - step;
        return true;
      }
      p += step;
    }

    // not inside any object
    return false;
  }

  /*
  vec3 p : the point to evaluate the function
  */
  vec3 implicitSurfaceNormal (vec3 p, float A) {
    return -normalize(implicitSurfaceGradient(p, A, 0.05));
  }

  /*
  vec3 p : the point to evaluate the function
  float delta : the numerical derivative appriximation
  */
  vec3 implicitSurfaceGradient (vec3 p, float A, float delta) {
    vec3 dx = vec3(delta, 0, 0);
    vec3 dy = vec3(0, delta, 0);
    vec3 dz = vec3(0, 0, delta);

    float dfdx = implicitSurface(p + dx, A) - implicitSurface(p - dx, A);
    float dfdy = implicitSurface(p + dy, A) - implicitSurface(p - dy, A);
    float dfdz = implicitSurface(p + dz, A) - implicitSurface(p - dz, A);

    return vec3(dfdx, dfdy, dfdz);
  }

  /*
  vec3 p : the point to evaluate the function
  float A : the level surface value
  */
  float implicitSurface (vec3 p, float A) {
    const int numMetaballs = 3;
    
    float fieldValue = 0.0;
    
    for (int i = 0; i < numMetaballs; i++) {
      vec3 pos = metaballs[i].position;
      float radius = metaballs[i].radius;
      fieldValue += metaball(p, pos, radius);
    }
    
    fieldValue += (2.0-p.y) / 100.0;

    return fieldValue -A;
  }

  /*
  vec3 p : the point to evaluate the function
  vec3 c : the center of the meta ball
  float R : the radius of the meta ball
  */
  float metaball (vec3 p, vec3 c, float R) {
    float r = length(p - c) / R;
    return 1.0 / (r * r);
  }

  /*
  vec3 p : the point at which to compute the illumination
  vec3 n : the surface normal
  vec3 d : the incoming ray direction
  */
  void computeIllumination(vec3 p, vec3 n, vec3 d, vec3 w) {
    const int MAX_LINEAR_STEPS = 64;

    const int numLights = 2;
    for (int i = 0; i < numLights; i++) {

      vec3 lightPos = lights[i].position.xyz;
      vec3 lightDiff = lightPos - p * lights[i].position.w;
      vec3 lightDir = normalize(lightDiff);

      vec3 e = p + 0.1 * n;
      w *= vec3(0.8, 0.8, 0.8);

      vec3 outsidePoint;
      vec3 insidePoint;
      bool shadowRayHit = linearRayMarch(e, lightDir, 0.0, 20.0, MAX_LINEAR_STEPS, outsidePoint, insidePoint);

      if (!shadowRayHit || lights[i].position.w > sqrt(dot(lightDiff, lightDiff))) {
        float distanceSquared = dot(lightDiff, lightDiff);
        vec3 lightPowerDensity = lights[i].powerDensity;
        vec3 powerDensity = lightPowerDensity / distanceSquared;

        vec3 materialColor = 0.0 * vec3(1, 1, 1);
        vec3 specularColor = 0.0 * vec3(1, 1, 1);
        float shininess = 100.0;

        fragmentColor.rgb += w * maxPhongBlinn(n, lightDir, -d, powerDensity, materialColor, specularColor, shininess);
      }
    }
  }

  /*
  vec3 normal : the normal of the surface
  vec3 lightDir : the negative of the incoming light direction
  vec3 viewDir : the view direction
  vec3 powerDensity : the power density of the light
  vec3 materialColor : the material color
  vec3 specularColor : the specular color
  float shininess : the shininess
  */
  vec3 maxPhongBlinn(vec3 normal, vec3 lightDir, vec3 viewDir, vec3 powerDensity, vec3 materialColor, vec3 specularColor, float shininess) {
    float cosa = clamp(dot(lightDir, normal), 0.0, 1.0);
    float cosb = clamp(dot(viewDir, normal), 0.0, 1.0);

    vec3 diffuse = cosa * powerDensity * materialColor;

    vec3 halfway = normalize(viewDir + lightDir);
    float cosDelta = clamp(dot(halfway, normal), 0.0, 1.0);
    vec3 specular = powerDensity * specularColor * pow(cosDelta, shininess);

    return diffuse + specular * cosa / max(cosb, cosa);
  }

  /*
  vec3 d : direction of incoming ray
  vec3 n : normal at ray hit
  */
  vec3 mirrorShade (vec3 d, vec3 n) {
    d = reflect(d, n);
    return texture(material.envTexture, d.xyz).xyz;
  }

  /*
  Noise function f: R^3 -> R.
  */
  float snoise(vec3 r) {
    vec3 s = vec3(7502, 22777, 4767);
    float f = 0.0;
    for(int i=0; i<16; i++) {
      f += sin( dot(s - vec3(32768, 32768, 32768), r)
       / 65536.0);
      s = mod(s, 32768.0) * 2.0 + floor(s / 32768.0);
    }
    return f / 32.0 + 0.5;
  }

  `;