[VERTEX SHADER]
 
void main(void)
{
	gl_Position = ftransform();
}

[FRAGMENT SHADER]

uniform float alpha;

void main (void) 
{	
	gl_FragColor = vec4(1.0, 1.0, 1.0, alpha);
}
