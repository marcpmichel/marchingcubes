#version 330

// Input vertex attributes
in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec3 vertexNormal;
in vec4 vertexColor;

// Input uniform values
uniform mat4 mvp;

// Output vertex attributes (to fragment shader)
out vec2 fragTexCoord;
out vec4 fragColor;

uniform vec3 lightPosition;
uniform vec3 cameraPosition;

out vec3 fragColor;

void main() {
    vec3 normal = normalize(vertexNormal);
    vec3 lightDir = normalize(lightPosition - vertexPosition);
    vec3 viewDir = normalize(cameraPosition - vertexPosition);
    vec3 reflectDir = reflect(-lightDir, normal);

    // Diffuse shading
    float diff = max(dot(normal, lightDir), 0.0);

    // Specular shading
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32.0); // 32 is the shininess factor

    // Combine results
    vec3 ambient = vec3(0.1, 0.1, 0.1); // Ambient color
    vec3 diffuse = vec3(1.0, 1.0, 1.0) * diff; // Red color with diffuse lighting
    vec3 specular = vec3(1.0, 1.0, 1.0) * spec; // White specular highlight

    fragColor = ambient + diffuse + specular;

    gl_Position = mvp * vec4(vertexPosition, 1.0);
}