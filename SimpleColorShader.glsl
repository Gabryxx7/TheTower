[VERTEX SHADER]

void main(void){
	gl_Position = ftransform();
}

[FRAGMENT SHADER]
uniform vec3 diffuse;
uniform vec3 outlinecolor;
uniform bool outline;

void main (void){
	vec4 finalColor;
	if(outline == 1){
		finalColor = vec4(diffuse, 1.0);
	}else{
		finalColor = vec4(outlinecolor, 1.0);
	}
	
		gl_FragColor = finalColor;
}