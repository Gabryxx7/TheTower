[VERTEX SHADER]

void main(void){
	gl_Position = ftransform();
}

[FRAGMENT SHADER]
uniform vec3 diffuse;

void main (void){
	gl_FragColor = vec4(diffuse, 1.0);
}