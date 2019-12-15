/*
Tal Rastopchin
December 1, 2019

Adapted from Laszlo Szecsi's homework starter code and
powerpoint slide instructions.
*/
"use strict"; 
/* exported ClippedQuadric */
class ClippedQuadric extends UniformProvider {
  constructor(id, ...programs) {
    super(`clippedQuadrics[${id}]`);

    this.addComponentsAndGatherUniforms(...programs);
  }

  makeUnitSphere() {
    this.surface.set(
      1,  0,  0,  0,
      0,  1,  0,  0,
      0,  0,  1,  0,
      0,  0,  0, -1);

    this.clipper.set(
      1,  0,  0,  0,
      0,  1,  0,  0,
      0,  0,  1,  0,
      0,  0,  0, -2);
  }

  makeUnitCylinder(){
    this.surface.set(
      1,  0,  0,  0,
      0,  0,  0,  0,
      0,  0,  1,  0,
      0,  0,  0, -1);

    this.clipper.set(
      0,  0,  0,  0,
      0,  1,  0,  0,
      0,  0,  0,  0,
      0,  0,  0, -1);
  }

  makeUnitCone(){
    this.surface.set(
      1,  0,  0,  0,
      0,  -1,  0,  0,
      0,  0,  1,  0,
      0,  0,  0,  0);

    this.clipper.set(
      0,  0,  0,  0,
      0,  1,  0,  -1,
      0,  0,  0,  0,
      0,  0,  0,  0);
  }

  makeUnitParaboloid(){
    this.surface.set(
      1,  0,  0,  0,
      0,  0,  0,  -1,
      0,  0,  1,  0,
      0,  0,  0,  0);

    this.clipper.set(
      0,  0,  0,  0,
      0,  1,  0,  -1,
      0,  0,  0,  0,
      0,  0,  0,  0);
  }

  makePlane() {
    this.surface.set(
      0,  0,  0,  0,
      0,  1,  0,  0,
      0,  0,  0,  0,
      0,  0,  0,  -1);

    this.clipper.set(
      0,  0,  0,  0,
      0,  1,  0,  0,
      0,  0,  0,  0,
      0,  0,  0, -2);
  }

  // transforms both the surface and the clipper matrices according
  // to the transformation matrix T
  transform(T) {
    const S = T.clone();
    // transform surface
    S.invert();               // T is now T-1
    this.surface.premul(S);
    this.clipper.premul(S);   // A is now T-1 * A
    S.transpose();            // T is now T-1T
    this.surface.mul(S);
    this.clipper.mul(S);      // A is now A'
  }
}

