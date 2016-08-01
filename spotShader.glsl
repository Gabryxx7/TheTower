[VERTEX SHADER]
varying float distToCamera;
uniform bool outline;
uniform float offset;
uniform vec3 color;
uniform vec3 outlineColor;

void main()
{	
	if(outline){		
		// Sposto il vertice di un tot (determinato dall'offset) lungo la normale al vertice; facendo questo per ogni vertice si crea di fatto una mesh ingrandita
		vec4 outlinePos = vec4(gl_Vertex.xyz + gl_Normal.xyz * offset, 1.0);
		vec4 pos = gl_ModelViewMatrix * outlinePos;
	    distToCamera = -pos.z;	
		gl_Position = gl_ProjectionMatrix * pos;
	}
	else {
	    vec4 pos = gl_ModelViewMatrix * gl_Vertex;
	    distToCamera = -pos.z;
	    gl_Position = gl_ProjectionMatrix * pos;
    }
}

[FRAGMENT SHADER]

varying float distToCamera;
uniform vec3 color;
uniform vec3 outlineColor;
uniform bool outline;

void main()
{
	float distance = 8;
    float alphaValue = 0.9 - smoothstep(distance-6, distance+6, distToCamera);
    vec4 outColor = vec4(color,alphaValue);
    if(outline){
    	alphaValue = 1.0 - smoothstep(distance-3, distance+3, distToCamera);
    	outColor = vec4(outlineColor,alphaValue);
	}
    
    if(outColor.a <= 0)
    	discard;    	
    	
    gl_FragColor = outColor;
}
