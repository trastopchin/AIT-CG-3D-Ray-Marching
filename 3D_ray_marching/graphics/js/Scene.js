/*
Tal Rastopchin
December 12, 2019

Adapted from Laszlo Szecsi's homework starter code and
powerpoint slide instructions.
*/
"use strict";
/* exported Scene */
class Scene extends UniformProvider {
  constructor(gl) {
    super("scene");
    this.programs = [];
    this.gameObjects = [];

    this.vsQuad = new Shader(gl, gl.VERTEX_SHADER, "quad-vs.glsl");    
    this.fsMarch = new Shader(gl, gl.FRAGMENT_SHADER, "march-fs.glsl");

    this.programs.push( 
    	this.traceProgram = new TexturedProgram(gl, this.vsQuad, this.fsMarch));

    this.texturedQuadGeometry = new TexturedQuadGeometry(gl);    

    this.timeAtFirstFrame = new Date().getTime();
    this.timeAtLastFrame = this.timeAtFirstFrame;

    this.traceMaterial = new Material(this.traceProgram);
    this.envTexture = new TextureCube(gl, [
      "media/fnx.png",
      "media/fx.png",
      "media/fy.png",
      "media/fny.png",
      "media/fz.png",
      "media/fnz.png",]
      );
    this.traceMaterial.envTexture.set(this.envTexture);
    this.traceMesh = new Mesh(this.traceMaterial, this.texturedQuadGeometry);

    this.traceQuad = new GameObject(this.traceMesh);
    this.gameObjects.push(this.traceQuad);

    this.camera = new PerspectiveCamera(...this.programs); 
    this.camera.position.set(0, 2, 16);
    this.camera.pitch = -0.2;
    this.camera.update();

    this.lights = [];

    const light1 = new Light(this.lights.length, ...this.programs);
    this.lights.push(light1);
    light1.position.set(0, 4, 4, 1);
    light1.powerDensity.set(10, 10, 10);

    const light2 = new Light(this.lights.length, ...this.programs);
    this.lights.push(light2);
    light2.position.set(-1, 1, 1, 0);
    light2.powerDensity.set(1, 1, 1);

    
    this.metaballs = [];

    const metaball1 = new Metaball(this.metaballs.length, ...this.programs);
    this.metaballs.push(metaball1);
    metaball1.position.set(2, 0, 0);
    metaball1.radius = 0.65;

    const metaball2 = new Metaball(this.metaballs.length, ...this.programs);
    this.metaballs.push(metaball2);
    metaball2.position.set(2, 0, 0);
    metaball2.radius = 0.65;

    const metaball3 = new Metaball(this.metaballs.length, ...this.programs);
    this.metaballs.push(metaball3);
    metaball3.position.set(2, 0, 0);
    metaball3.radius = 0.65;

    this.addComponentsAndGatherUniforms(...this.programs);

    gl.enable(gl.DEPTH_TEST);
  }

  resize(gl, canvas) {
    gl.viewport(0, 0, canvas.width, canvas.height);
    this.camera.setAspectRatio(canvas.width / canvas.height);
  }

  update(gl, keysPressed) {
    //jshint bitwise:false
    //jshint unused:false
    const timeAtThisFrame = new Date().getTime();
    const dt = (timeAtThisFrame - this.timeAtLastFrame) / 1000.0;
    const t = (timeAtThisFrame - this.timeAtFirstFrame) / 1000.0; 
    this.timeAtLastFrame = timeAtThisFrame;
    this.time = t;

    // clear the screen
    gl.clearColor(0.3, 0.0, 0.3, 1.0);
    gl.clearDepth(1.0);
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

    this.camera.move(dt, keysPressed);

    const time = t/2;

    this.metaballs[0].position.set(8, 0, 0);
    this.metaballs[1].position.set(8 * Math.cos(time), 8 * Math.sin(time), 0);
    this.metaballs[2].position.set(8 * Math.cos(time), 0, 8 * Math.sin(time));

    for(const gameObject of this.gameObjects) {
        gameObject.update();
    }
    for(const gameObject of this.gameObjects) {
        gameObject.draw(this, this.camera, ...this.lights, ...this.metaballs);
    }
  }
}
