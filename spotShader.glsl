[VERTEX SHADER]
varying float distToCamera;
uniform bool outline;
uniform bool stepped;
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
uniform float SCALE_FACTOR;
uniform vec3 color;
uniform vec3 outlineColor;
uniform bool outline;
uniform bool stepped;

void main()
{
	float viewDistance = 8 * SCALE_FACTOR;
    float alphaValue = 1;
    if(!stepped)
    	alphaValue = 0.9 - smoothstep(viewDistance-(6*SCALE_FACTOR), viewDistance+(6*SCALE_FACTOR), distToCamera);
    	
    vec4 outColor = vec4(color,alphaValue);
    
    if(outline){
    	if(stepped)
    		alphaValue = 1;
    	else 
    		alphaValue = 1.0 - smoothstep(viewDistance-(3*SCALE_FACTOR), viewDistance+(3*SCALE_FACTOR), distToCamera);
    		
    	outColor = vec4(outlineColor,alphaValue);
	}
    
    if(outColor.a <= 0)
    	discard;   
    	
    gl_FragColor = outColor;
}
