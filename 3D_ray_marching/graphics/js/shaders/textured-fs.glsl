Shader.source[document.currentScript.src.split('js/shaders/')[1]] = `#version 300 es 
  precision highp float;

  out vec4 fragmentColor;
  in vec4 color;
  in vec4 tex;

  uniform struct{
  	vec4 solidColor;
  	sampler2D colorTexture;
  } material;

  uniform struct {
    float time;
  } scene;

  void main(void) {
    fragmentColor = material.solidColor * cos(scene.time) * 0.01
     + texture(material.colorTexture, tex.xy);
  }
`;