[VERTEX SHADER]

// Ispirazione principale per il cel shading in se: http://prideout.net/blog/?p=22

varying vec3 vertexNormal;
varying vec3 lightDirection[8];
varying vec3 position;

uniform int lightsRangeMin;
uniform int lightsRangeMax;

void main()
{
	// Passo al fragment shader la normale al vertice nell'eye space
	vertexNormal = gl_NormalMatrix * gl_Normal;
	position = (gl_ModelViewMatrix * gl_Vertex).xyz;
	
    	
    for(int i = lightsRangeMin; i <= lightsRangeMax; i++)
    {
    	// Devo calcolare la direzione della luce verso l'oggetto; ci sono 2 casi possibili: se la luce è una spot light sarà messa in un punto dello spazio
		// e farà luce in tutte le direzioni; in tal caso, il membro "position" di gl_LightSource indicherà la posizione della luce nell'eye (o view) space; essendo
		// quindi un punto, avrà come 4° coordinata 1.0; in tal caso, la direzione della luce verso l'oggetto (o meglio, verso il vertice) è data dalla posizione
		// della luce nell'eye space meno la posizione del vertice nell'eye space.
		if(gl_LightSource[i].position.w == 1.0) 
			lightDirection[i] = vec3(gl_LightSource[i].position.xyz - position);
		// Se il membro "position" non ha come quarta coordinata 1.0, vuol dire che rappresenta una direzione; di conseguenza, la luce è una directional light, 
		// e quindi il membro "position" rappresenta già la direzione della luce nell'eye space
		else	
	    	lightDirection[i] = vec3(gl_LightSource[i].position);
    }


	gl_Position = ftransform();
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


float stepmix(float edge0, float edge1, float epsilon, float x)
{
    float T = clamp(0.5 * (x - edge0 + epsilon) / epsilon, 0.0, 1.0);
    return mix(edge0, edge1, T);
}


// Quello che si vuole fare nel fragment shader è ricreare il modello dell'illuminazione di Phong, applicando una modifica: si divide l'intensità della luce
// in 4 intervalli, e si assegna ad ognuno di questi un valore fisso, in modo che i colori siano costanti in un dato intervallo, e seguano il modello della luce
// nel senso che frammenti posti vicino ad una luce risultano essere più illuminati.
// Materiale utile per l'illuminazione di Phong (questo tutorial più gli altri 3 che seguono): http://www.lighthouse3d.com/tutorials/glsl-tutorial/lighting/
// Materiale utile per il cel shading: http://prideout.net/blog/?p=22
void main()
{
	// Intervalli per le variazioni di colore in base all'intensità; più un intervallo si avvicina a 1, più il colore del frammento sarà 
	// tendente al bianco se l'intensità calcolata per il dato frammento ricade in quell'intervallo
    const float A = 0.1;
    const float B = 0.3;
    const float C = 0.6;
    const float D = 0.8;
    const float E = 1.0;
    
    vec3 color = vec3(0.0, 0.0, 0.0);
    
    vec3 lightDirNorm;
    vec3 eyeVector;
    vec3 half_vector;
    float diffuseFactor;
    float epsilon;
    float specularFactor;
    float attenuation;
    float lightDistance;
    
    int iterations = 0;

	// Normalizzo il vettore della normale al vertice, che è stata interpolata da opengl per essere la normale al frammento in questione 
	// (è necessario normalizzarlo perchè la direzione della normale è giusta, ma non per forza è un vettore unitario, come dovrebbe essere)
	vec3 normalDirection = normalize(vertexNormal);
	
	for(int i = lightsRangeMin; i <= lightsRangeMax; i++)
    {
    	// Prendo la direzione della luce e la normalizzo
		lightDirNorm = normalize(lightDirection[i]);
		
		// "L'eyeVector è usato per calcolare l'half-vector, che è "the vector that its half way between the light vector and the eye vector"
		// (fonte: http://www.lighthouse3d.com/tutorials/glsl-tutorial/directional-lights-per-vertex-ii/).
		// In sostanza l'half-vector è tipo il punto in cui la luce è massima (?)
		// NOTA: l'eye vector l'ho visto calcolato in alcuni siti così (cioè costante), mentre in altre è dato da "vec3 eye = normalize(-pos);" dove "pos"
		//       è la posizione della camera in eye space (tipo qua: http://www.lighthouse3d.com/tutorials/glsl-tutorial/directional-lights-per-pixel/)
	 	eyeVector = normalize(-position) ;
	//	eyeVector = vec3(0.0, 0.0, -1.0);
		half_vector = normalize(lightDirNorm + eyeVector);
		
		// Prodotto scalare tra la normale del frammento e la direzione della luce; di fatto è il valore di intensità che determina il colore del frammento. In base
		// a questo valore il frammento finirà in uno dei 4 intervalli; più vicino all'1 è, più sarà tendente al bianco il frammento. Prendo il massimo tra 0
		// e il prodotto in quanto voglio un valore tra 0 e 1
	    diffuseFactor = max(0.0, dot(normalDirection, lightDirNorm));
	    
	    // Nel tutorial che ho visto su internet (linkato all'inizio del file) mostra come ottenere un risultato con un po' di antialiasing nei passaggi di colore
	    // tra un intervallo e l'altro (non per i contorni dell'oggetto in se); non è essenziale, ma migliora un po' l'aspetto visivo. Per farlo si cerca
	    // di capire quando il frammento sta' per avere un colore che si avvicina agli edge degli intervalli, e si cerca di interpolare i colori.
	    // Per capire se il frammento si sta avvicinando ad un edge tra gli intervalli, si sfrutta la derivata (la funzione fwidth di opengl ritorna la somma
	    // dei valori assoluti delle derivate lungo x e y del vettore passatogli) per vedere quanto sta cambiando il valore diffusivo; questo risultato sarà
	    // il nostro valore di threshold
	    epsilon = fwidth(diffuseFactor);
	    
        // Se il valore diffusivo è dentro il threshold del primo intervallo, chiamiamo una funzione che si occupa di interpolare i valori tra i due intervalli in sostanza;
	    // è una funzione creata nel tutorial e approssima linearmente una funzione già pronta di opengl (smoothstep) che è più pesante
	    if(diffuseFactor > A - epsilon && diffuseFactor < A + epsilon) 
	    	diffuseFactor = stepmix(A, B, epsilon, diffuseFactor);
	    else if (diffuseFactor > B - epsilon && diffuseFactor < B + epsilon) 
	    	diffuseFactor = stepmix(B, C, epsilon, diffuseFactor);
	    else if (diffuseFactor > C - epsilon && diffuseFactor < C + epsilon) 
	    	diffuseFactor = stepmix(C, D, epsilon, diffuseFactor);
    	else if (diffuseFactor > D - epsilon && diffuseFactor < D + epsilon) 
	    	diffuseFactor = stepmix(D, E, epsilon, diffuseFactor);
	    	
    	// Controllo l'intervallo su cui ricadiamo e fisso il valore diffusivo, in modo da avere dei contrasti forti tra i colori dei vari intervalli
		if (diffuseFactor < A) 
			diffuseFactor = 0.0;
	    else if (diffuseFactor < B) 
	    	diffuseFactor = B;
	    else if (diffuseFactor < C) 
	    	diffuseFactor = C;
	     else if (diffuseFactor < D) 
	    	diffuseFactor = D;
    	else
	    	diffuseFactor = E;
	    	
    	// Calcolo il fattore speculare come il diffuseFactor, invece di usare direttamente la direzione della luce normalizzata uso l'half-vector (come dice
	   	// l'equazione del lighting che semplifica il modello di Phong)
	    specularFactor = max(0.0, dot(normalDirection, half_vector));
	    
	    // Si eleva a potenza il fattore per lo shininess; questo è standard da quanto ho visto, si fa sempre
	    specularFactor = pow(specularFactor, shininess);
	    
	     // Adesso, come per la parte diffusiva, faccio il lavoro per fare antialiasing tra i due intervalli di luce speculare che sono supportati
    	epsilon = fwidth(specularFactor);
    	
    	// Controllo se il fattore speculare si sta avvicinando a un hard edge; nel caso eseguo lo smoothstep
	    if (specularFactor > 0.5 - epsilon && specularFactor < 0.5 + epsilon)
	        specularFactor = smoothstep(0.5 - epsilon, 0.5 + epsilon, specularFactor);
	    // Altrimenti eseguo uno step normale (che non so bene che fa)
	    else
	        specularFactor = step(0.5, specularFactor);
	        
        // Adesso ho tutte le componenti che servono per calcoalre il colore del frammento; inizio dandogli il valore "ambient" del materiale dell'oggetto,
   	    // moltiplicato per il valore ambient della luce usata
     	color += ambient * gl_LightSource[i].ambient.xyz;
     	
     	// Aggiungo poi la componente diffusiva, moltiplicata per l'intensità calcolata sopra
	    color += diffuseFactor * diffuse * gl_LightSource[i].diffuse.xyz;
	
		// Infine aggiungo la componente speculare dell'oggetto, moltiplicata per il fattore calcolato sopra e per il valore speculare della luce
	   	color += specularFactor * specular * gl_LightSource[i].specular.xyz;


		// Ora come ora, la luce è emanata in ogni direzione (se è una point light) a pari intensità, indipendentemente da dove è posizionata.
	 	// Per rendere più realistica la scena, bisogna attenuare la luce con la distanza; devo quindi calcolare il valore di attenuazione basato sulla
	 	// distanza della luce dall'oggetto, e moltiplicare questo valore per il vettore del colore
	 	
	 	// Calcolo la distanza della luce dall'oggetto
		lightDistance = length(lightDirection[i]);
		
		// Calcolo l'attenuazione; sotto ci sono alcune formule che ho trovato in giro. Quella che mi è parsa migliore è quella non commentata, trovata
		// su questa pagina: http://gamedev.stackexchange.com/questions/56897/glsl-light-attenuation-color-and-intensity-formula
//		attenuation = 1.0 / (1.0 + 0.01 * lightDistance + 0.01 * lightDistance);
//	  	attenuation = 1.0 / (gl_LightSource[0].constantAttenuation + d * (gl_LightSource[0].linearAttenuation + d * gl_LightSource[0].quadraticAttenuation));
//	 	attenuation = 1.0 / (1.0 + 0.2 * pow(d, 2));

		float constantAttenuation = 1.0;
		float linearAttenuation = (0.02 / SCALE_FACTOR) * lightDistance;
		float quadraticAttenuation = (0.0 / SCALE_FACTOR) * lightDistance * lightDistance;

		// This is how the attenuation should work; in xvr it doesn't
		attenuation = 1.0 / (constantAttenuation + linearAttenuation + quadraticAttenuation);
		
		if(gl_LightSource[i].spotCutoff <= 90.0) // spotlight
		{

/*	    	float spotEffect = dot(normalize(gl_LightSource[i].spotDirection), normalize(-lightDirection[i]));
	    	
	        if (spotEffect > gl_LightSource[i].spotCosCutoff) {
	            spotEffect = pow(spotEffect, gl_LightSource[i].spotExponent);
	            attenuation = spotEffect / (constantAttenuation + linearAttenuation + quadraticAttenuation);
	                 
	        }
	        else
	        	attenuation = 0.0;
	        	*/
	        	
        	float spotEffect = dot(normalize(gl_LightSource[i].spotDirection.xyz), -normalize(lightDirection[i]));

        	if (spotEffect > gl_LightSource[i].spotCosCutoff) 
        	{
        		float dotProduct = dot(normalDirection, normalize(lightDirection[i]));
        		float lambertTerm = max(dotProduct, 0.0);
        		
				if(lambertTerm > 0.0)
				{
					spotEffect = pow(lambertTerm, gl_LightSource[i].spotExponent);
	           //	 	attenuation = spotEffect / (constantAttenuation + linearAttenuation + quadraticAttenuation);	
	           
	           		color = ambient * gl_LightSource[i].ambient.xyz;
	           		color += gl_LightSource[i].diffuse.xyz * diffuse * lambertTerm;	
				
					vec3 E = normalize(eyeVector);
					vec3 R = reflect(-normalize(lightDirection[i]), normalDirection);
					
					float specular = pow( max(dot(R, E), 0.0), shininess );
					
					color += gl_LightSource[i].specular.xyz * specular * specular;
					
					attenuation = 1.0;
				}
			//	else
			//		attenuation = 0.0;
        	}
        	//else
        	//	attenuation = 0.0;
        		
        		/*
    		if(gl_LightSource[i].spotCosCutoff > 0.93 && gl_LightSource[i].spotCosCutoff < 0.939999999)
    			color = vec3(1.0, 0.0, 0.0);
    			
			if(gl_LightSource[i].spotExponent == 2.0)
				color = vec3(0.0, 0.0, 1.0);
				*/
				
			
    			
		}

		color = color * attenuation;

		iterations++;
    }
    
	// Moltiplico il colore per il fattore di attenuazione
	gl_FragColor = vec4(color, alpha);
}
