
#version 400

[VERTEX SHADER]

void main()
{          
	gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}

[FRAGMENT SHADER]

uniform float time;           

void main()
{   
	gl_FragColor = vec4(sin(time), cos(time), sin(time) - cos(time), 1.0);
}

/*
#version 400

[VERTEX SHADER]

varying vec3 varyingNormalDirection;
varying vec3 varyingViewDirection;    

void main()
{          
varyingNormalDirection = normalize(gl_NormalMatrix * gl_Normal).xyz;  
varyingViewDirection = normalize(gl_ModelViewMatrix * gl_Vertex).xyz;

gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}

[FRAGMENT SHADER]


uniform float time;           

varying vec3 varyingNormalDirection;
varying vec3 varyingViewDirection;    

void main()
{   
// I project the two vectors on the plane y = 0
vec2 normalDirection = normalize(varyingNormalDirection.xz);
vec2 viewDirection = normalize(varyingViewDirection.xz);

const vec4 color = vec4(1.0,1.0,1.0,0.3);

//      opacity equals infinity when view and normal have an angle of 0,
//      equals 0.001 when they have an angle of 90
//      I also multiply for the dot product between view and normal
//      which is 1 at center, 0 at edge, to increase the falloff
float dotProduct = abs(dot(viewDirection, normalDirection));
float opacity = min(1.0, dotProduct * 0.01 / (1.0 - dotProduct) );

//      with opacity I'm also varying the color, from green to white
gl_FragColor = vec4(1.*opacity,1.0,1.*opacity,opacity*2.);
 }
*/