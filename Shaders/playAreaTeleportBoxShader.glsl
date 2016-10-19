#version 400

/* NOTE: in order to render the box nicely with this shader, the box has to rendered first culling the front faces (so that only back faces will be drawn) */
/* and then culling the back faces. By doing this, the back faces will be drawn first and their fragment won't be discarded and the transparencies of the fragments */
/* will be computed correctly */

[VERTEX SHADER]

varying vec4 position;

void main() 
{
	gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;

	// I pass the vertex position to the shader; note that I'm passing the position in the object's coordinate system
	position = gl_Vertex;
}

[FRAGMENT SHADER]

uniform vec3 color;                 // Color of the box
uniform float width;    			// Width of the box
uniform float depth;   				// Depth of the box
uniform float height;            	// Height of the box
uniform float outerEdgesTickness;   // How thick are the edges of the box

varying vec4 position;              // Interpolated position of the vertex, in object space

void main() 
{		
	// I find the height of the current fragment in the object's space. I add half the height because The origin of the y is at the center of the object,
	// and I want to know the actual height of the current fragment (from 0, the floor, to the height of the box)
	float currentHeight = position.y + height / 2.0;

	// Now I check if the fragment is in one of the edges. Taking into account that the origin of the object's coordinate system is in the center
	// of the box, I consider the absolute values of the z and x coordinates to check if the fragment is at the edge, with respect of the given thickness
	if(abs(position.x) > width / 2.0 -  outerEdgesTickness || abs(position.z) > depth / 2.0 -  outerEdgesTickness)
	{
		// I compute the alpha value for the shading effect by normalizing the current height to the total height. I actually consider 
		// double the height in order to make the top half of the box invisible; this parameter could be decided with a uniform, in the future
		float alpha = mix(0.0, height * 2.0, currentHeight);
		
		// I draw the fragment with a starting alpha of 0.3 and decrease it with the value above; even if it gets negative, it will be considered 0
		gl_FragColor = vec4(color, 0.3 - alpha);
	}
	// Otherwise, if the fragment is nearly in the floor, I draw it but with a little alpha value
	else if(currentHeight < outerEdgesTickness)
		gl_FragColor = vec4(color, 0.2);
	// Any other fragments (i.e., the top of the box) will be discarded
	else
		discard;
}