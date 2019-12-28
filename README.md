# AIT-CG-3D-Ray-Marching

Implemented a ray marcher to render metaballs and other implicitly defined surfaces. Created as an extension of the [ray tracing project](https://github.com/trastopchin/AIT-CG-3D-Ray-Tracing) as the final project for my Computer Graphics course at the Aquincum Instute of Technology the fall of 2019 with professor László Szécsi.

This ray marcher is set up to render three moving metaballs and a ground plane with an ideally reflective mirror material.

<p align="center">
  <img src="/resources/screenshot01.png" alt="A screenshot of the running project demonstrating three metaballs metaballs and a ground plane with an ideally reflective mirror material." width="800">
</p>

One should be able to download the [3D_ray_marching](https://github.com/trastopchin/AIT-CG-3D-Ray-Marching/tree/master/3D_ray_marching) folder and open up the [index.html](https://github.com/trastopchin/AIT-CG-3D-Ray-Marching/blob/master/3D_ray_marching/graphics/index.html) file in a web browser to see the project. To navigate the scene one can use the WASD keys to move around as well as click down and drag the mouse to change the camera's orientation. In the case of google chrome, one might have to open the browser with `open /Applications/Google\ Chrome.app --args --allow-file-access-from-files` in order to load images and textures properly. This project was built upon László Szécsi's starter code and class powerpoint slides.

Whereas there is still some JavaScript code that is making this project work, the majority of the ray marching implementation takes place within the [march-fs.glsl](https://github.com/trastopchin/AIT-CG-3D-Ray-Marching/blob/master/3D_ray_marching/graphics/js/shaders/march-fs.glsl) fragment shader.

## Implementation Details

* This ray marcher renders implicitly defined metaballs and other implicitly defined surfaces with point lights, direcitonal lights, the maximum blinn-phong reflecition model, shadows, and ideal mirror reflection.

* Since the ray marching algorithm essentially solves the same problem as the ray tracing algorithm, we can use the exact same illumination algorithm and recursive ray tracing algorithm from the [ray tracing project](https://github.com/trastopchin/AIT-CG-3D-Ray-Tracing) to render our surfaces with a mirror-like metallic material. We also get the same parallelization benefits of implementing the ray marching algorithm in a GLSL fragment shader.

* Since a ray marcher esssentially "steps" a point along a ray until said point is inside of a surface, ray marching can be much more inefficient than ray tracing quadric surfaces. In the ray tracing project given a ray we could query each quadric in the scene and determine the closest intersectoin point. However, with ray marching we have to step a point along a ray and ask whether or not that point is inside of our surface each step, which is a lot more computationally expensive. This ray marcher uses a combination of linear and binary ray marching in order to optimize finding a surface intersection point. The idea behind this is that we can first use a linear ray march with a medium step size to approximate a ray surface intersection. Then, we can use the first point we found inside the surface and the last point outside of our surface as a starting point for a binary ray march where we can refine our surface intersection without too many more computations.

* Instead of explicitly determining the gradient of the implicit surface function, this ray marcher numerically approximates the surface normal. This is important because we can add and mix any sum of implicitly defined surfaces to our liking without having to worry about keeping track of each surface's individual gradient.

* This ray marcher determines whether or not a point is inside the implicity defined surface when evaluating that surface at that point yields a positive sign. We can create an effect similar to a ground plane by making the implicit surface function positive for negative y values. In this implementation we do this by adding `(2.0 - p.y) / 100.0` (where adding 2.0 offsets the ground plane) to the implicit surface function.

## Built With

* [WebGLMath](https://github.com/szecsi/WebGLMath) - László Szécsi's vector math library for WebGL programming.
