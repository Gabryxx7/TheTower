#version 400

[VERTEX SHADER]

varying vec4 position;

void main() 
{
	gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;

	// I pass the vertex position to the shader; note that I'm passing the position in the object's coordinate system
	position = gl_Vertex;
}

[FRAGMENT SHADER]

uniform float radius;           // Radius of the circle
uniform vec3 color;             // Color of the circle
uniform float ticksThickness;   // Defines the width of the lines
uniform float ticksNumber;      // Defines how many ticks to draw
uniform float offset;           // Defines the offset of the ticks' positions; it's used to create the illusion that they're moving

varying vec4 position;          // Interpolated position of the vertex, in object space

void main() 
{	
	// There are 2 layers of ticks, one inner and one outer. I need to check if this fragment is inside one of these 2 ticks or outside them; to do that,
	// I compute the distance of the fragment from the origin of the circle, which is [0, 0, 0]. This is why it helps to simply use the object's 
	// coordinate system for these computations
	float dist = distance(vec3(0.0, 0.0, 0.0), position.xyz);
	
	vec4 fragColor;

	// If the distance is around the middle of the radius, it's in the first range; if it's almost at the end of the whole radius, it's at the second ragnge
	bool range1 = dist > radius/2.0 && dist < radius/2.0 + ticksThickness;
	bool range2 = dist > radius - ticksThickness;
	
	// If the fragment belongs to one of the 2 ranges, it's a tick
	if(range1 || range2)
	{
		float actualOffset = offset;
		
		// If it's in the outer layer I invert the offset, so that it looks like that the ticks are moving backwards while the inner ones move forward
		if(range2)
			actualOffset = -actualOffset;
			
		// I compute the angle of this fragment with respect to the origin of the circle. To do that, I use the atan() function, which returns the angle in the
		// radius [-PI, PI] in radiants (so I need to convert it to degrees). Note that I'm using the z and x axis to compute the angle; that's because
		// the default position in object's space of the circle is parallel to the floor, so what in 2D would be the y is now the z.
		// I also add the offset to the angle, so that the angle is shifted
		float angle = degrees(atan(position.z, position.x)) + actualOffset;
		
		// I compute the step size of the tick in the circle, i.e. the length of each tick. I multiply the ticks number by 2 because I have to consider 
		// the "missing ticks" as ticks themselves
		float stepSize = 360.0 / (ticksNumber * 2.0);
		
		// I compute where is the current fragment in this range, i.e. in which "bins" it falls into
		float currentBin = round(angle / stepSize);
		
		// I take the modulo of the bin: if the result is 1, it's a tick; if it's 0, it's the empty space, which I color with a lesser alpha
		if(mod(currentBin, 2.0) != 0.0) 
			fragColor = vec4(color, 1.0);
		else
			fragColor = vec4(color, 0.2);
	}
	// If the fragment isn't in one of the 2 ranges, I simply color it with a lower alpha
	else
		fragColor = vec4(color, 0.2);
		
	gl_FragColor = fragColor;
}