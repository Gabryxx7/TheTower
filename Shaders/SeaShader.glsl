[VERTEX SHADER]
uniform vec3 baseColor;
uniform vec3 topColor;
uniform vec3 bottomColor;
uniform vec3 clearColor;
uniform vec3 seaPos;
uniform vec3 camPos;
uniform float amplitude;
uniform float viewDistance;
uniform float size;
uniform float alpha;
uniform float beta;
varying vec3 vPos;
uniform float phase;

void main()
{
	vec4 pos = gl_Vertex;
	pos.y += amplitude*cos(alpha+phase)*cos(beta+phase);
	vPos = pos;
	gl_Position = gl_ModelViewProjectionMatrix * pos;
}


[FRAGMENT SHADER]
uniform vec3 baseColor;
uniform vec3 topColor;
uniform vec3 bottomColor;
uniform vec3 clearColor;
uniform vec3 seaPos;
uniform vec3 camPos;
uniform float amplitude;
uniform float viewDistance;
uniform float size;
uniform float alpha;
uniform float beta;
uniform float phase;
varying vec3 vPos;

void main()
{
	float distFromCenter = (vPos.y-seaPos.y)/amplitude;
	vec3 fadedColor;
	if(vPos.y >= seaPos.y)
		fadedColor = mix(baseColor, topColor, distFromCenter);
	else
		fadedColor = mix(baseColor, bottomColor, distFromCenter);
		
	//float distFromCamera = sqrt(
	//vec3 finalColor = mix(fadedColor, clearColor, -vPos.z);
    gl_FragColor = vec4(fadedColor, 1.0);
}