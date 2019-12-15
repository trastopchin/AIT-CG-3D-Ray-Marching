Shader.source[document.currentScript.src.split('js/shaders/')[1]] = `#version 300 es 
  precision highp float;

  out vec4 fragmentColor;
  in vec4 texCoord;

  uniform struct {
  	sampler2D img;
  } material;

  void main(void) {
    fragmentColor = texture(material.img, texCoord.xy);
  }

`;