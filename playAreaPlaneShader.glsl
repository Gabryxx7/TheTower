#version 400

/* The code of this shader is similar to the code in the playAreaBosShader.glsl, so most of the comments are there */

[VERTEX SHADER]

uniform mat4 modelMatrix;           // Model matrix of the object; used to obtain the world position of the vertices

varying vec4 position;
varying vec4 worldPosition;

void main() 
{
	gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;

	// I pass the vertex position to the shader; note that I'm passing the position in the object's coordinate system
	position = gl_Vertex;
	worldPosition = modelMatrix * gl_Vertex;
}

[FRAGMENT SHADER]

uniform vec3 primaryColor;          // Color of the plane
uniform vec3 secondaryColor;        // Color of the plane when the player is too close to the edge
uniform float width;    			// Width of the box
uniform float height; 
uniform float depth;   				// Depth of the box
uniform float outerEdgesTickness;   // How thick are the edges of the box
uniform vec3 playerPosition;        // Position of the player in the play area
uniform float colorAlpha;
uniform float scaleFactor;

varying vec4 position;              // Interpolated position of the vertex, in object space
varying vec4 worldPosition;         // Interpolated position of the vertex, in world space

void main() 
{		
	float currentHeight = position.y + height / 2.0;

	// Now I check if the fragment is in one of the edges. Taking into account that the origin of the object's coordinate system is in the center
	// of the box, I consider the absolute values of the z and x coordinates to check if the fragment is at the edge, with respect of the given thickness
	if(abs(position.x) > width / 2.0 -  outerEdgesTickness || abs(position.z) > depth / 2.0 -  outerEdgesTickness)
	{
	//	playerPosition.z = -playerPosition.z;
		playerPosition.y -= height / 2.0;
	
		// If we're far away from this fragment, I draw it with the primary color (green); red otherwise. The value 1.5 is basically 1.5 meters
		if(distance(worldPosition.xyz, playerPosition) > 1.2 && currentHeight <= 0.01 * scaleFactor)
			gl_FragColor = vec4(primaryColor, colorAlpha);
//		else 
//			discard;
	 	else if(distance(worldPosition.xyz, playerPosition) <= 1.2)
	 		gl_FragColor = vec4(secondaryColor, colorAlpha);
 		else
 			discard;
	}	
	// Otherwise, if the fragment is nearly in the floor, I draw it but with a little alpha value
	else if(currentHeight < outerEdgesTickness)
		gl_FragColor = vec4(primaryColor, 0.2);
	// Any other fragments (i.e., the top of the box) will be discarded
	else
		discard;
}