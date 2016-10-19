[VERTEX SHADER]

uniform float offset;

void main()
{
	// Sposto il vertice di un tot (determinato dall'offset) lungo la normale al vertice; facendo questo per ogni vertice si crea di fatto una mesh ingrandita
	vec4 pos = vec4(gl_Vertex.xyz + gl_Normal.xyz * offset, 1.0);

	gl_Position = gl_ModelViewProjectionMatrix * pos;
}

[FRAGMENT SHADER]

uniform vec3 color;

void main()
{
	// Il colore del frammento è semplicemente quello passato per definire l'outline
	gl_FragColor = vec4(color, 1.0);   
}
