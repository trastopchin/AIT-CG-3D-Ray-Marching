# AIT-CG-3D-Ray-Marching

Implement a ray marcher to render implicitly metaballs and other implicitly defined surfaces. Created as an extension of the [ray tracing project]() as the final project for my Computer Graphics course at the Aquincum Instute of Technology the fall of 2019 with professor László Szécsi.

<p align="center">
  <img src="/resources/screenshot01.png" alt="A screenshot of the running project demonstrating each of the completed features." width="800">
</p>

One should be able to download the [3D_ray_marching]() folder and open up the [index.html]() file in a web browser to see the project. To navigate the scene one can use the WASD keys to move around as well as click down and drag the mouse to change the camera's orientation. In the case of google chrome, one might have to open the browser with `open /Applications/Google\ Chrome.app --args --allow-file-access-from-files` in order to load images and textures properly. This project was built upon László Szécsi's starter code and class powerpoint slides.

Whereas there is still some JavaScript code that is making this project work, the majority of the ray tracing implementation takes place within the [march-fs.glsl]() fragment shader.


## Implementation Details

This ray marcher is optimized by using a linear ray march to approximate where primary rays intersect with the implicitly defined surface and the uses a binary ray march to refine the intersection point. This ray marcher also numerically approximates the surface normal so the gradient of the surface equation does not have to be computed explicitly. Lastly, because the ray marching algorithm solves a similar problem as the ray casting algorithm, we can use the same illumination algorithm to render our surface as a mirror-like metallic material.

## Built With

* [WebGLMath](https://github.com/szecsi/WebGLMath) - László Szécsi's vector math library for WebGL programming.
