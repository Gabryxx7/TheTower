
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


//uniform float rt_w; // render target width
uniform float rt_h; // render target height
//uniform float vx_offset;

uniform sampler2D texture;

const int kernel = 5;

//float offset[3] = float[]( 0.0, 1.3846153846, 3.2307692308 );
//float weight[3] = float[]( 0.2270270270, 0.3162162162, 0.0702702703 );

float offset[5] = float[]( 0.0, 1.0, 2.0, 3.0, 4.0 );
float weight[5] = float[]( 0.2270270270, 0.1945945946, 0.1216216216, 0.0540540541, 0.0162162162 );

uniform float value;

void main() 
{ 
	float rt_w = 1920.0;
	float vx_offset = 0.50;
	
	vec3 tc = vec3(1.0, 0.0, 0.0);
	
    if (gl_TexCoord[0].x < (vx_offset - 0.01))
    {
        vec2 uv = gl_TexCoord[0].xy;
        
        tc = texture2D(texture, uv).rgb * weight[0];
        
    	for (int i=0; i<kernel; i++) 
    	{
        	tc += texture2D(texture, uv + vec2(offset[i])/rt_w, 0.0).rgb * weight[i] / value;
        	tc += texture2D(texture, uv - vec2(offset[i])/rt_w, 0.0).rgb * weight[i] / value;
   	    }
  	}
  	else if (gl_TexCoord[0].x>=(vx_offset+0.01))
 	{
  		tc = texture2D(texture, gl_TexCoord[0].xy).rgb;
  	}
  	
  	gl_FragColor = vec4(tc, 1.0);
} 
