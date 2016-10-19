
#version 400

[VERTEX SHADER]

varying vec2 textureCoords;

void main()
{    
	gl_Position = vec4(gl_Vertex.xy, 0.0, 1.0);
	textureCoords = gl_Vertex.xy * 0.5 + 0.5;      
	gl_TexCoord[0] = gl_MultiTexCoord0;
	//gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}

[FRAGMENT SHADER]


uniform sampler2D texture;
//uniform float dimension;    // This has to be the texture height (i.e. screen height) for vertical gaussian blur, and the texture width for horizzontal blur

uniform vec2 resolution; // This has to be the texture height (i.e. screen height) for vertical gaussian blur, and the texture width for horizzontal blur

float offset[3] = float[]( 0.0, 1.3846153846, 3.2307692308 );
float weight[3] = float[]( 0.2270270270, 0.3162162162, 0.0702702703 );

//float offset[5] = float[]( 0.0, 1.0, 2.0, 3.0, 4.0 );
//float weight[5] = float[]( 0.2270270270, 0.1945945946, 0.1216216216, 0.0540540541, 0.0162162162 );

uniform float value;

void main() 
{ 
	vec3 textureColor = texture2D(texture, vec2(gl_FragCoord) / resolution) * weight[0];
	
    vec2 uv = gl_TexCoord[0].xy;
        
    for (int i=1; i<3; i++)
    {
        textureColor += texture2D(texture, (vec2(gl_FragCoord) + vec2(0.0, offset[i])) / resolution) * weight[i];
        textureColor += texture2D(texture, (vec2(gl_FragCoord) - vec2(0.0, offset[i])) / resolution) * weight[i];
   	}
  	
  	gl_FragColor = vec4(textureColor, 1.0);
} 