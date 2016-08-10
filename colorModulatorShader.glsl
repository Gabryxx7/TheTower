
[VERTEX SHADER]

 
void main(void)
{
	gl_Position = ftransform();
}


[FRAGMENT SHADER]

uniform vec3 startingColor;
uniform vec3 finalColor;
uniform float time;

void main (void) 
{	
	vec3 color = mix(startingColor, finalColor, time);
	
	gl_FragColor = vec4(color , 0.15);
}
