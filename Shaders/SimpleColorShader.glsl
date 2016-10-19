[VERTEX SHADER]

void main(void){
	gl_Position = ftransform();
}

[FRAGMENT SHADER]
uniform vec3 diffuse;
uniform vec3 outlinecolor;
uniform bool outline;
uniform float alpha;

void main (void){
	vec4 finalColor;
	if(outline == 1){
		finalColor = vec4(diffuse, alpha);
	}else{
		finalColor = vec4(outlinecolor, alpha);
	}
	
		gl_FragColor = finalColor;
}