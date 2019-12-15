"use strict";
/* exported PerspectiveCamera */
class PerspectiveCamera extends UniformProvider {
  constructor(...programs) { 
    super("camera");
    this.position = new Vec3(0, 0, 0); 
    this.roll = 0;
    this.pitch = 0;
    this.yaw = 0;  

    this.fov = 1.0; 
    this.aspect = 1.0; 
    this.nearPlane = 0.1; 
    this.farPlane = 1000.0;
    
    this.ahead = new Vec3(0.0, 0.0, -1.0); 
    this.right = new Vec3(1.0, 0.0, 0.0); 
    this.up = new Vec3(0.0, 1.0, 0.0);

    this.speed = 5; 
  
    this.isDragging = false; 
    this.mouseDelta = new Vec2(0.0, 0.0); 

    this.rotationMatrix = new Mat4(); 
    this.viewProjMatrix = new Mat4(); 
    this.rayDirMatrix = new Mat4();
    this.update();

    this.addComponentsAndGatherUniforms(...programs);
  }

  update() { 
    this.rotationMatrix.set(). 
      rotate(this.roll).
      rotate(this.pitch, 1, 0, 0).
      rotate(this.yaw, 0, 1, 0);
    this.viewProjMatrix.set(this.rotationMatrix).             
      translate(this.position).
      invert();

      const yScale = 1.0 / Math.tan(this.fov * 0.5); 
      const xScale = yScale / this.aspect; 
      const f = this.farPlane; 
      const n = this.nearPlane; 
      this.viewProjMatrix.mul( new Mat4( 
          xScale ,    0    ,      0       ,   0, 
            0    ,  yScale ,      0       ,   0, 
            0    ,    0    ,  (n+f)/(n-f) ,  -1, 
            0    ,    0    ,  2*n*f/(n-f) ,   0));
      this.rayDirMatrix.set(this.rotationMatrix).invert().mul( new Mat4( 
          xScale ,    0    ,      0       ,   0, 
            0    ,  yScale ,      0       ,   0, 
            0    ,    0    ,  (n+f)/(n-f) ,  -1, 
            0    ,    0    ,  2*n*f/(n-f) ,   0)).
      	invert();
  }

  setAspectRatio(ar) { 
    this.aspect = ar;
    this.update();
  } 

  move(dt, keysPressed) { 
    if(this.isDragging){ 
      this.yaw -= this.mouseDelta.x * 0.002; 
      this.pitch -= this.mouseDelta.y * 0.002; 
      if(this.pitch > 3.14/2.0) { 
        this.pitch = 3.14/2.0; 
      } 
      if(this.pitch < -3.14/2.0) { 
        this.pitch = -3.14/2.0; 
      } 
      this.mouseDelta = new Vec2(0.0, 0.0);
    }
    if(keysPressed.W) { 
      this.position.addScaled(this.speed * dt, this.ahead); 
    } 
    if(keysPressed.S) { 
      this.position.addScaled(-this.speed * dt, this.ahead); 
    } 
    if(keysPressed.D) { 
      this.position.addScaled(this.speed * dt, this.right); 
    } 
    if(keysPressed.A) { 
      this.position.addScaled(-this.speed * dt, this.right); 
    } 
    if(keysPressed.E) { 
      this.position.addScaled(this.speed * dt, this.up); 
    } 
    if(keysPressed.Q) { 
      this.position.addScaled(-this.speed * dt, this.up); 
    } 

    this.update();
    this.ahead.set(0, 0, -1).xyz0mul(this.rotationMatrix);
    this.right.set(1, 0, 0).xyz0mul(this.rotationMatrix);
    this.up.set(0, 1, 0).xyz0mul(this.rotationMatrix);
  } 

  mouseDown() { 
    this.isDragging = true; 
    this.mouseDelta.set(); 
  } 
  mouseMove(event) { 
    this.mouseDelta.x += event.movementX; 
    this.mouseDelta.y += event.movementY; 
    event.preventDefault();  
  } 
  mouseUp() { 
    this.isDragging = false; 
  } 

}

PerspectiveCamera.worldUp = new Vec4(0, 1, 0, 0);