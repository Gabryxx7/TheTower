
[VERTEX SHADER]

 
void main(void)
{
	gl_Position = ftransform();
}


[FRAGMENT SHADER]

uniform vec3 startingColor;
uniform vec3 finalColor;
uniform float time;
uniform float alpha;

void main (void) 
{	
	vec3 color;
	
	// I mix the color based on the time variable, but only if it didn't reach 1.0; otherwise I simply use the final color,  
	// since it would be the result wanted anyway (otherwise with the time variable going above 0 the mix would end up wrong)
	if(time <= 1.0)
		color = mix(startingColor, finalColor, time);
	else
		color = finalColor;
	
	gl_FragColor = vec4(color, alpha);
}
