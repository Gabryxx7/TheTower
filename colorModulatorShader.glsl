
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
	
	if(time <= 1.0)
		color = mix(startingColor, finalColor, time);
	else
		color = finalColor;
	
	gl_FragColor = vec4(color, alpha);
}
