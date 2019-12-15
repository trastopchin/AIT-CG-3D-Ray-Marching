"use strict";
/* exported OrthoCamera */
class OrthoCamera extends UniformProvider {
  constructor(...programs) { 
    super("camera");
    this.position = new Vec2(0.0, 0); 
    this.rotation = 0; 
    this.windowSize = new Vec2(2, 2); 
    
    this.viewProjMatrix = new Mat4(); 
    this.updateViewProjMatrix();

    this.addComponentsAndGatherUniforms(...programs);
  }

  updateViewProjMatrix() { 
    this.viewProjMatrix.set(). 
      scale(0.5). 
      scale(this.windowSize). 
      rotate(this.rotation). 
      translate(this.position). 
      invert(); 
  }

  setAspectRatio(ar) { 
    this.windowSize.x = this.windowSize.y * ar;
    this.updateViewProjMatrix();
  } 
}