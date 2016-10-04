[VERTEX SHADER]

void main(void){
	gl_Position = ftransform();
}

[FRAGMENT SHADER]
uniform vec3 color;

void main (void){
	gl_FragColor = vec4(color, 1.0);
}