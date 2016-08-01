[VERTEX SHADER]
varying float distToCamera;

void main()
{	
    vec4 cs_position = gl_ModelViewMatrix * gl_Vertex;
    distToCamera = -cs_position.z;
    gl_Position = gl_ProjectionMatrix * cs_position;
}

[FRAGMENT SHADER]

varying float distToCamera;

void main()
{    
	//if(distToCamera > 8)
    //	gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0 );
    //else
    //	gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0 );
    	
    vec4 outColor = vec4(1.0,0.0,0.0,1.0);
    outColor.a = 1.0 - smoothstep(8-4, 8+4, distToCamera);
    
    if(outColor.a <= 0)
    	discard;
    	
    gl_FragColor = outColor;
}
