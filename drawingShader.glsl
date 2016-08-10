
#version 400

[VERTEX SHADER]

varying vec3 position;

void main()
{          
	// I pass to the fragment shader the position of the vertex in world coordinates. To do that I first convert the vertex into eye-space coordinates, 
	// and then apply the inverse
	position = (gl_ModelViewMatrixInverse * (gl_ModelViewMatrix * gl_Vertex)).xyz;

	gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}

[FRAGMENT SHADER]


uniform float alpha; // Alpha value for the line. Thi uniforms is used for lines that are not "connected" (i.e. random lines not attached to anything)

uniform float time;  // Time value, used to change the alpha and the color (for not "connected" lines) over time        

// These uniforms are used for "connected" lines
uniform vec3 startColor;      // Starting color of the line
uniform vec3 finalColor;      // Ending color of the line
uniform vec3 startPoint;      // Starting point (the position of the first connector)
uniform vec3 endPoint;        // Ending point (the position of the second connector)

uniform bool lineIsConnected; // Booleans that indicates whether the line is connected or not

varying vec3 position;        // Position of the fragment (in world coordinates)

void main()
{   
	vec3 color;
	float alphaValue;

	// If this is true, it means that the line we're currently rendering is a "connected" line. In this case, we have to change the color of the fragment
	// depending on how close the fragment is to the endPoint (aka, the other connector)
	if(lineIsConnected)
	{
		// I obtain the line vector, the currentVector (i.e. vector that connects the startPoint to the fragment; I'm going to find the projection of
		// this vector into the line vector) and the total distance
		vec3 line = endPoint - startPoint;
		vec3 currentVector = position - startPoint;
		float totalDistance = length(line);
	    
	    // We have to find the projection of the position of the fragment into the line. To do that I apply tricks regarding line equations, in order to obtain
	    // the projection of the vector. We then subtract the position of the fragment to the projection to get the actual point in the line that is closest.
	    // Keywords for this topic: projection of point into vector, closest point to vector
		vec3 projection = currentVector - line * (dot(currentVector, line) / (totalDistance * totalDistance));
		vec3 point = position - projection;
		
		// I need to study the vector that connects the start of the line to the point found; in particular, I need to know the distance, 
		// i.e. how far is the fragment along the line
		vec3 projectionVector = point - startPoint;		
		float currentDistance = length(projectionVector);
		
		// I normalize the distance according to the total length of the line. This way I get a weight I can pass to the mix function 
		// in order to get the right color interpolation
		float normalizedDistance = currentDistance / totalDistance;
		
		// One special case: lengths are always positive; this means that if I go back behind the starting connector, the length will goes to 0 and then start
		// increasing again, causing the color interpolation to be wrong (it would think that I'm getting closer to the other connector). To avoid this
		// I check the length of the vector that connects the point to the endPoint: if its greater than the length of the line, it means we're behind the
		// starting connector, so I simply use the startColor. Otherwise, I interpolate the color based on the current distance
		if(length(endPoint - point) > totalDistance || currentDistance > totalDistance)
		{
			if(currentDistance < length(endPoint - point))
				color = startColor;
			else
				color = finalColor;
		}
		else
			color = mix(startColor, finalColor, normalizedDistance);
			
		// In order to have some kind of effect on these kind of lines (so that they don't look too static) I apply a pseudo-random thing to the alpha
		alphaValue = abs(cos(time)) + 0.35;
	}
	else
	{
		// If this line isn't connected to anything, I apply a pseudo-random thing to change the color over time, and I set the alpha to what was passed
		color = vec3(sin(time), cos(time), sin(time) - cos(time));
		alphaValue = alpha;	
	}
		
	gl_FragColor = vec4(color, alphaValue);
}
