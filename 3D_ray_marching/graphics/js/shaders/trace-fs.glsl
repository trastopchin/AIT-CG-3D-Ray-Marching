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
    mat4 viewProjMatrix;  
    mat4 rayDirMatrix;
    vec3 position;
  } camera;

  uniform struct {
    mat4 surface;
    mat4 clipper;
    vec3 materialColor;
    vec3 specularColor;
    float procMix;
    vec3 reflectance;
  } clippedQuadrics[16];

  uniform struct {
    vec4 position;
    vec3 powerDensity;
  } lights[16];

  bool findBestHit(vec4 e, vec4 d, out float t, out int index);
  float intersectClippedQuadric(mat4 A, mat4 B,vec4 e, vec4 d);
  float intersectQuadric(mat4 A, vec4 e, vec4 d);
  vec3 quadricSurfaceNormal(vec4 point, mat4 quadric);
  vec3 maxPhongBlinn(vec3 normal, vec3 lightDir, vec3 viewDir, vec3 powerDensity, vec3 materialColor, vec3 specularColor, float shininess);
  vec3 shade(vec3 normal, vec3 lightDir, vec3 powerDensity, vec3 materialColor);
  vec3 procWood(vec3 position);
  float snoise(vec3 r);

  int numClippedQuadrics = 14;
  int numLights = 2;

  /*
  Renders xyz
  */
  void main(void) {
    // ray = e + td
    vec4 e = vec4(camera.position, 1);
    vec4 d = vec4(normalize(rayDir).xyz, 0);
    vec3 w = vec3(1.0, 1.0, 1.0);

    for (int iteration = 0; iteration < 4; iteration++) {
      // determine if scene object ray intersection
      float t = 0.0;
      int index = 0;
      bool hit = findBestHit(e, d, t, index);

      // if scene object ray intersection
      if (hit) {
        mat4 surface = clippedQuadrics[index].surface;
        vec4 hitPos = e + d * t;
        vec3 normal = quadricSurfaceNormal(hitPos, surface);

        // if first intersection, we set the fragment distance accordingly
        if (iteration == 0) {
          // computing depth from world space hitPos coordinates 
          vec4 ndcHit = hitPos * camera.viewProjMatrix;
          gl_FragDepth = ndcHit.z / ndcHit.w * 0.5 + 0.5;
        }

        // to handle both sides of the surface, flip normal towards incoming ray
        if(dot(normal, d.xyz) > 0.0) {
          normal *= -1.0;
        }

        //vec3 materialColor = procTexture(hitPos.xyz);
        vec3 materialColor = clippedQuadrics[index].materialColor;
        vec3 specularColor = clippedQuadrics[index].specularColor;
        float procMix = clippedQuadrics[index].procMix;
        materialColor = mix(materialColor, procWood(hitPos.xyz), procMix);
        float shininess = 100.0;

        // light loop
        float delta = 0.0001;
        vec4 shadowStart = hitPos + vec4(delta * normal, 0);
        
        for (int i = 0; i < numLights; i++) {
          vec3 lightDiff = lights[i].position.xyz - hitPos.xyz / hitPos.w * lights[i].position.w;
          vec3 lightDir = normalize(lightDiff);
          float distanceSquared = dot(lightDiff, lightDiff);
          vec3 powerDensity = lights[i].powerDensity / distanceSquared;

          // cast shadow ray
          vec4 shadowDir = vec4(lightDir, 0);
          float bestShadowT = 0.0;
          int shadowIndex = 0;
          bool shadowRayHitSomething = findBestHit(shadowStart, shadowDir, bestShadowT, shadowIndex);

          // if ray didnt hit anything or no occluder
          if(!shadowRayHitSomething ||
           bestShadowT  * lights[i].position.w > sqrt(dot(lightDiff, lightDiff))) {

            fragmentColor.rgb += w * maxPhongBlinn(normal, lightDir, -d.xyz, powerDensity, materialColor, specularColor, shininess);
          }

          // computing depth from world space hitPos coordinates 
          vec4 ndcHit = hitPos * camera.viewProjMatrix;
          gl_FragDepth = ndcHit.z / ndcHit.w * 0.5 + 0.5;
        }
        e = shadowStart;
        d = vec4(reflect(d.xyz, normal), 0);
        w *= clippedQuadrics[index].reflectance;

        if (dot(w, w) < 0.01) {
          break;
        }
      }
      else {
        // nothing hitPos by ray, return enviroment color
        fragmentColor.rgb += w * texture(material.envTexture, d.xyz).xyz;
        w *= 0.0;
        gl_FragDepth = 0.9999999;
      }
    }
  }

  /*
  Determine whether or not a given ray parameterized by vectors e
  and d intersects with the clipped quadrics passed in through the
  clippedQuadrics uniform. Returns a boolean depending on whether
  or not such an intersection is found. If such an intersection is
  found, determine which clipped quadric intersection is closest
  to the ray start and accordingly set the ray parameter t and
  clipped quadric index index.
  */
  bool findBestHit(vec4 e, vec4 d, out float t, out int index) {
    // hitPos represents whether or not an intersection has been found
    bool hitPos = false;

    // initialize our bestT and bestIndex variables
    float bestT = 0.0;
    int bestIndex = 0;

    // for each clipped quadric in our uniform array
    for (int i = 0; i < numClippedQuadrics; i++) {
      mat4 surface = clippedQuadrics[i].surface;
      mat4 clipper = clippedQuadrics[i].clipper;

      float tCurrent = intersectClippedQuadric(surface, clipper, e, d);
      // t negative -> no intersection
      if (tCurrent < 0.0) {
        continue;
      }
      // t positive and first found intersection
      else if (hitPos == false) {
        hitPos = true;
        bestT = tCurrent;
        bestIndex = i;
      }
      // t positive and closer than previously found intersection
      else if (tCurrent < bestT) {
        hitPos = true;
        bestT = tCurrent;
        bestIndex = i;
      }
    }

    // if hitPos set the t and index out parameters accordingly
    if (hitPos) {
      t = bestT;
      index =  bestIndex;
    }

    return hitPos;
  }

  /*
  Determine whether or not a given ray parameterized by vectors e
  and d intersects with a clipped quadric defined by the quadratic
  coefficient matrices A and B, where A represents the surface and
  B represents the clipper. If there is no intersection returns a
  negative value, namely -1.0. If there is an intersection(s),
  determine if they are within the bounds of the clipping quadric
  and then return the closest possible intersection ray parameter.
  */
  float intersectClippedQuadric(mat4 A, mat4 B, vec4 e, vec4 d) {
    // compute quadratic coefficients a, b, and c
    float a = dot(d * A, d);
    float b = dot(d * A, e) + dot(e * A, d);
    float c = dot(e * A, e);

    float discriminant = b*b - 4.0*a*c;

    // if no intersections -> t negative
    if (discriminant < 0.0) {
      return -1.0;
    }

    // if intersections
    float t1 = (-b + sqrt(discriminant)) / 2.0 / a;
    float t2 = (-b - sqrt(discriminant)) / 2.0 / a;

    // determine intersection points
    vec4 r1 = e + d * t1;
    vec4 r2 = e + d * t2;

    // determine if points lie within the clipper
    if (dot(r1 * B, r1) > 0.0) {
      t1 = -1.0;
    }
    if (dot(r2 * B, r2) > 0.0) {
      t2 = -1.0;
    }

    // return lesser of t1 and t2
    return (t1<0.0)?t2:((t2<0.0)?t1:min(t1, t2));
  }

  /*
  Determine whether or not a given ray parameterized by vectors e
  and d intersects with a clipped quadric defined by the quadratic
  coefficient matrix A. If there is no intersection returns a 
  negative value, namely -1.0. If there is an intersection(s),
  return the closest possible intersection ray parameter.
  */
  float intersectQuadric(mat4 A, vec4 e, vec4 d) {
    // compute quadratic coefficients a, b, and c
    float a = dot(d * A, d);
    float b = dot(d * A, e) + dot(e * A, d);
    float c = dot(e * A, e);

    float discriminant = b*b - 4.0*a*c;

    // if no intersections -> t negative
    if (discriminant < 0.0) {
      return -1.0;
    }

    // if intersections
    float t1 = (-b + sqrt(discriminant)) / 2.0 / a;
    float t2 = (-b - sqrt(discriminant)) / 2.0 / a;

    // return lesser of t1 and t2
    return (t1<0.0)?t2:((t2<0.0)?t1:min(t1, t2));
  }

  /*
  Determines the surface normal at a given point on a quadratic
  surface.
  */
  vec3 quadricSurfaceNormal(vec4 point, mat4 surface) {
    return normalize((point * surface + surface * point).xyz);
  }

  /*
  Maximum Phong-Blinn reflection model.
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
  Simple diffuse reflection model.
  */
  vec3 shade(vec3 normal, vec3 lightDir, vec3 powerDensity, vec3 materialColor) {
    float cosa = clamp(dot(lightDir, normal), 0.0, 1.0);
    return cosa * powerDensity * materialColor;
  }

  /*
  Procedural wood texturing based on noise function.
  */
  vec3 procWood(vec3 position) {
    vec3 color1 = 5.0 * vec3(0.181, 0.136, 0.089);
    vec3 color2 = 5.0 * vec3(0.328, 0.270, 0.198);
    float freq = 2.0;
    float noiseFreq = 16.0;
    float noiseExp = 4.0;
    float noiseAmp = 5.0;

    float noise = pow(snoise(position * noiseFreq), noiseExp) * noiseAmp;
    float w = fract(position.z * freq + noise);

    return mix(color1, color2, w);
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