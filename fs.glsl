#version 330

out vec4 finalColor;

in vec4 fragColor;
in vec3 fragPosition;
in vec3 fragNormal;
  
uniform vec3 ambientColor;
uniform vec3 lightPosition;

float ambientStrength = 0.1;

void main()
{
    // ambient
    vec3 ambient = ambientStrength * ambientColor;
    
    // diffuse 
    vec3 norm = normalize(fragNormal);
    vec3 lightDir = normalize(lightPosition - fragPosition);
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = diff * ambientColor;
            
    vec3 result = (ambient + diffuse) * fragColor.rgb;
    finalColor = vec4(result, fragColor.a);
} 