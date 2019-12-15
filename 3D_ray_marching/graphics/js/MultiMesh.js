"use strict"; 
/* exported MultiMesh */
class MultiMesh extends UniformProvider {
  constructor(gl, jsonModelFileUrl, materials) {
    super("multiMesh");

		const request = new XMLHttpRequest();
	  request.overrideMimeType("application/json"); 
	  request.open("GET", jsonModelFileUrl); 
	  request.onreadystatechange = () => { 
			if (request.readyState == 4) { 
				const submeshes = [];
			  const meshesJson = JSON.parse(request.responseText).meshes; 
			  for (let i = 0; i < meshesJson.length; i++) { 
			    submeshes.push( new Mesh( 
			    	materials[i],
			      new SubmeshGeometry( gl, meshesJson[i])
			    ));
			  } 
			  // get rid of materials
			  this.components.clear();
			  // add actual components
			  this.addComponentsAndGatherUniforms(...submeshes);
			}
	  }; 
	  request.send();

	  // make the materials our child components in lieu of
    // the actual submeshes, loaded later
    this.addComponentsAndGatherUniforms(...materials);
  }
}