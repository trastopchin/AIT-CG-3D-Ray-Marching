/*
Tal Rastopchin
December 11, 2019

Adapted from Laszlo Szecsi's homework starter code and
powerpoint slide instructions.
*/
"use strict";
/* exported Metaball */
class Metaball extends UniformProvider {
    constructor(id, ...programs) {
      super(`metaballs[${id}]`);
      // added by reflection:
      // this.position = new Vec3();
      // this.radius = 0;

      this.addComponentsAndGatherUniforms(...programs);
    }
}
