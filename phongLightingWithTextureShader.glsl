[VERTEX SHADER]

// This shader is basically the toon shader without the toon part. It only applies the Phong lighting equation, using the texture of the object

varying vec3 vertexNormal;
varying vec3 lightDirection[8];
varying vec3 position;

uniform int lightsRangeMin;
uniform int lightsRangeMax;

void main()
{
	vertexNormal = gl_NormalMatrix * gl_Normal;
	position = (gl_ModelViewMatrix * gl_Vertex).xyz;
    	
    for(int i = lightsRangeMin; i <= lightsRangeMax; i++)
    {
		if(gl_LightSource[i].position.w == 1.0) 
			lightDirection[i] = vec3(gl_LightSource[i].position.xyz - position);
		else	
	    	lightDirection[i] = vec3(gl_LightSource[i].position);
    }


	gl_Position = ftransform();
	gl_TexCoord[0] = gl_MultiTexCoord0;
}

[FRAGMENT SHADER]

uniform vec3 ambient;
uniform vec3 diffuse;
uniform vec3 specular;
uniform float shininess;

uniform float alpha;

varying vec3 vertexNormal;
varying vec3 lightDirection[8];
varying vec3 position;

uniform int lightsRangeMin;
uniform int lightsRangeMax;

uniform float SCALE_FACTOR;

// Texture of the object
uniform sampler2D tex;


void main()
{
    vec3 color = vec3(0.0, 0.0, 0.0);
    
    vec3 lightDirNorm;
    vec3 eyeVector;
    vec3 half_vector;
    float diffuseFactor;
    float epsilon;
    float specularFactor;
    float attenuation;
    float lightDistance;
        
	// I compute the fragment's color from the texture
	vec3 colorFromTex = texture2D(tex, gl_TexCoord[0].st).rgb;

	vec3 normalDirection = normalize(vertexNormal);
	
	for(int i = lightsRangeMin; i <= lightsRangeMax; i++)
    {
		lightDirNorm = normalize(lightDirection[i]);
		
	 	eyeVector = normalize(-position) ;
		half_vector = normalize(lightDirNorm + eyeVector);
	
	    diffuseFactor = max(0.0, dot(normalDirection, lightDirNorm));
	    
	    specularFactor = max(0.0, dot(normalDirection, half_vector));
	    specularFactor = pow(specularFactor, shininess);
	    
     	color += ambient * gl_LightSource[i].ambient.xyz;
	    color += diffuseFactor * diffuse * gl_LightSource[i].diffuse.xyz;
	   	color += specularFactor * specular * gl_LightSource[i].specular.xyz;

		lightDistance = length(lightDirection[i]);

		float constantAttenuation = 1.0;
		float linearAttenuation = (0.02 / SCALE_FACTOR) * lightDistance;
		float quadraticAttenuation = (0.0 / SCALE_FACTOR) * lightDistance * lightDistance;

		attenuation = 1.0 / (constantAttenuation + linearAttenuation + quadraticAttenuation);

		// I'm not using the attenuation; the light is very dim even like this for the objects that use this shader
//		color = colorFromTex * color * attenuation;
		color = colorFromTex * color * 1.0;
    }
    
	gl_FragColor = vec4(color, alpha);
}
