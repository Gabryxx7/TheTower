#version 400

/* NOTE: in order to render the box nicely with this shader, the box has to rendered first culling the front faces (so that only back faces will be drawn) */
/* and then culling the back faces. By doing this, the back faces will be drawn first and their fragment won't be discarded and the transparencies of the fragments */
/* will be computed correctly */

[VERTEX SHADER]

uniform mat4 modelMatrix;

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
uniform float depth;   				// Depth of the box
uniform float outerEdgesTickness;   // How thick are the edges of the box
uniform vec3 playerPosition;        // Position of the player in the play area
uniform float colorAlpha;

varying vec4 position;              // Interpolated position of the vertex, in object space
varying vec4 worldPosition;         // Interpolated position of the vertex, in world space

uniform mat4 modelMatrix;

void main() 
{		
	// Now I check if the fragment is in one of the edges. Taking into account that the origin of the object's coordinate system is in the center
	// of the box, I consider the absolute values of the z and x coordinates to check if the fragment is at the edge, with respect of the given thickness
	if(abs(position.x) > width / 2.0 -  outerEdgesTickness || abs(position.y) > depth / 2.0 -  outerEdgesTickness)
	{
		playerPosition.z = -playerPosition.z;
	
		if(distance(worldPosition.xyz, playerPosition) > 1.5)
			gl_FragColor = vec4(primaryColor, colorAlpha);
		else
			gl_FragColor = vec4(secondaryColor, colorAlpha);
	}	
	// Otherwise, if the fragment is nearly in the floor, I draw it but with a little alpha value
	else
		gl_FragColor = vec4(primaryColor, 0.2);
}