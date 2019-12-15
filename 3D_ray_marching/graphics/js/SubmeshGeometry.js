"use strict";
/* exported SubmeshGeometry */
class SubmeshGeometry {
  constructor(gl, jsonObject) {
    this.gl = gl;

    // allocate and fill vertex buffer in device memory (OpenGL name: array buffer)
    this.vertexBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, this.vertexBuffer);
    gl.bufferData(gl.ARRAY_BUFFER,
    new Float32Array(jsonObject.vertices),
      gl.STATIC_DRAW);

    this.vertexNormalBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, this.vertexNormalBuffer);
    gl.bufferData(gl.ARRAY_BUFFER,
      new Float32Array(jsonObject.normals), 
      gl.STATIC_DRAW);

    this.vertexTexCoordBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, this.vertexTexCoordBuffer); 
    gl.bufferData(gl.ARRAY_BUFFER, 
      new Float32Array(jsonObject.texturecoords[0]), 
      gl.STATIC_DRAW);

    const indices = [].concat.apply([], jsonObject.faces);
    this.indexCount = indices.length;

    // allocate and fill index buffer in device memory (OpenGL name: element array buffer)
    this.indexBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.indexBuffer);
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER,
      new Uint16Array(indices),
      gl.STATIC_DRAW);


    // create and bind input layout with input buffer bindings (OpenGL name: vertex array)
    this.inputLayout = gl.createVertexArray();
    gl.bindVertexArray(this.inputLayout);

    gl.bindBuffer(gl.ARRAY_BUFFER, this.vertexBuffer);
    gl.enableVertexAttribArray(0);
    gl.vertexAttribPointer(0,
      3, gl.FLOAT, //< three pieces of float
      false, //< do not normalize (make unit length)
      0, //< tightly packed
      0 //< data starts at array start
    );
    gl.bindBuffer(gl.ARRAY_BUFFER, this.vertexNormalBuffer);
    gl.enableVertexAttribArray(1);
    gl.vertexAttribPointer(1,
      3, gl.FLOAT, //< three pieces of float
      false, //< do not normalize (make unit length)
      0, //< tightly packed
      0 //< data starts at array start
    );
    gl.bindBuffer(gl.ARRAY_BUFFER, this.vertexTexCoordBuffer);
    gl.enableVertexAttribArray(2);
    gl.vertexAttribPointer(2,
      2, gl.FLOAT, //< three pieces of float
      false, //< do not normalize (make unit length)
      0, //< tightly packed
      0 //< data starts at array start
    );     
    gl.bindBuffer(gl.ARRAY_BUFFER, this.vertexTexCoordBuffer); 
    gl.enableVertexAttribArray(2); 
    gl.vertexAttribPointer(2, 
      2, gl.FLOAT, //< two pieces of float 
      false, //< do not normalize (make unit length) 
      0, //< tightly packed 
      0 //< data starts at array start 
    ); 

    gl.bindVertexArray(null);
  }

  draw() {
    const gl = this.gl;

    gl.bindVertexArray(this.inputLayout);
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.indexBuffer);  

    gl.drawElements(gl.TRIANGLES, this.indexCount, gl.UNSIGNED_SHORT, 0);
  }
}
