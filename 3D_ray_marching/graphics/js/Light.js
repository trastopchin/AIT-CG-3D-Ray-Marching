/*
Tal Rastopchin
November 18, 2019

Adapted from Laszlo Szecsi's homework starter code and
powerpoint slide instructions.
*/
"use strict";
/* exported Light */
class Light extends UniformProvider {
    constructor(id, ...programs) {
      super(`lights[${id}]`);
      //this.position = new Vec4();  // should be added
      //this.powerDensity = new Vec3(); // by reflection

      this.addComponentsAndGatherUniforms(...programs);
    }
}
